#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def show(ref: str, path: str) -> dict:
    raw = subprocess.check_output(
        ["git", "show", f"{ref}:{path}"], cwd=ROOT, encoding="utf-8", errors="replace"
    )
    return json.loads(raw)


def walk(d, p=""):
    out = {}
    if isinstance(d, dict):
        for k, v in d.items():
            np = f"{p}.{k}" if p else str(k)
            out.update(walk(v, np))
    elif isinstance(d, list):
        for i, v in enumerate(d):
            out.update(walk(v, f"{p}[{i}]"))
    else:
        out[p] = d
    return out


def main() -> None:
    tip = walk(show("origin/playtest/latest", "data/player-copy.json"))
    mov = walk(show("origin/movement", "data/player-copy.json"))
    keys = sorted(set(tip) | set(mov))
    only_m = [k for k in keys if k in mov and k not in tip]
    only_t = [k for k in keys if k in tip and k not in mov]
    differ = [k for k in keys if k in tip and k in mov and tip[k] != mov[k]]
    interesting = [
        k
        for k in only_m + differ
        if any(s in k.lower() for s in ("move", "how_to", "howto", "adventure", "gate", "long"))
    ]
    lines = [
        f"tip keys={len(tip)} movement keys={len(mov)}",
        f"only on movement={len(only_m)} only on tip={len(only_t)} value-differ={len(differ)}",
        "",
        "=== movement keys/values tip lacks or differs (move/adventure/how-to related) ===",
    ]
    for k in interesting:
        if k in mov and k not in tip:
            lines.append(f"ONLY-MOV {k} = {mov[k]!r}")
        elif k in tip and k in mov:
            lines.append(f"DIFFER {k}")
            lines.append(f"  tip: {tip[k]!r}")
            lines.append(f"  mov: {mov[k]!r}")
    lines.append("")
    lines.append("=== ALL keys only on movement (first 80) ===")
    for k in only_m[:80]:
        v = str(mov[k]).replace("\n", " ")[:120]
        lines.append(f"  {k} = {v!r}")
    Path(__file__).with_name("_move_copy_diff.txt").write_text("\n".join(lines), encoding="utf-8")
    print("wrote _move_copy_diff.txt", "only_m", len(only_m), "interesting", len(interesting))


if __name__ == "__main__":
    main()
