#!/usr/bin/env python3
"""Check UI and dungeon PNG imports, and shipped sizes against size lists.

Stdlib only. Reads PNG width and height from the IHDR chunk. Parses Godot
.import / .tscn / .tres / project.godot as text.

Size lists live in design/visual/sizes/*.sizes.json. Each file is either a
JSON array, or an object with an "assets" array (other keys are notes).
Every entry is::

    {"path": "assets/ui/example.png", "native": [w, h], "shipped": [w, h]}

``path`` is repo-relative (``res://`` and backslashes are accepted).
The PNG's IHDR size must equal ``shipped``. ``native`` is recorded for the
art list and is not compared.

Check (a), for every PNG under assets/ui/** and assets/dungeon/** that has
a sibling .import file:

- compress/mode is lossless (0)
- mipmaps/generate is false
- sampling is Nearest. project.godot default_texture_filter=0 counts as
  Nearest. An .import filter flag or a scene texture_filter that sets Linear
  (CanvasItem values 2, 4, 6, or a Linear name) is a failure.

Writes design/audit-shots/cursor/png_check.json and a short summary.
Exit code 1 when failures is non-empty.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path, PurePosixPath


PNG_SIG = b"\x89PNG\r\n\x1a\n"
ASSET_ROOTS = ("assets/ui", "assets/dungeon")
LINEAR_CANVAS = {2, 4, 6}
NEAREST_OR_INHERIT = {0, 1, 3, 5}
EXT_RESOURCE_RE = re.compile(r'ExtResource\(\s*"([^"]+)"\s*\)')
NODE_NAME_RE = re.compile(r'name="([^"]*)"')
NODE_PARENT_RE = re.compile(r'parent="([^"]*)"')
RES_ID_RE = re.compile(r'\bid="([^"]+)"')
RES_PATH_RE = re.compile(r'path="([^"]+)"')


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for candidate in (here.parents[2], Path.cwd()):
        if (candidate / "project.godot").is_file():
            return candidate
    return here.parents[2]


def posix_rel(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def normalize_asset_path(raw: str) -> str:
    text = raw.strip().strip('"').replace("\\", "/")
    if text.startswith("res://"):
        text = text[len("res://") :]
    return text.lstrip("./")


def under_asset_roots(rel: str) -> bool:
    return any(rel == folder or rel.startswith(folder + "/") for folder in ASSET_ROOTS)


def path_selected(rel: str, only: str | None) -> bool:
    if not only:
        return True
    pure = PurePosixPath(rel)
    return pure.full_match(only) or pure.match(only)


def png_ihdr(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        sig = handle.read(8)
        if sig != PNG_SIG:
            raise ValueError("missing PNG signature")
        length_bytes = handle.read(4)
        chunk_type = handle.read(4)
        if len(length_bytes) != 4 or chunk_type != b"IHDR":
            raise ValueError("IHDR chunk is not first")
        length = int.from_bytes(length_bytes, "big")
        data = handle.read(length)
        if len(data) < 8:
            raise ValueError("IHDR is truncated")
        width = int.from_bytes(data[0:4], "big")
        height = int.from_bytes(data[4:8], "big")
        return width, height


def iter_prop_lines(text: str):
    section = ""
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            section = stripped
            continue
        if not stripped or stripped.startswith(";") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        yield section, key.strip(), value.strip()


def classify_canvas_filter(raw: str) -> str:
    token = raw.split("#", 1)[0].strip().strip('"')
    if re.fullmatch(r"-?\d+", token):
        number = int(token)
        if number in LINEAR_CANVAS:
            return "linear"
        if number in NEAREST_OR_INHERIT:
            return "inherit" if number == 0 else "nearest"
        return "unknown"
    upper = token.upper()
    if "NEAREST" in upper or upper in {
        "PARENT",
        "PARENT_NODE",
        "TEXTURE_FILTER_PARENT_NODE",
        "INHERIT",
    }:
        return "nearest" if "NEAREST" in upper else "inherit"
    if "LINEAR" in upper:
        return "linear"
    return "unknown"


def project_default_is_linear(project_text: str) -> str | None:
    for _section, key, value in iter_prop_lines(project_text):
        if key != "textures/canvas_textures/default_texture_filter":
            continue
        token = value.split("#", 1)[0].strip()
        if token == "0":
            return None
        if token in {"1", "2"}:
            return f"default_texture_filter={token} (Linear). Nearest is 0"
        if token == "3":
            return None
        return f"default_texture_filter={token} is not Nearest (0)"
    return "project.godot has no textures/canvas_textures/default_texture_filter=0"


def import_problems(text: str) -> list[str]:
    reasons: list[str] = []
    mode = None
    mipmaps = None
    for _section, key, value in iter_prop_lines(text):
        if key == "compress/mode":
            mode = value.split("#", 1)[0].strip()
        elif key == "mipmaps/generate":
            mipmaps = value.split("#", 1)[0].strip().lower()
        elif "filter" in key.lower():
            flag = value.split("#", 1)[0].strip().strip('"').lower()
            key_l = key.lower()
            linear = flag in {"true", "linear", "linear_with_mipmaps", "linear_with_mipmaps_anisotropic"}
            if key_l in {"flags/filter", "process/filter"} and flag in {"1", "true"}:
                linear = True
            if "texture_filter" in key_l and classify_canvas_filter(flag) == "linear":
                linear = True
            if linear:
                reasons.append(f"{key}={value} sets Linear")
    if mode != "0":
        shown = "missing" if mode is None else mode
        reasons.append(f"compress/mode={shown} (lossless is 0)")
    if mipmaps != "false":
        shown = "missing" if mipmaps is None else mipmaps
        reasons.append(f"mipmaps/generate={shown} (expected false)")
    return reasons


def scene_linear_hits(text: str) -> list[tuple[str, str]]:
    """Return (repo-relative png, reason) for Linear overrides in one scene."""
    resources: dict[str, str] = {}
    nodes: list[dict] = []
    current: dict | None = None
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if current is not None:
                nodes.append(current)
            current = None
            if stripped.startswith("[ext_resource "):
                id_match = RES_ID_RE.search(stripped)
                path_match = RES_PATH_RE.search(stripped)
                if id_match and path_match:
                    resources[id_match.group(1)] = normalize_asset_path(path_match.group(1))
            elif stripped.startswith("[node "):
                name_match = NODE_NAME_RE.search(stripped)
                parent_match = NODE_PARENT_RE.search(stripped)
                name = name_match.group(1) if name_match else ""
                if parent_match is None:
                    node_path = "."
                else:
                    parent = parent_match.group(1)
                    node_path = name if parent == "." else f"{parent}/{name}"
                current = {
                    "path": node_path,
                    "filter": None,
                    "textures": [],
                }
            continue
        if current is None or "=" not in stripped or stripped.startswith(";"):
            continue
        key, value = stripped.split("=", 1)
        key = key.strip()
        value = value.strip()
        if key == "texture_filter":
            current["filter"] = classify_canvas_filter(value)
            current["filter_raw"] = value
        else:
            current["textures"].extend(EXT_RESOURCE_RE.findall(value))
    if current is not None:
        nodes.append(current)

    by_path = {node["path"]: node for node in nodes}
    hits: list[tuple[str, str]] = []

    def parent_of(node_path: str) -> str | None:
        if node_path == ".":
            return None
        if "/" not in node_path:
            return "."
        return node_path.rsplit("/", 1)[0]

    def effective(node_path: str) -> str:
        seen: set[str] = set()
        while node_path is not None and node_path not in seen:
            seen.add(node_path)
            node = by_path.get(node_path)
            if node and node["filter"] in {"linear", "nearest", "unknown"}:
                return node["filter"]
            node_path = parent_of(node_path)
        return "inherit"

    for node in nodes:
        kind = effective(node["path"])
        if kind not in {"linear", "unknown"}:
            continue
        label = "Linear" if kind == "linear" else f"unrecognized texture_filter {node.get('filter_raw', '')}"
        for res_id in node["textures"]:
            asset = resources.get(res_id, "")
            if under_asset_roots(asset):
                hits.append((asset, f"scene sets {label} on node {node['path']}"))
        if kind == "unknown" and not node["textures"]:
            hits.append(("", f"scene node {node['path']} sets {label}"))
    return hits


def load_size_entries(path: Path) -> tuple[list, str | None]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [], f"size list is not valid JSON ({exc})"
    if isinstance(data, list):
        entries = data
    elif isinstance(data, dict) and isinstance(data.get("assets"), list):
        entries = data["assets"]
    else:
        return [], "size list must be an array, or an object with an assets array"
    return entries, None


def entry_error(entry: object) -> str | None:
    if not isinstance(entry, dict):
        return "size entry is not an object"
    path = entry.get("path")
    native = entry.get("native")
    shipped = entry.get("shipped")
    if not isinstance(path, str) or not path.strip():
        return "size entry needs a path string"
    for label, pair in (("native", native), ("shipped", shipped)):
        if (
            not isinstance(pair, list)
            or len(pair) != 2
            or not all(isinstance(n, int) and not isinstance(n, bool) for n in pair)
        ):
            return f"size entry {label} must be [w, h] integers"
    return None


def collect_pngs(root: Path) -> list[Path]:
    found: list[Path] = []
    for folder in ASSET_ROOTS:
        base = root / folder
        if not base.is_dir():
            continue
        for png in base.rglob("*.png"):
            if png.with_name(png.name + ".import").is_file():
                found.append(png)
    return found


def scene_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for pattern in ("*.tscn", "*.tres"):
        for path in root.rglob(pattern):
            rel = path.relative_to(root).as_posix()
            if rel.startswith(".godot/") or "/.godot/" in rel:
                continue
            files.append(path)
    return files


def add_failure(failures: list[dict], seen: set[tuple[str, str]], path: str, reason: str) -> None:
    key = (path, reason)
    if key in seen:
        return
    seen.add(key)
    failures.append({"path": path, "reason": reason})


def run_checks(root: Path, only: str | None) -> tuple[int, list[dict]]:
    failures: list[dict] = []
    seen: set[tuple[str, str]] = set()
    checked: set[str] = set()

    project_path = root / "project.godot"
    project_reason = None
    if project_path.is_file():
        project_reason = project_default_is_linear(project_path.read_text(encoding="utf-8"))
    else:
        project_reason = "project.godot is missing"
    if project_reason:
        add_failure(failures, seen, "project.godot", project_reason)

    pngs = collect_pngs(root)
    selected_pngs = [png for png in pngs if path_selected(posix_rel(png, root), only)]
    linear_by_png: dict[str, list[str]] = {}
    for scene in scene_files(root):
        rel_scene = posix_rel(scene, root)
        try:
            text = scene.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            text = scene.read_text(encoding="utf-8", errors="replace")
        for asset, reason in scene_linear_hits(text):
            if asset and not path_selected(asset, only):
                continue
            if asset and not under_asset_roots(asset):
                continue
            target = asset or rel_scene
            linear_by_png.setdefault(target, []).append(f"{rel_scene}: {reason}")

    for png in selected_pngs:
        rel = posix_rel(png, root)
        checked.add(rel)
        import_path = png.with_name(png.name + ".import")
        try:
            text = import_path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            text = import_path.read_text(encoding="utf-8", errors="replace")
        for reason in import_problems(text):
            add_failure(failures, seen, rel, reason)
        for reason in linear_by_png.get(rel, []):
            add_failure(failures, seen, rel, reason)

    for target, reasons in linear_by_png.items():
        if target in checked:
            continue
        for reason in reasons:
            add_failure(failures, seen, target, reason)

    sizes_dir = root / "design" / "visual" / "sizes"
    if sizes_dir.is_dir():
        for size_file in sorted(sizes_dir.glob("*.sizes.json")):
            rel_list = posix_rel(size_file, root)
            entries, error = load_size_entries(size_file)
            if error:
                add_failure(failures, seen, rel_list, error)
                continue
            for index, entry in enumerate(entries):
                problem = entry_error(entry)
                if problem:
                    add_failure(failures, seen, rel_list, f"entry {index}: {problem}")
                    continue
                rel = normalize_asset_path(entry["path"])
                if not path_selected(rel, only):
                    continue
                checked.add(rel)
                png = root / rel
                if not png.is_file():
                    add_failure(failures, seen, rel, f"size list {rel_list} names a missing PNG")
                    continue
                try:
                    width, height = png_ihdr(png)
                except ValueError as exc:
                    add_failure(failures, seen, rel, f"could not read IHDR ({exc})")
                    continue
                shipped = entry["shipped"]
                if [width, height] != shipped:
                    add_failure(
                        failures,
                        seen,
                        rel,
                        f"IHDR {width}x{height} != shipped {shipped[0]}x{shipped[1]} in {rel_list}",
                    )
    failures.sort(key=lambda item: (item["path"], item["reason"]))
    return len(checked), failures


def write_report(root: Path, checked: int, failures: list[dict]) -> Path:
    out = root / "design" / "audit-shots" / "cursor" / "png_check.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "updated": datetime.now().astimezone().isoformat(timespec="seconds"),
        "checked": checked,
        "failures": failures,
    }
    out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return out


def print_summary(checked: int, failures: list[dict], out: Path, root: Path) -> None:
    print(f"checked {checked}")
    print(f"failures {len(failures)}")
    for item in failures[:20]:
        print(f"  {item['path']}: {item['reason']}")
    if len(failures) > 20:
        print(f"  ... {len(failures) - 20} more")
    print(f"wrote {out.relative_to(root).as_posix()}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--only",
        metavar="GLOB",
        help="Check only repo-relative paths matching this glob (forward slashes).",
    )
    args = parser.parse_args(argv)
    root = repo_root()
    checked, failures = run_checks(root, args.only)
    out = write_report(root, checked, failures)
    print_summary(checked, failures, out, root)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
