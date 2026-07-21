#!/usr/bin/env python3
"""Build a self-contained HTML report and integrity manifest for a plot review."""

from __future__ import annotations

import argparse
import base64
import hashlib
import html
import json
import mimetypes
import sys
from pathlib import Path, PurePosixPath
from typing import Any


class BundleError(ValueError):
    """Raised when review evidence cannot be bundled safely."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build an offline HTML report and SHA-256 evidence manifest."
    )
    parser.add_argument("--evidence", required=True, type=Path)
    parser.add_argument("--candidate-manifest", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--manifest-out", required=True, type=Path)
    return parser.parse_args()


def load_object(path: Path, label: str) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exception:
        raise BundleError(f"missing {label}: {path.name}") from exception
    except json.JSONDecodeError as exception:
        raise BundleError(f"invalid {label} JSON: {exception.msg}") from exception
    if not isinstance(value, dict):
        raise BundleError(f"{label} must be a JSON object")
    return value


def require_string(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise BundleError(f"{label} must be a non-empty string")
    return value


def safe_artifact(root: Path, raw_path: Any) -> tuple[str, Path]:
    value = require_string(raw_path, "artifact path")
    if "\\" in value or any(ord(character) < 32 for character in value):
        raise BundleError(f"unsafe artifact path: {value!r}")
    relative = PurePosixPath(value)
    if relative.is_absolute() or not relative.parts or ".." in relative.parts:
        raise BundleError(f"unsafe artifact path: {value!r}")
    normalized = relative.as_posix()
    target = (root / Path(*relative.parts)).resolve()
    try:
        target.relative_to(root.resolve())
    except ValueError as exception:
        raise BundleError(f"unsafe artifact path: {value!r}") from exception
    if not target.is_file():
        raise BundleError(f"missing artifact: {normalized}")
    return normalized, target


def output_in_root(root: Path, path: Path, label: str) -> Path:
    target = path.resolve()
    try:
        target.relative_to(root.resolve())
    except ValueError as exception:
        raise BundleError(f"{label} must be inside the evidence directory") from exception
    return target


def digest(path: Path) -> str:
    checksum = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def artifact_media_type(path: Path) -> str:
    return mimetypes.guess_type(path.name)[0] or "application/octet-stream"


def image_data_uri(path: Path) -> str:
    media_type = artifact_media_type(path)
    if media_type not in {"image/png", "image/jpeg", "image/svg+xml", "image/webp"}:
        raise BundleError(f"unsupported preview image type: {path.name}")
    if path.stat().st_size > 20 * 1024 * 1024:
        raise BundleError(f"preview image exceeds 20 MiB: {path.name}")
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{media_type};base64,{encoded}"


def text(value: Any) -> str:
    return html.escape(str(value), quote=True)


def collect_bundle(
    root: Path,
    evidence_path: Path,
    candidate_path: Path,
    evidence: dict[str, Any],
    candidate_manifest: dict[str, Any],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Path]]:
    if evidence.get("schema_version") != "1.0":
        raise BundleError("review evidence must use schema version 1.0")
    if candidate_manifest.get("schema_version") != "1.0":
        raise BundleError("candidate manifest must use schema version 1.0")

    selected_id = require_string(evidence.get("selected_candidate"), "selected_candidate")
    raw_candidates = candidate_manifest.get("candidates")
    if not isinstance(raw_candidates, list) or not raw_candidates:
        raise BundleError("candidate manifest must contain candidates")

    artifacts: dict[str, dict[str, Any]] = {}
    resolved: dict[str, Path] = {}

    def add(relative: str, path: Path, role: str) -> None:
        item = artifacts.setdefault(
            relative,
            {
                "path": relative,
                "bytes": path.stat().st_size,
                "sha256": digest(path),
                "media_type": artifact_media_type(path),
                "roles": [],
            },
        )
        if role not in item["roles"]:
            item["roles"].append(role)
        resolved[relative] = path

    for source, role in ((evidence_path, "review-evidence"), (candidate_path, "candidate-manifest")):
        relative = source.resolve().relative_to(root.resolve()).as_posix()
        add(relative, source.resolve(), role)

    validated = root / "validated_review.json"
    if validated.is_file():
        relative, path = safe_artifact(root, "validated_review.json")
        add(relative, path, "validated-review")

    candidates: list[dict[str, Any]] = []
    candidate_ids: set[str] = set()
    for index, raw_candidate in enumerate(raw_candidates):
        if not isinstance(raw_candidate, dict):
            raise BundleError(f"candidates[{index}] must be an object")
        candidate_id = require_string(raw_candidate.get("id"), f"candidates[{index}].id")
        if candidate_id in candidate_ids:
            raise BundleError(f"duplicate candidate id: {candidate_id}")
        candidate_ids.add(candidate_id)
        files = raw_candidate.get("files")
        if not isinstance(files, list) or not files:
            raise BundleError(f"candidate {candidate_id} must include files")
        preview_path = ""
        for raw_file in files:
            relative, path = safe_artifact(root, raw_file)
            add(relative, path, f"candidate:{candidate_id}")
            if not preview_path and artifact_media_type(path).startswith("image/"):
                preview_path = relative
        if not preview_path:
            raise BundleError(f"candidate {candidate_id} has no supported preview")
        candidates.append(
            {
                "id": candidate_id,
                "rank": raw_candidate.get("rank", index + 1),
                "scheme": require_string(raw_candidate.get("scheme"), f"{candidate_id}.scheme"),
                "selection_score": raw_candidate.get("selection_score", "n/a"),
                "task": raw_candidate.get("task", ""),
                "preview_path": preview_path,
                "selected": candidate_id == selected_id,
            }
        )

    if selected_id not in candidate_ids:
        raise BundleError("selected candidate is not present in the candidate manifest")

    for key, role in (("before_file", "before"), ("comparison_file", "comparison")):
        relative, path = safe_artifact(root, evidence.get(key))
        add(relative, path, role)
    after_files = evidence.get("after_files")
    if not isinstance(after_files, list) or not after_files:
        raise BundleError("after_files must contain at least one artifact")
    for raw_file in after_files:
        relative, path = safe_artifact(root, raw_file)
        add(relative, path, "final")

    ordered_artifacts = sorted(artifacts.values(), key=lambda item: item["path"])
    for item in ordered_artifacts:
        item["roles"].sort()
    return candidates, ordered_artifacts, resolved


def score_rows(scores: Any) -> str:
    if not isinstance(scores, dict):
        raise BundleError("scores must be an object")
    rows = []
    for name in ("claim_support", "legibility", "accessibility", "honesty", "reproducibility"):
        value = scores.get(name)
        if not isinstance(value, int) or isinstance(value, bool) or not 1 <= value <= 5:
            raise BundleError(f"invalid score: {name}")
        rows.append(
            f'<div class="score"><span>{text(name.replace("_", " ").title())}</span>'
            f'<strong>{value}<small>/5</small></strong></div>'
        )
    return "".join(rows)


def render_report(
    evidence: dict[str, Any],
    candidate_manifest: dict[str, Any],
    candidates: list[dict[str, Any]],
    artifacts: list[dict[str, Any]],
    resolved: dict[str, Path],
) -> str:
    reviewer = evidence.get("reviewer")
    if not isinstance(reviewer, dict):
        raise BundleError("reviewer must be an object")
    findings = evidence.get("findings")
    if not isinstance(findings, list):
        raise BundleError("findings must be an array")
    actions = evidence.get("applied_actions")
    if not isinstance(actions, list):
        raise BundleError("applied_actions must be an array")

    comparison_relative = next(
        item["path"] for item in artifacts if "comparison" in item["roles"]
    )
    comparison_uri = image_data_uri(resolved[comparison_relative])
    candidate_cards = []
    for candidate in candidates:
        state = " selected" if candidate["selected"] else ""
        label = "Selected by validated review" if candidate["selected"] else f'Rule rank {candidate["rank"]}'
        candidate_cards.append(
            f'<article class="candidate{state}">'
            f'<img src="{image_data_uri(resolved[candidate["preview_path"]])}" '
            f'alt="{text(candidate["id"])} preview">'
            f'<div class="candidate-copy"><span class="candidate-state">{text(label)}</span>'
            f'<h3>{text(candidate["scheme"].replace("_", " "))}</h3>'
            f'<p>{text(candidate["id"])} · rule score {text(candidate["selection_score"])}</p>'
            f'<p>{text(candidate["task"])}</p></div></article>'
        )

    finding_rows = []
    for index, finding in enumerate(findings):
        if not isinstance(finding, dict):
            raise BundleError(f"findings[{index}] must be an object")
        finding_rows.append(
            '<article class="finding">'
            f'<span class="severity {text(finding.get("severity", "unknown"))}">'
            f'{text(finding.get("severity", "unknown"))}</span>'
            f'<h3>{text(finding.get("code", "finding").replace("_", " "))}</h3>'
            f'<p>{text(finding.get("evidence", ""))}</p>'
            f'<p class="recommendation">{text(finding.get("recommendation", ""))}</p>'
            '</article>'
        )

    action_items = "".join(f"<li>{text(action)}</li>" for action in actions) or "<li>None</li>"
    integrity_rows = "".join(
        '<tr>'
        f'<td>{text(item["path"])}</td>'
        f'<td>{text(", ".join(item["roles"]))}</td>'
        f'<td>{item["bytes"]:,}</td>'
        f'<td><code>{item["sha256"][:16]}…</code></td>'
        '</tr>'
        for item in artifacts
    )
    data_summary = candidate_manifest.get("data_summary", {})
    data_bits = []
    if isinstance(data_summary, dict):
        for key in ("rows", "columns", "numeric_columns", "category_columns", "time_columns"):
            if key in data_summary:
                data_bits.append(f"{key.replace('_', ' ')}: {data_summary[key]}")
    data_line = " · ".join(data_bits) if data_bits else "summary recorded in candidate manifest"

    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src data:; style-src 'unsafe-inline'">
<title>PlotProof Review Evidence</title>
<style>
:root {{ color-scheme: light; --ink:#17212b; --muted:#5d6873; --line:#d8dee4;
  --paper:#ffffff; --wash:#f4f6f7; --teal:#087e75; --red:#b33a3a; --gold:#9a6612; }}
* {{ box-sizing:border-box; }}
body {{ margin:0; background:var(--wash); color:var(--ink); font:15px/1.55 system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }}
header {{ background:#152a2d; color:white; padding:38px max(24px,calc((100vw - 1120px)/2)); border-bottom:5px solid #d9a52e; }}
.eyebrow {{ margin:0 0 8px; color:#9fddd7; font-size:12px; font-weight:800; text-transform:uppercase; }}
h1 {{ margin:0; font-size:48px; line-height:1.05; font-weight:760; }}
.lede {{ max-width:820px; margin:16px 0 0; color:#e8eeee; font-size:17px; }}
.status {{ display:flex; flex-wrap:wrap; gap:8px; margin-top:20px; }}
.pill {{ display:inline-flex; padding:5px 9px; border:1px solid #5a7274; border-radius:4px; color:#eff7f6; font-size:12px; font-weight:700; }}
main {{ width:min(1120px,calc(100% - 32px)); margin:28px auto 56px; }}
section {{ margin-top:34px; }}
.section-head {{ display:flex; align-items:end; justify-content:space-between; gap:16px; border-bottom:2px solid var(--ink); margin-bottom:16px; }}
h2 {{ margin:0 0 8px; font-size:23px; }} h3 {{ margin:4px 0 8px; font-size:17px; }}
.summary {{ display:grid; grid-template-columns:1.5fr 1fr; gap:20px; }}
.panel {{ background:var(--paper); border:1px solid var(--line); border-radius:6px; padding:20px; }}
.panel p:first-child {{ margin-top:0; }}
.scores {{ display:grid; grid-template-columns:repeat(5,1fr); gap:8px; }}
.score {{ background:var(--paper); border-top:4px solid var(--teal); padding:12px; min-height:92px; }}
.score span {{ display:block; color:var(--muted); font-size:12px; }} .score strong {{ display:block; margin-top:8px; font-size:25px; }}
.score small {{ color:var(--muted); font-size:12px; }}
.comparison {{ width:100%; display:block; background:white; border:1px solid var(--line); }}
.candidates {{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:14px; }}
.candidate {{ background:var(--paper); border:1px solid var(--line); border-radius:6px; overflow:hidden; }}
.candidate.selected {{ border:3px solid var(--teal); }}
.candidate img {{ display:block; width:100%; aspect-ratio:4/3; object-fit:contain; background:white; border-bottom:1px solid var(--line); }}
.candidate-copy {{ padding:14px; }} .candidate-copy p {{ margin:6px 0 0; color:var(--muted); }}
.candidate-state {{ color:var(--teal); font-size:12px; font-weight:800; text-transform:uppercase; }}
.findings {{ display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:12px; }}
.finding {{ background:var(--paper); border-left:5px solid var(--gold); padding:16px 18px; }}
.severity {{ display:inline-block; color:var(--gold); font-size:11px; font-weight:800; text-transform:uppercase; }}
.severity.high {{ color:var(--red); }} .recommendation {{ color:var(--teal); font-weight:650; }}
.repairs {{ columns:2; margin:0; padding-left:22px; }}
.integrity-note {{ color:var(--teal); font-weight:750; }}
.table-wrap {{ overflow-x:auto; background:white; border:1px solid var(--line); }}
table {{ width:100%; border-collapse:collapse; }} th,td {{ padding:10px 12px; border-bottom:1px solid var(--line); text-align:left; }}
th {{ background:#e9eeee; font-size:12px; text-transform:uppercase; }} code {{ font:12px ui-monospace,SFMono-Regular,Consolas,monospace; }}
footer {{ color:var(--muted); border-top:1px solid var(--line); margin-top:38px; padding-top:18px; }}
@media (max-width:760px) {{ h1 {{ font-size:32px; }} .summary,.candidates,.findings {{ grid-template-columns:1fr; }} .scores {{ grid-template-columns:repeat(2,1fr); }} .repairs {{ columns:1; }} }}
@media print {{ body {{ background:white; }} header {{ padding:24px; }} main {{ width:100%; }} .panel,.candidate,.table-wrap {{ break-inside:avoid; }} }}
</style>
</head>
<body>
<header>
  <p class="eyebrow">PlotProof · review evidence bundle</p>
  <h1>{text(evidence.get("selected_scheme", "Scientific figure review").replace("_", " "))}</h1>
  <p class="lede">{text(evidence.get("summary", ""))}</p>
  <div class="status"><span class="pill">{text(evidence.get("verdict", "reviewed")).upper()}</span>
  <span class="pill">{text(reviewer.get("model", "unknown model"))}</span>
  <span class="pill">SHA-256 evidence manifest</span><span class="pill">Offline report</span></div>
</header>
<main>
  <section class="summary">
    <div class="panel"><h2>Decision context</h2><p>{text(evidence.get("goal", ""))}</p>
      <p><strong>Selected:</strong> {text(evidence.get("selected_candidate"))} · {text(evidence.get("selected_scheme"))}</p>
      <p><strong>Data:</strong> {text(evidence.get("data_file", ""))} · {text(data_line)}</p></div>
    <div class="panel"><h2>Review provenance</h2><p><strong>Surface:</strong> {text(reviewer.get("surface", ""))}</p>
      <p><strong>Model:</strong> {text(reviewer.get("model", ""))}</p>
      <p><strong>Workflow:</strong> generate → review → repair → evidence</p></div>
  </section>
  <section><div class="section-head"><h2>Review scores</h2><span>1–5 contract scale</span></div><div class="scores">{score_rows(evidence.get("scores"))}</div></section>
  <section><div class="section-head"><h2>Before and after</h2><span>Validated repairs only</span></div>
    <img class="comparison" src="{comparison_uri}" alt="Before and after validated MATLAB figure repair"></section>
  <section><div class="section-head"><h2>Candidate decision</h2><span>{len(candidates)} rendered alternatives</span></div>
    <div class="candidates">{"".join(candidate_cards)}</div></section>
  <section><div class="section-head"><h2>Findings</h2><span>Evidence before recommendation</span></div>
    <div class="findings">{"".join(finding_rows)}</div></section>
  <section class="panel"><h2>Applied repair allowlist</h2><ul class="repairs">{action_items}</ul></section>
  <section><div class="section-head"><h2>Integrity</h2><span class="integrity-note">Integrity verified at bundle build</span></div>
    <p>Every source artifact below is hashed in <code>review_bundle_manifest.json</code>. Run the verifier after copying or downloading the bundle.</p>
    <div class="table-wrap"><table><thead><tr><th>Artifact</th><th>Role</th><th>Bytes</th><th>SHA-256</th></tr></thead>
    <tbody>{integrity_rows}</tbody></table></div></section>
  <footer>Generated locally from validated review evidence. No network resources, executable model output, or private absolute paths are embedded.</footer>
</main>
</body>
</html>
'''


def run() -> None:
    args = parse_args()
    evidence_path = args.evidence.resolve()
    candidate_path = args.candidate_manifest.resolve()
    if evidence_path.parent != candidate_path.parent:
        raise BundleError("evidence and candidate manifest must share one directory")
    root = evidence_path.parent
    out_path = output_in_root(root, args.out, "--out")
    manifest_path = output_in_root(root, args.manifest_out, "--manifest-out")
    if out_path == manifest_path:
        raise BundleError("--out and --manifest-out must be different files")
    protected_inputs = {evidence_path, candidate_path, root / "validated_review.json"}
    if out_path in protected_inputs or manifest_path in protected_inputs:
        raise BundleError("bundle outputs may not overwrite review inputs")

    evidence = load_object(evidence_path, "review evidence")
    candidate_manifest = load_object(candidate_path, "candidate manifest")
    candidates, artifacts, resolved = collect_bundle(
        root, evidence_path, candidate_path, evidence, candidate_manifest
    )
    report = render_report(evidence, candidate_manifest, candidates, artifacts, resolved)
    bundle_manifest = {
        "schema_version": "1.0",
        "status": "complete",
        "algorithm": "sha256",
        "report_file": out_path.relative_to(root).as_posix(),
        "evidence_file": evidence_path.relative_to(root).as_posix(),
        "candidate_manifest_file": candidate_path.relative_to(root).as_posix(),
        "artifacts": artifacts,
    }
    out_path.write_text(report, encoding="utf-8")
    manifest_path.write_text(
        json.dumps(bundle_manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"Review report: {out_path}")
    print(f"Integrity manifest: {manifest_path}")
    print(f"Hashed artifacts: {len(artifacts)}")


if __name__ == "__main__":
    try:
        run()
    except BundleError as exception:
        print(f"Review bundle error: {exception}", file=sys.stderr)
        raise SystemExit(2) from exception
