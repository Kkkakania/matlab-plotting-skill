#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys
import xml.etree.ElementTree as ET


ROOT = pathlib.Path(__file__).resolve().parents[1]
EXAMPLE_DIR = ROOT / "skills" / "scientific-diagram-skill" / "assets" / "examples"
DRAWIO = EXAMPLE_DIR / "research-method-flow.drawio"
SVG = EXAMPLE_DIR / "research-method-flow.svg"
PROVENANCE = EXAMPLE_DIR / "provenance.md"

UNIX_USER_ROOT = "/" + "Users" + "/"
UNIX_HOME_ROOT = "/" + "ho" + "me" + "/"
WINDOWS_USER_ROOT = "C:" + "\\\\" + "Users" + "\\\\"

SOURCE_MARKERS = [
    "Auth" + "or:",
    "Created" + " by",
    "Copy" + "right",
    "CS" + "DN",
    "bili" + "bili",
    "知" + "乎",
    "小" + "红" + "书",
    "公众" + "号",
]

SENSITIVE_MARKERS = [
    "身份" + "证",
    "银行" + "卡",
    "手机" + "号",
    "家庭" + "住址",
    "微信" + "号",
]

PRIVATE_PATTERNS = [
    re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
    re.compile(re.escape(UNIX_USER_ROOT) + r"[^\s<]+"),
    re.compile(re.escape(WINDOWS_USER_ROOT) + r"[^\s<]+"),
    re.compile(re.escape(UNIX_HOME_ROOT) + r"[^\s<]+"),
    re.compile("(" + "|".join(re.escape(marker) for marker in SOURCE_MARKERS) + ")"),
    re.compile("(" + "|".join(re.escape(marker) for marker in SENSITIVE_MARKERS) + ")"),
]


def fail(message: str) -> None:
    print(f"check_diagram_examples: {message}", file=sys.stderr)
    sys.exit(1)


def read_text(path: pathlib.Path) -> str:
    if not path.is_file() or path.stat().st_size == 0:
        fail(f"missing or empty file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def check_no_private_markers(path: pathlib.Path, text: str) -> None:
    for pattern in PRIVATE_PATTERNS:
        if pattern.search(text):
            fail(f"private/provenance marker found in {path.relative_to(ROOT)}")


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def check_drawio() -> None:
    text = read_text(DRAWIO)
    check_no_private_markers(DRAWIO, text)
    try:
        root = ET.fromstring(text)
    except ET.ParseError as exc:
        fail(f"drawio XML is not parseable: {exc}")

    if local_name(root.tag) != "mxfile":
        fail("drawio root must be mxfile")

    diagrams = [child for child in root if local_name(child.tag) == "diagram"]
    if len(diagrams) != 1:
        fail("drawio example must contain exactly one diagram")

    model = diagrams[0].find("mxGraphModel")
    if model is None:
        fail("drawio example must contain mxGraphModel")
    model_root = model.find("root")
    if model_root is None:
        fail("drawio example must contain mxGraphModel/root")

    cells = list(model_root.findall("mxCell"))
    vertices = [cell for cell in cells if cell.attrib.get("vertex") == "1"]
    edges = [cell for cell in cells if cell.attrib.get("edge") == "1"]
    if len(vertices) < 5:
        fail("drawio example should have at least five vertex cells")
    if len(edges) < 4:
        fail("drawio example should have at least four edge cells")

    labels = " ".join(cell.attrib.get("value", "") for cell in vertices)
    required_labels = [
        "Input data",
        "Inspect schema",
        "MATLAB figure",
        "mfigci check",
        "README or gallery",
    ]
    missing = [label for label in required_labels if label not in labels]
    if missing:
        fail("drawio example missing labels: " + ", ".join(missing))


def check_svg() -> None:
    text = read_text(SVG)
    check_no_private_markers(SVG, text)
    try:
        root = ET.fromstring(text)
    except ET.ParseError as exc:
        fail(f"SVG is not parseable: {exc}")
    if local_name(root.tag) != "svg":
        fail("SVG root must be svg")
    if "Research method flow" not in text:
        fail("SVG preview should include a descriptive title")
    blocked = ["<script", "href=\"http://", "href=\"https://", "xlink:href=\"http://", "xlink:href=\"https://", "data:"]
    for marker in blocked:
        if marker in text:
            fail(f"SVG preview contains blocked marker: {marker}")


def check_provenance() -> None:
    text = read_text(PROVENANCE)
    check_no_private_markers(PROVENANCE, text)
    required = [
        "clean-room",
        "synthetic labels",
        "Private data: none",
        "research-method-flow.drawio",
        "research-method-flow.svg",
    ]
    missing = [marker for marker in required if marker not in text]
    if missing:
        fail("provenance note missing markers: " + ", ".join(missing))


def main() -> None:
    check_drawio()
    check_svg()
    check_provenance()
    print("Diagram examples check passed.")


if __name__ == "__main__":
    main()
