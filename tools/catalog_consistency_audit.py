#!/usr/bin/env python3
"""Catalog consistency swarm — truth matrix + optional safe auto-fixes.

Reads catalog.json (items+monsters), dungeon_art.gd ITEM_PNG/MONSTER_PNG,
data/sfx-map.json, and data/player-copy.json. Writes markdown + CSV reports
under docs/catalog-audit/ (and a twin under playtest/catalog-audit/).

Usage:
  python3 tools/catalog_consistency_audit.py            # report only
  python3 tools/catalog_consistency_audit.py --fix     # apply safe mechanical fixes, then report

Safe --fix actions (no art generation, no design tier changes, no mass deletes):
  - Set flags.art=true on live catalog (+ content-board) cards that already have a
    registered PNG path whose file exists on disk.
  - Add sfx-map lookup.card_id ability/use entries for live cards when the matching
    mon.ability.<id> / item.use.<id> cue already exists.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "data" / "catalog.json"
BOARD_PATH = ROOT / "data" / "content-board.json"
SFX_PATH = ROOT / "data" / "sfx-map.json"
COPY_PATH = ROOT / "data" / "player-copy.json"
ART_GD = ROOT / "scripts" / "dungeon_art.gd"
DOCS_OUT = ROOT / "docs" / "catalog-audit"
PLAYTEST_OUT = ROOT / "playtest" / "catalog-audit"

# Known dynamic / format-string player-copy prefixes (not dead just because
# the exact key string never appears as a literal in .gd).
DYNAMIC_COPY_PREFIXES = (
    "tutorial.line.",
    "tutorial.beat.",
    "defeat.journal.",
    "defeat.spotlight.",
    "cabin.hall.ordinal_",
    "cabin.tip.",
    "keyword.",
    "intent.",
    "biome.",
    "log.hover.",
)

# Intentional SFX map aliases / ops-kind keys that are not catalog card ids.
KNOWN_SFX_ALIAS_IDS = {
    "chaos_stone",
    "magnet",
    "hook",
}

# cues.py HOLD note: skip dedicated ability oneshots for these until issues land.
SFX_ABILITY_HOLD = {
    "golem": "no named ability oneshot (cues.py HOLD)",
    "wizard": "no named ability oneshot (cues.py HOLD)",
    "leech_league": "HOLD until #347 Blood Rise / slash portrait",
}

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4}


@dataclass
class Gap:
    severity: str
    kind: str
    subject: str
    detail: str
    todo: str = ""
    auto_fixable: bool = False
    fixed: bool = False

    def row(self) -> dict[str, Any]:
        d = asdict(self)
        return d


def _git_tip() -> str:
    try:
        return (
            subprocess.check_output(
                ["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, text=True
            ).strip()
        )
    except Exception:
        return "unknown"


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _dump_json(path: Path, data: Any) -> None:
    path.write_text(
        json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8"
    )


def _parse_gd_string_dict(const_name: str) -> dict[str, str]:
    text = ART_GD.read_text(encoding="utf-8")
    m = re.search(rf"const {const_name} := \{{(.*?)\n\}}", text, re.S)
    if not m:
        return {}
    return {
        k: v for k, v in re.findall(r'"([^"]+)"\s*:\s*"([^"]+)"', m.group(1))
    }


def _res_to_path(res: str) -> Path:
    if res.startswith("res://"):
        return ROOT / res[len("res://") :]
    return ROOT / res


def _pool_of(card: dict) -> float:
    try:
        return float(card.get("pool", 0) or 0)
    except (TypeError, ValueError):
        return 0.0


def _tier_of(card: dict) -> float:
    try:
        return float(card.get("tier", 0) or 0)
    except (TypeError, ValueError):
        return 0.0


def _is_token(card: dict) -> bool:
    return _pool_of(card) < 0


def _art_flag(card: dict) -> bool:
    flags = card.get("flags") or {}
    return bool(flags.get("art"))


def _set_art_flag(card: dict, value: bool) -> bool:
    """Flip flags.art only. Preserve existing hide/dev; do not invent them."""
    flags = dict(card.get("flags") or {})
    before = bool(flags.get("art"))
    if before == value and card.get("flags") is not None:
        return False
    flags["art"] = value
    card["flags"] = flags
    return before != value


def _collect_copy_literals() -> set[str]:
    used: set[str] = set()
    pats = [
        re.compile(
            r'(?:COPY|PLAYER_COPY|KIT)\.(?:text|fill|has_key|set_copy|copy_text)\(\s*"([^"]+)"'
        ),
        re.compile(r'copy_key\s*=\s*"([^"]+)"'),
        re.compile(r'\.set_copy\(\s*"([^"]+)"'),
        re.compile(r'copy_key:\s*"([^"]+)"'),
    ]
    roots = [ROOT / "scripts", ROOT / "scenes", ROOT / "design"]
    for base in roots:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.suffix not in {".gd", ".tscn", ".html", ".js", ".md", ".json"}:
                continue
            try:
                text = path.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            for pat in pats:
                used.update(pat.findall(text))
            # format-string patterns like "cabin.hall.ordinal_%d"
            for m in re.finditer(r'"([a-z0-9_.]+%[^"]*)"', text):
                used.add(m.group(1))
    return used


def _copy_key_is_referenced(key: str, literals: set[str]) -> bool:
    if key in literals:
        return True
    for lit in literals:
        if "%" in lit:
            # crude: tutorial.beat.%s.body style — treat prefix before % as dynamic
            prefix = lit.split("%", 1)[0]
            if key.startswith(prefix):
                return True
    for prefix in DYNAMIC_COPY_PREFIXES:
        if key.startswith(prefix):
            return True
    return False


def audit(fix: bool = False) -> tuple[list[Gap], dict[str, Any]]:
    catalog = _load_json(CATALOG_PATH)
    board = _load_json(BOARD_PATH)
    sfx = _load_json(SFX_PATH)
    copy = _load_json(COPY_PATH)

    items = {c["id"]: c for c in catalog.get("items", [])}
    monsters = {c["id"]: c for c in catalog.get("monsters", [])}
    board_items = {c["id"]: c for c in board.get("items", [])}
    board_mons = {c["id"]: c for c in board.get("monsters", [])}

    item_png = _parse_gd_string_dict("ITEM_PNG")
    mon_png = _parse_gd_string_dict("MONSTER_PNG")

    cues: dict = sfx.get("cues") or {}
    card_lookup: dict = (sfx.get("lookup") or {}).get("card_id") or {}

    gaps: list[Gap] = []
    fixes: list[str] = []

    def add(gap: Gap) -> None:
        gaps.append(gap)

    # --- Art matrix ---
    for kind, cards, png_map in (
        ("item", items, item_png),
        ("monster", monsters, mon_png),
    ):
        for cid, card in sorted(cards.items()):
            status = str(card.get("status", ""))
            if status not in {"live", "todo"}:
                continue
            path = png_map.get(cid)
            exists = bool(path and _res_to_path(path).is_file())
            flagged = _art_flag(card)
            live = status == "live"

            if live and not path:
                add(
                    Gap(
                        "high" if live else "medium",
                        "live_missing_art_registry",
                        f"{kind}:{cid}",
                        f"Live {kind} '{card.get('name')}' has no ITEM_PNG/MONSTER_PNG entry; flags.art={flagged}.",
                        todo="Pixel: register unique art (do not invent PNG here).",
                    )
                )
            elif live and path and not exists:
                add(
                    Gap(
                        "critical",
                        "art_path_missing_file",
                        f"{kind}:{cid}",
                        f"Registered path missing on disk: {path}",
                        todo="Pixel: restore PNG or fix path.",
                    )
                )
            elif live and not flagged and exists:
                g = Gap(
                    "medium",
                    "art_flag_false_but_file_exists",
                    f"{kind}:{cid}",
                    f"flags.art=false but registered file exists ({path}).",
                    todo="Auto-fix flips flags.art=true in catalog + board.",
                    auto_fixable=True,
                )
                if fix and _set_art_flag(card, True):
                    g.fixed = True
                    fixes.append(f"flags.art=true catalog {kind}:{cid}")
                    bcard = (board_items if kind == "item" else board_mons).get(cid)
                    if bcard is not None and _set_art_flag(bcard, True):
                        fixes.append(f"flags.art=true board {kind}:{cid}")
                add(g)
            elif live and flagged and not exists and not path:
                add(
                    Gap(
                        "high",
                        "live_missing_art",
                        f"{kind}:{cid}",
                        "Live card claims art but has no registry/file.",
                        todo="Pixel: supply art.",
                    )
                )

    # PNG registry orphans (not in catalog). Alias extras are info.
    ALIAS_OK = {"cats_eye_marble", "bag_of_holding_closed", "marble"}
    for kind, png_map, cards in (
        ("item", item_png, items),
        ("monster", mon_png, monsters),
    ):
        for cid, path in sorted(png_map.items()):
            if cid in cards:
                continue
            sev = "info" if cid in ALIAS_OK else "low"
            add(
                Gap(
                    sev,
                    "art_registry_without_catalog",
                    f"{kind}:{cid}",
                    f"ITEM_PNG/MONSTER_PNG id not in catalog.json ({path}).",
                    todo="Keep if alias/extra; else remove registry entry in a Pixel pass.",
                )
            )

    # Orphan PNGs sitting in items/ / extra/ not referenced by dungeon_art.gd
    art_text = ART_GD.read_text(encoding="utf-8")
    for folder in (ROOT / "assets/dungeon/items", ROOT / "assets/dungeon/extra"):
        if not folder.is_dir():
            continue
        for png in sorted(folder.glob("*.png")):
            rel = str(png.relative_to(ROOT)).replace("\\", "/")
            if rel not in art_text and f"res://{rel}" not in art_text:
                add(
                    Gap(
                        "low",
                        "orphan_png_on_disk",
                        rel,
                        "PNG under items/extra not referenced in dungeon_art.gd.",
                        todo="Pixel: wire or retire file.",
                    )
                )

    # --- Token / tier ---
    for kind, cards in (("item", items), ("monster", monsters)):
        for cid, card in sorted(cards.items()):
            if str(card.get("status")) != "live":
                continue
            if not _is_token(card):
                continue
            tier = _tier_of(card)
            # Tokens should not look like mill T2/T3 for draft triggers.
            if tier >= 2:
                issue = "#358" if cid == "bear_trap" else "design"
                add(
                    Gap(
                        "critical" if cid == "bear_trap" else "high",
                        "token_wrong_tier",
                        f"{kind}:{cid}",
                        f"Token (pool={_pool_of(card)}) is live with tier={tier}; "
                        f"name='{card.get('name')}'. Tokens must not count as mill tier for drafts.",
                        todo=f"Design/code fix — see GitHub {issue}. Do not auto-change tier here.",
                    )
                )
            elif tier not in (0, 1) and kind == "item":
                add(
                    Gap(
                        "medium",
                        "token_tier_odd",
                        f"{kind}:{cid}",
                        f"Token item tier={tier} (pool={_pool_of(card)}).",
                        todo="Confirm Token tier display vs mill rules.",
                    )
                )

    # Code-referenced monster id missing from catalog (regression guard).
    # fungal_colony: combat + SFX live; catalog hold stub added 2026-11-04.
    main_gd = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8", errors="ignore")
    for hard_id in ("fungal_colony",):
        if hard_id in main_gd and hard_id not in monsters and hard_id not in items:
            add(
                Gap(
                    "high",
                    "code_id_missing_catalog",
                    f"monster:{hard_id}",
                    "main.gd references this id but catalog.json has no row.",
                    todo="Add catalog row or retire code path.",
                )
            )

    # --- SFX ---
    for cid, card in sorted(items.items()):
        if str(card.get("status")) != "live":
            continue
        entry = card_lookup.get(cid)
        cue_id = f"item.use.{cid}"
        if not isinstance(entry, dict) or not entry.get("use"):
            if cue_id in cues:
                g = Gap(
                    "medium",
                    "sfx_lookup_hole",
                    f"item:{cid}",
                    f"Live item missing lookup.card_id use, but cue '{cue_id}' exists.",
                    todo="Auto-fix adds lookup use → existing cue.",
                    auto_fixable=True,
                )
                if fix:
                    card_lookup[cid] = dict(entry or {})
                    card_lookup[cid]["use"] = cue_id
                    g.fixed = True
                    fixes.append(f"sfx lookup item:{cid} → {cue_id}")
                add(g)
            else:
                add(
                    Gap(
                        "medium",
                        "sfx_missing_use_cue",
                        f"item:{cid}",
                        "No lookup.use and no item.use.<id> cue.",
                        todo="Reel: add cue + file, then map entry. See also #348 if Recycler feel.",
                    )
                )
        else:
            use = str(entry.get("use"))
            if use and use not in cues:
                add(
                    Gap(
                        "high",
                        "sfx_lookup_broken_target",
                        f"item:{cid}",
                        f"lookup use → '{use}' but cue missing.",
                        todo="Point at an existing cue or add the cue.",
                    )
                )

    for cid, card in sorted(monsters.items()):
        if str(card.get("status")) != "live":
            continue
        entry = card_lookup.get(cid)
        cue_id = f"mon.ability.{cid}"
        hold = SFX_ABILITY_HOLD.get(cid)
        if not isinstance(entry, dict) or not entry.get("ability"):
            if hold:
                add(
                    Gap(
                        "low",
                        "sfx_ability_hold",
                        f"monster:{cid}",
                        f"No ability lookup by design: {hold}.",
                        todo="Leave until HOLD clears; do not invent audio.",
                    )
                )
            elif cue_id in cues:
                g = Gap(
                    "medium",
                    "sfx_lookup_hole",
                    f"monster:{cid}",
                    f"Live monster missing lookup.card_id ability, but cue '{cue_id}' exists.",
                    todo="Auto-fix adds lookup ability → existing cue.",
                    auto_fixable=True,
                )
                if fix:
                    card_lookup[cid] = dict(entry or {})
                    card_lookup[cid]["ability"] = cue_id
                    g.fixed = True
                    fixes.append(f"sfx lookup monster:{cid} → {cue_id}")
                add(g)
            else:
                add(
                    Gap(
                        "medium",
                        "sfx_missing_ability_cue",
                        f"monster:{cid}",
                        "No lookup.ability and no mon.ability.<id> cue/file.",
                        todo="Reel: add ability oneshot when ready.",
                    )
                )
        else:
            ab = str(entry.get("ability"))
            if ab and ab not in cues:
                add(
                    Gap(
                        "high",
                        "sfx_lookup_broken_target",
                        f"monster:{cid}",
                        f"lookup ability → '{ab}' but cue missing.",
                        todo="Point at an existing cue or add the cue.",
                    )
                )

    # Orphan / alias lookup keys
    catalog_ids = set(items) | set(monsters)
    for cid, entry in sorted(card_lookup.items()):
        if cid.startswith("_") or not isinstance(entry, dict):
            continue
        if cid in catalog_ids:
            continue
        if cid in KNOWN_SFX_ALIAS_IDS:
            add(
                Gap(
                    "info",
                    "sfx_lookup_alias",
                    f"lookup:{cid}",
                    "card_id lookup key is an alias/ops/legacy id, not a catalog row.",
                    todo="Keep unless code stops using it.",
                )
            )
        else:
            add(
                Gap(
                    "low",
                    "sfx_lookup_orphan",
                    f"lookup:{cid}",
                    "card_id lookup key not in catalog.",
                    todo="Confirm alias or drop in a Reel pass (no mass-delete here).",
                )
            )

    # Cue file holes
    prefix = str(sfx.get("path_prefix", "res://assets/audio/")).replace("res://", "")
    for cue_id, cue in sorted(cues.items()):
        if not isinstance(cue, dict):
            continue
        for stem in cue.get("files") or []:
            ogg = ROOT / prefix / f"{stem}.ogg"
            wav = ROOT / prefix / f"{stem}.wav"
            if not ogg.is_file() and not wav.is_file():
                add(
                    Gap(
                        "high",
                        "sfx_cue_file_missing",
                        cue_id,
                        f"Cue file missing: {prefix}{stem}.ogg/.wav",
                        todo="Reel: restore asset or retarget cue.",
                    )
                )

    # --- Player-copy ---
    literals = _collect_copy_literals()
    rows = copy.get("rows") or []
    copy_keys = [str(r.get("key", "")) for r in rows if isinstance(r, dict)]
    dead: list[str] = []
    for key in copy_keys:
        if not key:
            continue
        if _copy_key_is_referenced(key, literals):
            continue
        dead.append(key)
        # Per-key rows go to CSV only via a second pass below — keep the
        # human top-20 readable with one summary gap here.
    if dead:
        sample = ", ".join(dead[:8])
        more = f" (+{len(dead) - 8} more)" if len(dead) > 8 else ""
        add(
            Gap(
                "low",
                "player_copy_maybe_dead_summary",
                f"count:{len(dead)}",
                f"No literal/dynamic reference found for {len(dead)} keys. Sample: {sample}{more}.",
                todo="Jam review before delete. Full list in gaps.csv (kind=player_copy_maybe_dead). Do not mass-delete.",
                auto_fixable=False,
            )
        )
        for key in dead:
            add(
                Gap(
                    "low",
                    "player_copy_maybe_dead",
                    key,
                    "No literal/dynamic reference found in scripts/scenes/design.",
                    todo="Jam review before delete. Do not mass-delete.",
                    auto_fixable=False,
                )
            )

    # Board vs catalog id parity
    for kind, a, b in (
        ("item", items, board_items),
        ("monster", monsters, board_mons),
    ):
        only_cat = sorted(set(a) - set(b))
        only_board = sorted(set(b) - set(a))
        for cid in only_cat:
            add(
                Gap(
                    "high",
                    "board_missing_card",
                    f"{kind}:{cid}",
                    "In catalog.json but missing from content-board.json.",
                    todo="Sync board row from catalog.",
                )
            )
        for cid in only_board:
            add(
                Gap(
                    "high",
                    "catalog_missing_card",
                    f"{kind}:{cid}",
                    "In content-board.json but missing from catalog.json.",
                    todo="Sync catalog row from board.",
                )
            )

    if fix:
        sfx_touched = any(f.startswith("sfx lookup ") for f in fixes)
        catalog_touched = any(f.startswith("flags.art=true catalog ") for f in fixes)
        board_touched = any(f.startswith("flags.art=true board ") for f in fixes)
        if catalog_touched:
            _dump_json(CATALOG_PATH, catalog)
        if board_touched:
            _dump_json(BOARD_PATH, board)
        if sfx_touched:
            sfx.setdefault("lookup", {})["card_id"] = card_lookup
            # Match existing sfx-map indent (1 space) — only rewrite when lookup changed.
            SFX_PATH.write_text(
                json.dumps(sfx, indent=1, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )

    meta = {
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "git_tip": _git_tip(),
        "counts": {
            "items": len(items),
            "monsters": len(monsters),
            "item_png": len(item_png),
            "monster_png": len(mon_png),
            "sfx_cues": len(cues),
            "sfx_card_lookup": len(
                [k for k in card_lookup if not str(k).startswith("_")]
            ),
            "player_copy_keys": len(copy_keys),
            "player_copy_maybe_dead": len(dead),
            "gaps": len(gaps),
            "fixed": sum(1 for g in gaps if g.fixed),
        },
        "fixes": fixes,
    }
    return gaps, meta


def _sort_gaps(gaps: list[Gap]) -> list[Gap]:
    return sorted(
        gaps,
        key=lambda g: (SEVERITY_ORDER.get(g.severity, 99), g.kind, g.subject),
    )


def write_reports(gaps: list[Gap], meta: dict[str, Any]) -> tuple[Path, Path]:
    gaps = _sort_gaps(gaps)
    for out_dir in (DOCS_OUT, PLAYTEST_OUT):
        out_dir.mkdir(parents=True, exist_ok=True)

    md_path = DOCS_OUT / "REPORT.md"
    csv_path = DOCS_OUT / "gaps.csv"
    twin_md = PLAYTEST_OUT / "REPORT.md"
    twin_csv = PLAYTEST_OUT / "gaps.csv"

    # Top 20 for humans: skip per-key player_copy noise (summary row stays).
    open_gaps = [
        g
        for g in gaps
        if not g.fixed and g.kind != "player_copy_maybe_dead"
    ]
    top = open_gaps[:20]
    fixed = [g for g in gaps if g.fixed]
    todos = [g for g in gaps if g.todo and not g.fixed]

    lines: list[str] = []
    lines.append("# Catalog consistency audit")
    lines.append("")
    lines.append(f"- Generated: `{meta['generated_at']}`")
    lines.append(f"- Git tip: `{meta['git_tip']}`")
    lines.append(f"- Tool: `tools/catalog_consistency_audit.py`")
    lines.append("")
    lines.append("## Counts")
    lines.append("")
    for k, v in meta["counts"].items():
        lines.append(f"- **{k}** — {v}")
    lines.append("")
    fixes_log = DOCS_OUT / "AUTO-FIXES.md"
    if meta.get("fixes"):
        fix_lines = [
            "# Auto-fixes from catalog_consistency_audit.py",
            "",
            f"- Generated: `{meta['generated_at']}`",
            f"- Git tip at fix time: `{meta['git_tip']}`",
            "",
        ]
        for f in meta["fixes"]:
            fix_lines.append(f"- {f}")
        fix_lines.append("")
        fixes_log.write_text("\n".join(fix_lines), encoding="utf-8")
        (PLAYTEST_OUT / "AUTO-FIXES.md").write_text(
            "\n".join(fix_lines), encoding="utf-8"
        )
    if fixes_log.exists():
        lines.append("## Auto-fixes applied on this branch")
        lines.append("")
        # Skip the AUTO-FIXES heading; embed body bullets.
        body = fixes_log.read_text(encoding="utf-8").splitlines()
        for line in body:
            if line.startswith("#"):
                continue
            if line.startswith("- Generated:") or line.startswith("- Git tip"):
                lines.append(line)
                continue
            if line.startswith("- "):
                lines.append(line)
        lines.append("")
    lines.append("## Top gaps by severity (open)")
    lines.append("")
    if not top:
        lines.append("_No open gaps._")
    else:
        for i, g in enumerate(top, 1):
            lines.append(
                f"{i}. **[{g.severity}]** `{g.kind}` — `{g.subject}`: {g.detail}"
                + (f" _{g.todo}_" if g.todo else "")
            )
    lines.append("")
    lines.append("## TODOs (art / design / Reel — not auto-fixed)")
    lines.append("")
    shown = 0
    for g in todos:
        if g.kind in {
            "live_missing_art_registry",
            "live_missing_art",
            "art_path_missing_file",
            "token_wrong_tier",
            "sfx_missing_use_cue",
            "sfx_missing_ability_cue",
            "sfx_ability_hold",
            "code_id_missing_catalog",
            "orphan_png_on_disk",
        } or g.severity in {"critical", "high"}:
            lines.append(
                f"- **{g.subject}** (`{g.kind}`): {g.todo or g.detail}"
            )
            shown += 1
    if shown == 0:
        lines.append("_None flagged._")
    lines.append("")
    lines.append("## Issue cross-links")
    lines.append("")
    lines.append(
        "- [#358](https://github.com/Nathan-Elequin/swipe/issues/358) — Bear Trap is a Token, not a Tier 2 mill monster (draft skip)."
    )
    lines.append(
        "- [#348](https://github.com/Nathan-Elequin/swipe/issues/348) — Recycler SFX / countdown feel (map cue may already exist; feel still open)."
    )
    lines.append(
        "- [#347](https://github.com/Nathan-Elequin/swipe/issues/347) — Leech League slash / HOLD on ability SFX."
    )
    lines.append("")
    lines.append("## Full gap table")
    lines.append("")
    lines.append("See `gaps.csv` in this folder (and `playtest/catalog-audit/gaps.csv`).")
    lines.append("")
    lines.append("### Kind legend")
    lines.append("")
    lines.append("| kind | meaning |")
    lines.append("|---|---|")
    lines.append("| live_missing_art_registry | Live card not in ITEM_PNG/MONSTER_PNG |")
    lines.append("| art_flag_false_but_file_exists | flags.art false though PNG is wired |")
    lines.append("| art_registry_without_catalog | PNG map id with no catalog row |")
    lines.append("| orphan_png_on_disk | File under items/extra unused by dungeon_art.gd |")
    lines.append("| token_wrong_tier | Token (pool&lt;0) carrying mill tier ≥2 |")
    lines.append("| sfx_lookup_hole | Cue exists; card_id lookup missing |")
    lines.append("| sfx_missing_*_cue | No cue for live card |")
    lines.append("| sfx_ability_hold | Intentional skip (cues.py HOLD) |")
    lines.append("| player_copy_maybe_dead | Key not found via literals/dynamic prefixes |")
    lines.append("| code_id_missing_catalog | Hardcoded id without catalog row |")
    lines.append("")

    text = "\n".join(lines) + "\n"
    md_path.write_text(text, encoding="utf-8")
    twin_md.write_text(text, encoding="utf-8")

    fieldnames = [
        "severity",
        "kind",
        "subject",
        "detail",
        "todo",
        "auto_fixable",
        "fixed",
    ]
    for path in (csv_path, twin_csv):
        with path.open("w", encoding="utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            for g in gaps:
                w.writerow(g.row())

    # Matrix CSV: one row per catalog card
    matrix_path = DOCS_OUT / "truth-matrix.csv"
    twin_matrix = PLAYTEST_OUT / "truth-matrix.csv"
    catalog = _load_json(CATALOG_PATH)
    item_png = _parse_gd_string_dict("ITEM_PNG")
    mon_png = _parse_gd_string_dict("MONSTER_PNG")
    sfx = _load_json(SFX_PATH)
    card_lookup = (sfx.get("lookup") or {}).get("card_id") or {}
    cues = sfx.get("cues") or {}
    rows_m = []
    for kind, cards, png_map, event_key, cue_prefix in (
        ("item", catalog["items"], item_png, "use", "item.use."),
        ("monster", catalog["monsters"], mon_png, "ability", "mon.ability."),
    ):
        for card in cards:
            cid = card["id"]
            path = png_map.get(cid, "")
            entry = card_lookup.get(cid) if isinstance(card_lookup.get(cid), dict) else {}
            cue = f"{cue_prefix}{cid}"
            rows_m.append(
                {
                    "kind": kind,
                    "id": cid,
                    "name": card.get("name", ""),
                    "status": card.get("status", ""),
                    "tier": card.get("tier", ""),
                    "pool": card.get("pool", ""),
                    "is_token": _is_token(card),
                    "flags_art": _art_flag(card),
                    "png_path": path,
                    "png_exists": bool(path and _res_to_path(path).is_file()),
                    "sfx_lookup_event": (entry or {}).get(event_key, ""),
                    "sfx_cue_id": cue,
                    "sfx_cue_exists": cue in cues,
                }
            )
    for path in (matrix_path, twin_matrix):
        with path.open("w", encoding="utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows_m[0].keys()) if rows_m else [])
            w.writeheader()
            w.writerows(rows_m)

    return md_path, csv_path


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--fix",
        action="store_true",
        help="Apply safe mechanical fixes before writing the report",
    )
    args = ap.parse_args()
    gaps, meta = audit(fix=args.fix)
    md, csv_path = write_reports(gaps, meta)
    open_n = sum(1 for g in gaps if not g.fixed)
    print(
        f"catalog_consistency_audit: tip={meta['git_tip']} gaps={len(gaps)} "
        f"open={open_n} fixed={meta['counts']['fixed']} → {md.relative_to(ROOT)} + {csv_path.relative_to(ROOT)}"
    )
    if meta.get("fixes"):
        for f in meta["fixes"]:
            print(f"  fix: {f}")
    # Print top 20 open for PR summary convenience (skip per-key copy noise).
    print("--- top open ---")
    open_gaps = [
        g
        for g in _sort_gaps(gaps)
        if not g.fixed and g.kind != "player_copy_maybe_dead"
    ]
    for i, g in enumerate(open_gaps[:20], 1):
        print(f"{i}. [{g.severity}] {g.kind} {g.subject}: {g.detail}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
