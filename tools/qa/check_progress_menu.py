#!/usr/bin/env python3
"""SOURCE-ONLY checks for post-run progress menu + Spin postrun.* copy.

Does NOT prove runtime presentation or live cabin FX.
For engine protocol tests when Godot is present:
  ./tools/qa/run_progress_menu.sh

Exit 0 on pass. Prints PROGRESS_MENU_OK / FAIL.
"""
from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FAILS: list[str] = []
PASSES: list[str] = []


def ok(name: str, cond: bool, detail: str = "") -> None:
    if cond:
        PASSES.append(name)
        print(f"PASS  {name}" + (f"  ({detail})" if detail else ""))
    else:
        FAILS.append(name)
        print(f"FAIL  {name}" + (f"  ({detail})" if detail else ""))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


EXPECTED = {
    "postrun.title": "Run Results",
    "postrun.tab.overview": "Overview",
    "postrun.tab.collection": "Collection",
    "postrun.tab.next_target": "Next Goal",
    "postrun.skip": "Skip Recap",
    "postrun.next": "Next",
    "postrun.cabin": "Visit Cabin",
    "postrun.new_run": "New Run",
    "postrun.summary.success_new": "New item types added: {count}.",
    "postrun.summary.success_none": "Made it home. No new item types added.",
    "postrun.summary.death": "Run ended in {area}. No collection progress from this return.",
    "postrun.summary.tutorial": (
        "Tutorial complete. Tutorial items don't count toward collection progress."
    ),
    "postrun.collection.area_count": "{area} collection: {count}/{total}",
    "postrun.collection.item_missing": "Not yet collected",
    "postrun.collection.item_new": "New!",
    "postrun.collection.area_locked": "Locked",
    "postrun.requirement.bring_home": (
        "Bring home {required} different item types from {area} to unlock {destination}."
    ),
    "postrun.requirement.verdant": (
        "Bring home 5 different item types from successful Verdant Hollow runs "
        "to open the way deeper. They don't all have to come home together."
    ),
    "postrun.requirement.met": "{destination} unlocked",
    "postrun.next_target.prompt": "Next goal: {destination}",
    "postrun.next_target.progress": "Progress: {count}/{required} different item types",
    "postrun.destination.route": (
        "Reach {destination} by starting in {start_area} and continuing during the same run."
    ),
    "postrun.shortcut.requirement": (
        "Unlock {required_area} to start new runs in {start_area}."
    ),
    "postrun.shortcut.unlocked": "New starting point: {start_area}",
    "postrun.button.start_at": "Start New Run in {start_area}",
    "postrun.button.start_default": "Start New Run",
    "postrun.hand_note": "Each new run starts with 6 random items from unlocked pools.",
}


def main() -> int:
    print("KIND source-only (Godot runtime not invoked by this script)")
    copy = json.loads(read("data/player-copy.json"))
    keys = {row["key"]: row.get("text", "") for row in copy.get("rows", []) if "key" in row}

    for k, text in EXPECTED.items():
        ok(f"copy.{k}", keys.get(k) == text, f"got={keys.get(k)!r}")

    # CSV twin must match JSON (no stale import drift).
    csv_path = ROOT / "data/player-copy.csv"
    with csv_path.open(encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.reader(fh))
    header = rows[0]
    ki = header.index("key")
    ti = header.index("text")
    csv_keys = {
        r[ki]: r[ti]
        for r in rows[1:]
        if len(r) > max(ki, ti) and r[ki].startswith("postrun.")
    }
    for k, text in EXPECTED.items():
        ok(f"csv.{k}", csv_keys.get(k) == text, f"got={csv_keys.get(k)!r}")
    ok("copy.postrun_count_27", len([k for k in keys if k.startswith("postrun.")]) == 27)
    ok("csv.postrun_count_27", len(csv_keys) == 27)

    menu = read("scripts/ui/progress_menu.gd")
    main_gd = read("scripts/main.gd")
    cabin = read("scripts/home_cabin.gd")
    shell = read("scripts/campaign_shell.gd")

    ok("menu.script_exists", "extends CanvasLayer" in menu and "postrun.title" in menu)
    ok("menu.uses_player_copy", "PLAYER_COPY" in menu and "postrun." in menu)
    ok("menu.can_start_gate", "CAMPAIGN_SHELL.can_start" in menu)
    ok("menu.no_continue_run_button", "continue_run" not in menu.lower())
    ok("menu.route_not_button", "postrun.destination.route" in menu)
    ok("menu.hand_note_gated", "starter_item_mix" in menu and "hand_note omitted" in menu)
    ok("menu.no_all_goals_complete_invent", "all-goals-complete" in menu or "all_goals" not in menu.lower())
    ok("menu.await_closed", "await closed" in menu)
    ok("menu.skip_acks", "_ack_all_new" in menu and "_on_skip" in menu)
    ok("menu.stagger", "STAGGER_S" in menu)

    ok("main.progress_menu_const", "PROGRESS_MENU" in main_gd)
    ok("main.open_helper", "func _open_progress_menu" in main_gd)
    for kind in ("win", "loss", "tutorial"):
        ok(
            f"main.routes_{kind}",
            f'_open_progress_menu("{kind}"' in main_gd,
        )
    ok(
        "main.push_block_flag",
        re.search(r'_open_progress_menu\("win".*true', main_gd, re.S) is not None
        or '_open_progress_menu("win", news, ids, true' in main_gd,
    )
    ok(
        "main.tutorial_zero_credit",
        '_open_progress_menu("tutorial", [], [], false)' in main_gd,
    )
    ok(
        "main.no_auto_s7_on_leave",
        '_open_home_cabin(true, "win"' not in main_gd
        or main_gd.count('_open_progress_menu("win"') >= 2,
    )
    ok(
        "main.quiet_stamp_on_leave",
        '_campaign_bank_from_hand(true)' in main_gd
        and "stamp_map_piece" in main_gd
        and '_campaign_bank_from_hand(false)' in main_gd,
        "leave stamps crosses; push-block does not",
    )

    ok("cabin.progress_menu_meta_gate", "progress_menu_handled_return" in cabin)
    ok("cabin.resume_respects_meta", "_resume_pending_bank_if_idle" in cabin and "progress_menu_handled_return" in cabin)

    ok("shell.starter_mix_default", 'starter_item_mix", [3, 2, 1]' in shell or "starter_item_mix\", [3, 2, 1]" in shell)
    ok("shell.can_start_exists", "static func can_start" in shell)
    ok("shell.shortcut_open_exists", "static func shortcut_open" in shell)

    screen = ROOT / "design/visual/SCREEN-progress-menu.md"
    req = ROOT / "playtest/repot/inbox/REQ-20261108-progress-menu.md"
    ok("docs.screen", screen.is_file())
    ok("docs.req", req.is_file())

    old = read("playtest/repot/inbox/REQ-20261107-cabinet-homecoming-restore.md")
    ok("docs.old_superseded", "status: superseded" in old and "REQ-20261108-progress-menu" in old)

    print(f"\n{len(PASSES)} passed, {len(FAILS)} failed")
    if FAILS:
        print("PROGRESS_MENU_FAIL")
        return 1
    print("PROGRESS_MENU_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
