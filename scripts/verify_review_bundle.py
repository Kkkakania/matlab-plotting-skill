#!/usr/bin/env python3
"""Verify every artifact recorded in a PlotProof review bundle manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path, PurePosixPath
from typing import Any


class VerificationError(ValueError):
    """Raised when a review bundle is malformed or has changed."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Verify a review evidence bundle.")
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--root", required=True, type=Path)
    return parser.parse_args()


def safe_artifact(root: Path, raw_path: Any) -> tuple[str, Path]:
    if (
        not isinstance(raw_path, str)
        or not raw_path
        or "\\" in raw_path
        or any(ord(character) < 32 for character in raw_path)
    ):
        raise VerificationError(f"unsafe artifact path: {raw_path!r}")
    relative = PurePosixPath(raw_path)
    if relative.is_absolute() or ".." in relative.parts:
        raise VerificationError(f"unsafe artifact path: {raw_path!r}")
    target = (root / Path(*relative.parts)).resolve()
    try:
        target.relative_to(root.resolve())
    except ValueError as exception:
        raise VerificationError(f"unsafe artifact path: {raw_path!r}") from exception
    return relative.as_posix(), target


def digest(path: Path) -> str:
    checksum = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def run() -> None:
    args = parse_args()
    root = args.root.resolve()
    if not root.is_dir():
        raise VerificationError(f"bundle root is not a directory: {root}")
    try:
        manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError) as exception:
        raise VerificationError(f"could not read integrity manifest: {exception}") from exception
    if not isinstance(manifest, dict):
        raise VerificationError("integrity manifest must be an object")
    if manifest.get("schema_version") != "1.0" or manifest.get("algorithm") != "sha256":
        raise VerificationError("unsupported integrity manifest contract")
    artifacts = manifest.get("artifacts")
    if not isinstance(artifacts, list) or not artifacts:
        raise VerificationError("integrity manifest contains no artifacts")

    seen: set[str] = set()
    for index, item in enumerate(artifacts):
        if not isinstance(item, dict):
            raise VerificationError(f"artifacts[{index}] must be an object")
        relative, path = safe_artifact(root, item.get("path"))
        if relative in seen:
            raise VerificationError(f"duplicate artifact path: {relative}")
        seen.add(relative)
        if not path.is_file():
            raise VerificationError(f"missing artifact: {relative}")
        expected_bytes = item.get("bytes")
        if not isinstance(expected_bytes, int) or isinstance(expected_bytes, bool):
            raise VerificationError(f"invalid byte count: {relative}")
        if path.stat().st_size != expected_bytes:
            raise VerificationError(f"byte count mismatch: {relative}")
        expected_hash = item.get("sha256")
        if not isinstance(expected_hash, str) or len(expected_hash) != 64:
            raise VerificationError(f"invalid SHA-256 value: {relative}")
        if digest(path) != expected_hash:
            raise VerificationError(f"SHA-256 mismatch: {relative}")

    print(f"Review bundle verified: {len(artifacts)} artifacts")


if __name__ == "__main__":
    try:
        run()
    except VerificationError as exception:
        print(f"Review bundle verification failed: {exception}", file=sys.stderr)
        raise SystemExit(1) from exception
