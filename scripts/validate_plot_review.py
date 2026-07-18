#!/usr/bin/env python3
"""Validate and normalize a Codex-authored scientific plot review."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


SCHEMA_VERSION = "1.0"
SCORE_NAMES = (
    "claim_support",
    "legibility",
    "accessibility",
    "honesty",
    "reproducibility",
)
ALLOWED_ACTIONS = {
    "enable_grid": None,
    "enforce_zero_baseline": None,
    "high_contrast_palette": None,
    "increase_font_size": (8, 24),
    "legend_best": None,
}
ALLOWED_SEVERITIES = {"low", "medium", "high"}
ALLOWED_VERDICTS = {"accept", "repair", "reject"}
ALLOWED_REVIEW_MODELS = {"gpt-5.6-luna", "gpt-5.6-sol", "gpt-5.6-terra"}


class ReviewValidationError(ValueError):
    pass


def require_object(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ReviewValidationError(f"{label} must be a JSON object")
    return value


def require_string(value: Any, label: str, max_length: int = 1000) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ReviewValidationError(f"{label} must be a non-empty string")
    normalized = value.strip()
    if len(normalized) > max_length:
        raise ReviewValidationError(f"{label} exceeds {max_length} characters")
    return normalized


def exact_keys(value: dict[str, Any], required: set[str], label: str) -> None:
    missing = required - value.keys()
    unknown = value.keys() - required
    if missing:
        raise ReviewValidationError(f"{label} is missing fields: {', '.join(sorted(missing))}")
    if unknown:
        raise ReviewValidationError(f"{label} has unknown fields: {', '.join(sorted(unknown))}")


def load_json(path: Path, label: str) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ReviewValidationError(f"could not read {label}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ReviewValidationError(f"invalid JSON in {label}: {exc}") from exc


def manifest_candidate_ids(manifest_path: Path | None) -> set[str] | None:
    if manifest_path is None:
        return None
    manifest = require_object(load_json(manifest_path, "manifest"), "manifest")
    if manifest.get("schema_version") != SCHEMA_VERSION:
        raise ReviewValidationError(f"manifest schema_version must be {SCHEMA_VERSION}")
    candidates = manifest.get("candidates")
    if not isinstance(candidates, list) or not candidates:
        raise ReviewValidationError("manifest candidates must be a non-empty array")
    ids = set()
    for index, candidate_value in enumerate(candidates):
        candidate = require_object(candidate_value, f"manifest candidates[{index}]")
        ids.add(require_string(candidate.get("id"), f"manifest candidates[{index}].id", 80))
    return ids


def normalize_scores(value: Any) -> dict[str, int]:
    scores = require_object(value, "scores")
    exact_keys(scores, set(SCORE_NAMES), "scores")
    normalized = {}
    for name in SCORE_NAMES:
        score = scores[name]
        if isinstance(score, bool) or not isinstance(score, int) or not 1 <= score <= 5:
            raise ReviewValidationError(f"scores.{name} must be an integer from 1 to 5")
        normalized[name] = score
    return normalized


def normalize_reviewer(value: Any) -> dict[str, str]:
    reviewer = require_object(value, "reviewer")
    exact_keys(reviewer, {"surface", "model"}, "reviewer")
    surface = require_string(reviewer["surface"], "reviewer.surface", 40)
    model = require_string(reviewer["model"], "reviewer.model", 80)
    if surface != "codex":
        raise ReviewValidationError("reviewer.surface must be codex")
    if model not in ALLOWED_REVIEW_MODELS:
        raise ReviewValidationError(
            f"reviewer.model must be one of: {', '.join(sorted(ALLOWED_REVIEW_MODELS))}"
        )
    return {"surface": surface, "model": model}


def normalize_findings(value: Any) -> list[dict[str, str]]:
    if not isinstance(value, list) or len(value) > 20:
        raise ReviewValidationError("findings must be an array with at most 20 items")
    normalized = []
    required = {"code", "severity", "evidence", "recommendation"}
    for index, finding_value in enumerate(value):
        finding = require_object(finding_value, f"findings[{index}]")
        exact_keys(finding, required, f"findings[{index}]")
        severity = require_string(finding["severity"], f"findings[{index}].severity", 20)
        if severity not in ALLOWED_SEVERITIES:
            raise ReviewValidationError(f"findings[{index}].severity is unsupported")
        normalized.append(
            {
                "code": require_string(finding["code"], f"findings[{index}].code", 80),
                "severity": severity,
                "evidence": require_string(finding["evidence"], f"findings[{index}].evidence"),
                "recommendation": require_string(
                    finding["recommendation"], f"findings[{index}].recommendation"
                ),
            }
        )
    return normalized


def normalize_actions(value: Any) -> list[dict[str, Any]]:
    if not isinstance(value, list) or len(value) > 8:
        raise ReviewValidationError("repair_actions must be an array with at most 8 items")
    normalized = []
    seen = set()
    for index, action_value in enumerate(value):
        action = require_object(action_value, f"repair_actions[{index}]")
        name = require_string(action.get("action"), f"repair_actions[{index}].action", 80)
        if name not in ALLOWED_ACTIONS:
            raise ReviewValidationError(f"unsupported repair action: {name}")
        if name in seen:
            raise ReviewValidationError(f"duplicate repair action: {name}")
        seen.add(name)
        bounds = ALLOWED_ACTIONS[name]
        expected_keys = {"action", "value"} if bounds else {"action"}
        exact_keys(action, expected_keys, f"repair_actions[{index}]")
        item: dict[str, Any] = {"action": name}
        if bounds:
            value_number = action["value"]
            if isinstance(value_number, bool) or not isinstance(value_number, (int, float)):
                raise ReviewValidationError(f"repair_actions[{index}].value must be numeric")
            if not bounds[0] <= value_number <= bounds[1]:
                raise ReviewValidationError(
                    f"repair_actions[{index}].value must be between {bounds[0]} and {bounds[1]}"
                )
            item["value"] = value_number
        normalized.append(item)
    return normalized


def normalize_review(review_value: Any, candidate_ids: set[str] | None) -> dict[str, Any]:
    review = require_object(review_value, "review")
    required = {
        "schema_version",
        "selected_candidate",
        "verdict",
        "reviewer",
        "summary",
        "scores",
        "findings",
        "repair_actions",
    }
    exact_keys(review, required, "review")
    if review["schema_version"] != SCHEMA_VERSION:
        raise ReviewValidationError(f"review schema_version must be {SCHEMA_VERSION}")

    selected = require_string(review["selected_candidate"], "selected_candidate", 80)
    if candidate_ids is not None and selected not in candidate_ids:
        raise ReviewValidationError("selected_candidate is not present in the candidate manifest")
    verdict = require_string(review["verdict"], "verdict", 20)
    if verdict not in ALLOWED_VERDICTS:
        raise ReviewValidationError(f"verdict must be one of: {', '.join(sorted(ALLOWED_VERDICTS))}")

    findings = normalize_findings(review["findings"])
    actions = normalize_actions(review["repair_actions"])
    if verdict == "accept" and actions:
        raise ReviewValidationError("an accepted review must not contain repair_actions")
    if verdict == "repair" and not actions:
        raise ReviewValidationError("a repair review must contain at least one repair_action")

    return {
        "schema_version": SCHEMA_VERSION,
        "selected_candidate": selected,
        "verdict": verdict,
        "reviewer": normalize_reviewer(review["reviewer"]),
        "summary": require_string(review["summary"], "summary", 2000),
        "scores": normalize_scores(review["scores"]),
        "findings": findings,
        "repair_actions": actions,
        "validation": {
            "status": "validated",
            "allowed_actions": sorted(ALLOWED_ACTIONS),
        },
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--review", required=True, type=Path)
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--out", type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        candidate_ids = manifest_candidate_ids(args.manifest)
        normalized = normalize_review(load_json(args.review, "review"), candidate_ids)
    except ReviewValidationError as exc:
        print(f"Review validation failed: {exc}", file=sys.stderr)
        return 2

    payload = json.dumps(normalized, indent=2, ensure_ascii=True) + "\n"
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(payload, encoding="utf-8")
        print(f"Validated plot review: {args.out}")
    else:
        sys.stdout.write(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
