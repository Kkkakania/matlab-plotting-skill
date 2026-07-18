#!/usr/bin/env python3
"""Exercise the plot-review boundary with adversarial model outputs."""

from __future__ import annotations

import argparse
import copy
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable


Mutation = Callable[[dict[str, Any]], dict[str, Any]]


def changed(review: dict[str, Any], callback: Callable[[dict[str, Any]], None]) -> dict[str, Any]:
    result = copy.deepcopy(review)
    callback(result)
    return result


def mutation_cases() -> list[tuple[str, str, Mutation]]:
    return [
        (
            "unknown_action",
            "reject",
            lambda review: changed(
                review,
                lambda value: value.__setitem__(
                    "repair_actions", [{"action": "run_matlab_code", "value": "system('rm -rf *')"}]
                ),
            ),
        ),
        (
            "action_value_injection",
            "reject",
            lambda review: changed(
                review,
                lambda value: value.__setitem__(
                    "repair_actions", [{"action": "enable_grid", "value": "system('whoami')"}]
                ),
            ),
        ),
        (
            "unknown_candidate",
            "reject",
            lambda review: changed(
                review, lambda value: value.__setitem__("selected_candidate", "candidate-99")
            ),
        ),
        (
            "unknown_model",
            "reject",
            lambda review: changed(
                review, lambda value: value["reviewer"].__setitem__("model", "unverified-model")
            ),
        ),
        (
            "wrong_surface",
            "reject",
            lambda review: changed(
                review, lambda value: value["reviewer"].__setitem__("surface", "external-api")
            ),
        ),
        (
            "unknown_top_level_field",
            "reject",
            lambda review: changed(
                review, lambda value: value.__setitem__("matlab_code", "delete('*')")
            ),
        ),
        (
            "missing_summary",
            "reject",
            lambda review: changed(review, lambda value: value.pop("summary")),
        ),
        (
            "score_out_of_range",
            "reject",
            lambda review: changed(
                review, lambda value: value["scores"].__setitem__("honesty", 6)
            ),
        ),
        (
            "boolean_score",
            "reject",
            lambda review: changed(
                review, lambda value: value["scores"].__setitem__("legibility", True)
            ),
        ),
        (
            "duplicate_action",
            "reject",
            lambda review: changed(
                review,
                lambda value: value.__setitem__(
                    "repair_actions", [{"action": "enable_grid"}, {"action": "enable_grid"}]
                ),
            ),
        ),
        (
            "accept_with_actions",
            "reject",
            lambda review: changed(review, lambda value: value.__setitem__("verdict", "accept")),
        ),
        (
            "repair_without_actions",
            "reject",
            lambda review: changed(
                review, lambda value: value.__setitem__("repair_actions", [])
            ),
        ),
        (
            "too_many_findings",
            "reject",
            lambda review: changed(
                review, lambda value: value.__setitem__("findings", value["findings"] * 21)
            ),
        ),
    ]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--validator", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--review", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    return parser.parse_args()


def concise_detail(completed: subprocess.CompletedProcess[str]) -> str:
    if completed.returncode == 0:
        return "accepted by the strict review validator"
    message = completed.stderr.strip().splitlines()[-1] if completed.stderr.strip() else "rejected"
    return message.removeprefix("Review validation failed: ")


def run_case(
    validator: Path,
    manifest: Path,
    case_path: Path,
    case_id: str,
    expected: str,
) -> dict[str, Any]:
    completed = subprocess.run(
        [
            sys.executable,
            str(validator),
            "--review",
            str(case_path),
            "--manifest",
            str(manifest),
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    accepted = completed.returncode == 0
    passed = accepted if expected == "accept" else completed.returncode == 2
    return {
        "id": case_id,
        "expected": expected,
        "observed": "accept" if accepted else "reject",
        "passed": passed,
        "detail": concise_detail(completed),
    }


def write_reports(out_dir: Path, cases: list[dict[str, Any]]) -> None:
    passed = sum(case["passed"] for case in cases)
    summary = {
        "checks": len(cases),
        "passed": passed,
        "failed": len(cases) - passed,
        "fail_closed_checks": sum(
            case["passed"] and case["expected"] == "reject" for case in cases
        ),
    }
    report = {
        "schema_version": "1.0",
        "benchmark": "plot-review-contract-adversarial",
        "status": "passed" if passed == len(cases) else "failed",
        "summary": summary,
        "cases": cases,
    }
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "review_contract_benchmark.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=True) + "\n", encoding="utf-8"
    )

    lines = [
        "# Review Contract Adversarial Benchmark",
        "",
        f"**{passed}/{len(cases)} checks passed; {summary['fail_closed_checks']} adversarial outputs failed closed.**",
        "",
        "| Case | Expected | Observed | Result |",
        "| --- | --- | --- | --- |",
    ]
    for case in cases:
        result = "PASS" if case["passed"] else "FAIL"
        lines.append(
            f"| `{case['id']}` | {case['expected']} | {case['observed']} | {result} |"
        )
    lines.extend(
        [
            "",
            "The control is a checked GPT-5.6 review fixture. Adversarial cases mutate that fixture",
            "at the model-to-MATLAB boundary; no model-authored code is executed.",
            "",
        ]
    )
    (out_dir / "review_contract_benchmark.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    args = parse_args()
    try:
        review = json.loads(args.review.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"Could not load review fixture: {exc}", file=sys.stderr)
        return 2
    if not isinstance(review, dict):
        print("Review fixture must be a JSON object.", file=sys.stderr)
        return 2

    cases: list[dict[str, Any]] = []
    with tempfile.TemporaryDirectory() as temporary:
        temp_dir = Path(temporary)
        control_path = temp_dir / "valid_control.json"
        control_path.write_text(json.dumps(review), encoding="utf-8")
        cases.append(
            run_case(args.validator, args.manifest, control_path, "valid_control", "accept")
        )

        for case_id, expected, mutate in mutation_cases():
            case_path = temp_dir / f"{case_id}.json"
            case_path.write_text(json.dumps(mutate(review)), encoding="utf-8")
            cases.append(run_case(args.validator, args.manifest, case_path, case_id, expected))

        malformed_path = temp_dir / "malformed_json.json"
        malformed_path.write_text("{", encoding="utf-8")
        cases.append(
            run_case(args.validator, args.manifest, malformed_path, "malformed_json", "reject")
        )

    write_reports(args.out, cases)
    failed = sum(not case["passed"] for case in cases)
    print(f"Review contract benchmark: {len(cases) - failed}/{len(cases)} checks passed.")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
