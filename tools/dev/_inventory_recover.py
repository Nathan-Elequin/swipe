#!/usr/bin/env python3
"""One-shot inventory for playtest/latest recovery. Writes UTF-8 outfile."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TIP = "origin/playtest/latest"
OUT = ROOT / "tools/dev/_inventory_recover.out.txt"


def run(args: list[str], check: bool = True) -> str:
    r = subprocess.run(
        args,
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if check and r.returncode != 0:
        sys.stderr.write(f"CMD FAIL {args}\n{r.stderr}\n")
        raise SystemExit(r.returncode)
    return r.stdout


def main() -> None:
    buf: list[str] = []

    def emit(line: str = "") -> None:
        buf.append(line)

    emit("=== TIP ===")
    emit(run(["git", "log", "-1", "--oneline", TIP]).strip())

    emit()
    emit("=== CATALOG vs CONTENT-BOARD ===")
    catalog = json.loads((ROOT / "data/catalog.json").read_text(encoding="utf-8"))
    board = json.loads((ROOT / "data/content-board.json").read_text(encoding="utf-8"))

    def from_list(rows, kind: str) -> dict:
        out = {}
        for c in rows or []:
            if isinstance(c, dict) and c.get("id"):
                cid = c["id"]
                key = cid if ":" in cid else f"{kind}:{cid}"
                out[key] = c
        return out

    cat_n = {}
    cat_n.update(from_list(catalog.get("items"), "item"))
    cat_n.update(from_list(catalog.get("monsters"), "monster"))
    brd_n = {}
    brd_n.update(from_list(board.get("items"), "item"))
    brd_n.update(from_list(board.get("monsters"), "monster"))

    def g(d, *keys):
        for k in keys:
            if k in d and d[k] not in (None, ""):
                v = d[k]
                if isinstance(v, dict) and "base" in v:
                    return v.get("base")
                return v
        return ""

    def hp_atk(d):
        hp = g(d, "hp", "hp_base")
        atk = g(d, "atk", "atk_base")
        if isinstance(d.get("hp"), dict):
            hp = d["hp"].get("base")
        if isinstance(d.get("atk"), dict):
            atk = d["atk"].get("base")
        return hp, atk

    diffs = []
    for k in sorted(set(cat_n) | set(brd_n)):
        c = cat_n.get(k) or {}
        b = brd_n.get(k) or {}
        if not c or not b:
            continue
        fields = []
        for fname in ("call_name", "ability", "name", "explainer", "reminder"):
            cv, bv = g(c, fname), g(b, fname)
            if str(cv).strip() != str(bv).strip():
                fields.append((fname, cv, bv))
        chp, catk = hp_atk(c)
        bhp, batk = hp_atk(b)
        if str(chp) != str(bhp):
            fields.append(("hp", chp, bhp))
        if str(catk) != str(batk):
            fields.append(("atk", catk, batk))
        if fields:
            diffs.append((k, fields))
    emit(f"catalog={len(cat_n)} board={len(brd_n)} disagree={len(diffs)}")
    for k, fields in diffs:
        emit(f"  {k}")
        for fname, cv, bv in fields:
            cs = str(cv).replace("\n", " ")[:100]
            bs = str(bv).replace("\n", " ")[:100]
            emit(f"    {fname}: catalog={cs!r}")
            emit(f"             board={bs!r}")

    emit()
    emit("=== UNIQUE COMMITS ON AHEAD BRANCHES (git cherry +) ===")
    refs = run(["git", "for-each-ref", "--format=%(refname:short)", "refs/remotes/origin"]).splitlines()
    for ref in refs:
        if ref in ("origin", "origin/HEAD", "origin/playtest/latest"):
            continue
        ahead = int(run(["git", "rev-list", "--count", f"{TIP}..{ref}"]).strip() or "0")
        if ahead == 0:
            continue
        cherry = run(["git", "cherry", TIP, ref], check=False)
        plus = [ln[2:] for ln in cherry.splitlines() if ln.startswith("+ ")]
        minus = [ln[2:] for ln in cherry.splitlines() if ln.startswith("- ")]
        if not plus:
            continue
        emit(f"\n{ref} ahead={ahead} UNIQUE={len(plus)} already-eq={len(minus)}")
        for sha in plus[:20]:
            subj = run(["git", "log", "-1", "--format=%h %s", sha]).strip()
            emit(f"  + {subj}")
        if len(plus) > 20:
            emit(f"  ... +{len(plus)-20} more")

    emit()
    emit("=== STASHES ===")
    emit(run(["git", "stash", "list"]) or "(none)")

    emit()
    emit("=== LOCAL DIRT ===")
    emit(run(["git", "status", "-sb"]))

    OUT.write_text("\n".join(buf) + "\n", encoding="utf-8")
    print(f"wrote {OUT} lines={len(buf)}")


if __name__ == "__main__":
    main()
