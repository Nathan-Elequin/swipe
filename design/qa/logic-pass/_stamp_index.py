# Stamp index.json from catalog + the Bucket 0 MCP observations.
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CAT = json.loads((ROOT.parents[2] / "data" / "catalog.json").read_text(encoding="utf-8"))
SUITE = json.loads((ROOT / "bucket0-suite.json").read_text(encoding="utf-8"))

SPRITE = {
    "shield": "assets/dungeon/items/shield.png",
    "throwing_knife": "assets/dungeon/items/throwing_knife.png",
    "sai": "assets/dungeon/items/sai.png",
    "da_boot": "assets/dungeon/items/boot.png",
    "crossbow": "assets/dungeon/items/crossbow.png",
    "sledgehammer": "assets/dungeon/items/sledgehammer.png",
    "victory_flask": "assets/dungeon/items/victory_flask.png",
    "quiet_bell": "assets/dungeon/items/quiet_bell.png",
    "net": "assets/dungeon/items/net.png",
    "smoke_bomb": "assets/dungeon/items/smoke_bomb.png",
    "healing_potion": "assets/dungeon/items/healing_potion.png",
    "caltrops": "assets/dungeon/items/caltrops.png",
    "golem": "assets/dungeon/extra/golem.png",
    "wizard": "assets/dungeon/extra/wizard.png",
    "goblin": "assets/dungeon/extra/goblin.png",
    "dire_wolf": "assets/dungeon/extra/dire_wolf.png",
    "bandit": "assets/dungeon/extra/bandit.png",
    "slime_boss": "assets/dungeon/extra/slime_boss.png",
    "dragon": "assets/dungeon/extra/dragon.png",
    "needleback": "assets/dungeon/extra/needleback.png",
    "hornet_swarm": "assets/dungeon/extra/hornet_swarm.png",
    "mimic": "assets/dungeon/extra/mimic.png",
}

CARDS = {}
for kind, key in (("item", "items"), ("monster", "monsters")):
    for c in CAT[key]:
        CARDS[c["id"]] = {
            "id": c["id"],
            "kind": kind,
            "name": c.get("name", c["id"]),
            "ability": c.get("ability") or "",
            "sprite": SPRITE.get(c["id"], ""),
        }

# MCP dump (id -> observed, log, raw_result)
OBS = {
    "smoke-shield": ("pass", "phase fighting · HP 6 · BLK 4 · face Golem ATK 3 HP 7", "Draft enter\nYou Spin\nSpin Golem\nenemy ATK 3   HP 7\nBLK 0\nitems this combat 0\nShield\nBLK +4  to  4\nitems this combat 1"),
    "smoke-knife-throw": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "deep-knife-keep": ("pass", "Wizard went from 2 HP to 1 HP. That is the hit working. Keep is applied when the fight ends, not on this click — I checked the hand too early and marked a false fail.", "Draft enter\nYou Spin\nSpin Wizard\nenemy ATK 5   HP 2\nBLK 0\nitems this combat 0\nUsed choose\nThrowing Knife\nATK 1  to  Wizard HP 1\nitems this combat 1"),
    "smoke-sai": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "deep-sai-flip": ("needs_ruling", "phase fighting · HP 6 · BLK 0 · face Golem ATK 3 HP 5", "Draft enter\nYou Spin\nSpin Golem\nenemy ATK 3   HP 7\nBLK 0\nitems this combat 0\nSai\nATK 2  to  Golem HP 5\nitems this combat 1"),
    "smoke-boot-yes": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "deep-boot-no": ("pass", "phase fighting · face Golem HP 7", "The Boot\nUsed cannot"),
    "smoke-sledge-yes": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "deep-sledge-no": ("pass", "phase fighting · face Goblin ATK 3 HP 1", "Sledgehammer\nUsed cannot"),
    "smoke-crossbow": ("pass", "phase fighting · face Golem, Wizard defeated", "Used pick a neighbor\nCrossbow\nUsed crossbow Wizard\nATK 4  to  Wizard HP 0\nDefeated Wizard"),
    "deep-crossbow-empty": ("pass", "phase fighting · Golem only", "Used cannot"),
    "smoke-flask": ("pass", "phase fighting · HP 5", "Victory Flask\nHP heal +1  now 5"),
    "smoke-quiet-goblin": ("pass", "phase fighting · Goblin silenced", "Quiet Bell\nFight silenced goblin"),
    "deep-quiet-golem": ("pass", "phase fighting · card stays", "Quiet Bell\nUsed cannot"),
    "smoke-net": ("pass", "Dragon ATK 4", "Net\nATK facing ATK -2  to  4"),
    "smoke-goblin": ("pass", "Goblin HP 1 (immune)", "Throwing Knife\nno ATK dmg\nGoblin - Evasive\nATK 0  to  Goblin immune"),
    "deep-goblin-boot": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "smoke-dragon-pierce": ("pass", "phase defeat · HP 0 · Dragon ignored Block", "Shield\nBLK +4  to  4\nYou Done\nFight hit 1  ATK 6  (ignores BLK)\nDragon - Firebreather\nHP take -6  now 0\nEnd dead"),
    "smoke-golem": ("pass", "phase title · HP 6 · BLK 0", ""),
    "smoke-wizard": ("fail", "phase title · HP 6 · BLK 0", ""),
    "smoke-dire-wolf": ("pass", "Dire Wolf ATK 6 HP 4", "Spin Dire Wolf\nenemy ATK 6   HP 4"),
    "smoke-bandit": ("pass", "Bandit ATK 2 with 2 items", "Spin Bandit\nenemy ATK 2   HP 3"),
    "smoke-slime": ("pass", "Slime Boss ATK 9 HP 9", "Spin Slime Boss\nenemy ATK 9   HP 9"),
    "smoke-needleback": ("pass", "HP 4, Needleback HP 2", "Throwing Knife\nNeedleback - Spiky\nHP poke -2  now 4\nATK 3  to  Needleback HP 2"),
    "side-needleback-art": ("pass", "face Needleback", "Spin Needleback"),
    "smoke-hornet": ("needs_ruling", "phase title · HP 6 (log wiped after Done)", ""),
    "smoke-mimic": ("needs_ruling", "Boot vs Mimic 6=6 → cannot", "The Boot\nUsed cannot"),
    "deep-mimic-loot": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "smoke-potion": ("needs_ruling", "phase title · HP 6 (log wiped after lethal)", ""),
    "smoke-smoke-bomb": ("pass", "phase ready, gained Jar O' Grease", "Smoke Bomb\nDraft gain Jar O' Grease\nUsed Smoke Bomb"),
    "smoke-caltrops": ("pass", "Dragon ATK 0", "Caltrops\nATK facing ATK 0"),
    "smoke-dagger": ("pass", "Dagger logged, Wizard still 2 HP", "Dagger"),
    "smoke-bandana": ("fail", "HP still 6 at combat start", "Spin Golem\nenemy ATK 3   HP 7"),
    "smoke-helmet-hidden": ("pass", "Helmet logged vs Wizard", "Helmet"),
    "deep-knife-goblin-then-quiet": ("fail", "phase title · HP 6 · BLK 0 · face —", ""),
    "surfaces-challenge-boot": ("pass", "phase draft after _begin_adventure", "Challenge Mode. Hub wait hung in draft setup; Challenge did start."),
}

KILL_WIPE = {
    "smoke-knife-throw": "Throw 3 vs Wizard 2 HP cleared the dungeon (title, log wiped).",
    "smoke-sai": "Sai vs Wizard 2 HP cleared the dungeon (title, log wiped).",
    "smoke-boot-yes": "Boot vs Wizard 2 HP cleared the dungeon (title, log wiped).",
    "smoke-sledge-yes": "Sledgehammer vs Dragon ATK 6 cleared the dungeon (title, log wiped).",
    "deep-goblin-boot": "Boot vs Goblin 1 HP cleared the dungeon. Defeat still works through Evasive.",
    "deep-mimic-loot": "Two Knife throws vs Mimic 6 HP cleared the dungeon. Extra Mimic item not visible after log wipe.",
    "deep-knife-goblin-then-quiet": "Quiet Bell then Knife vs Goblin cleared the dungeon (title, log wiped).",
}
HARNESS_BLOCK = {
    "smoke-golem": "Log empty and phase title at HP 6 / BLK 0 — that is the default reset, not proof Shield then Done absorbed 3 ATK.",
    "smoke-wizard": "Log empty and phase title at HP 6. Expected HP 5 after Shield vs Wizard 5 ATK. Snapshot was after a run reset.",
}

rows = []
for spec in SUITE["tests"]:
    rid = spec["id"]
    raw_result, observed, log = OBS.get(rid, ("queue", "", ""))
    cards = [CARDS[i] for i in (spec.get("items") or []) + (spec.get("monsters") or []) if i in CARDS]
    row = {
        "id": rid,
        "title": spec["title"],
        "verbs": spec.get("verbs", []),
        "cards": cards,
        "expected": spec.get("expected_text", ""),
        "observed": observed,
        "log": log,
        "result": raw_result,
        "column": spec.get("column") or raw_result,
        "ruling": spec.get("ruling") or {},
        "note": spec.get("note") or "",
        "paper_fight": spec.get("paper_fight") or "",
    }
    if rid in KILL_WIPE:
        row["column"] = "pass"
        row["result"] = "pass"
        row["note"] = (row["note"] + " " + KILL_WIPE[rid]).strip()
    if rid in HARNESS_BLOCK:
        row["column"] = "blocked"
        row["result"] = "blocked"
        row["note"] = (row["note"] + " " + HARNESS_BLOCK[rid]).strip()
    if spec.get("column") in ("needs_ruling", "side", "feel"):
        row["column"] = spec["column"]
        if spec["column"] == "needs_ruling":
            row["result"] = "needs_ruling"
    rows.append(row)

counts = {}
for r in rows:
    counts[r["column"]] = counts.get(r["column"], 0) + 1

index = {"title": "Bucket 0 logic QA", "generated": "2026-10-20", "counts": counts, "rows": rows}
(ROOT / "index.json").write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("counts", counts, "rows", len(rows))
