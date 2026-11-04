#!/usr/bin/env python3
"""Offline balance Monte Carlo for Spinheritance.

Usage:
  python3 tools/sim/balance_mc.py
  python3 tools/sim/balance_mc.py --trials 400 --seed 7
  python3 tools/sim/balance_mc.py --out playtest/balance

Reads data/catalog.json. Writes CSV + markdown under playtest/balance/.
Does not modify catalog numbers or combat scripts.
"""

from __future__ import annotations

import argparse
import csv
import json
import random
import statistics
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

# Allow `python3 tools/sim/balance_mc.py` from repo root
sys.path.insert(0, str(Path(__file__).resolve().parent))

from catalog_load import (  # noqa: E402
    REPO_ROOT,
    focus_monsters,
    live_items,
    live_monsters,
    load_catalog,
    player_hp_max,
)
from combat_model import run_duel, run_ladder  # noqa: E402
from loadouts import loadout_label, named_loadouts, random_loadout  # noqa: E402


def pct(x: float) -> str:
    return f"{100.0 * x:.1f}%"


def mean(xs: list[float]) -> float:
    return statistics.fmean(xs) if xs else 0.0


def run_matrix(
    catalog: dict,
    trials: int,
    seed: int,
    random_hands: int,
) -> tuple[list[dict], dict]:
    rng = random.Random(seed)
    hp_max = player_hp_max(catalog)
    monsters = focus_monsters(catalog)
    # Also include every live mill monster (pool >= 1) for breadth heatmap
    mill = [m for m in live_monsters(catalog) if m["pool"] >= 1]
    # Prefer focus first, then rest
    seen = set()
    ordered = []
    for m in monsters + mill:
        if m["id"] not in seen:
            ordered.append(m)
            seen.add(m["id"])

    loadouts = named_loadouts(catalog)
    # Random T1/T2 hands
    for i in range(random_hands):
        hand = random_loadout(catalog, random.Random(seed * 10007 + i), tiers=(1, 2), size=4)
        if len(hand) >= 3:
            loadouts[f"rand_t12_{i:02d}_{loadout_label(hand)}"] = hand

    rows: list[dict] = []
    for lname, specs in loadouts.items():
        for mon in ordered:
            wins = 0
            escapes = 0
            deaths = 0
            hp_left: list[float] = []
            turns: list[float] = []
            for t in range(trials):
                sub = random.Random(seed + hash((lname, mon["id"], t)) % (2**31 - 1))
                st = run_duel(specs, mon, hp_max=hp_max, hp_start=hp_max, rng=sub)
                if st.dead:
                    deaths += 1
                    result = "death"
                elif st.escaped:
                    escapes += 1
                    result = "escape"
                elif st.won:
                    wins += 1
                    result = "win"
                else:
                    result = "other"
                hp_left.append(float(st.player_hp if not st.dead else 0))
                turns.append(float(st.turns))
                rows.append({
                    "loadout": lname,
                    "monster": mon["id"],
                    "monster_tier": mon["tier"],
                    "monster_pool": mon["pool"],
                    "monster_model": mon["model"],
                    "trial": t,
                    "result": result,
                    "win": int(st.won and not st.dead),
                    "hp_left": st.player_hp if not st.dead else 0,
                    "turns": st.turns,
                    "items_used": st.items_used,
                    "seed": seed,
                })
            n = trials
            # aggregate stub stored later
            _ = (wins, escapes, deaths, hp_left, turns, n)
    return rows, {"loadouts": loadouts, "monsters": ordered, "hp_max": hp_max}


def aggregate(rows: list[dict]) -> list[dict]:
    buckets: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for r in rows:
        buckets[(r["loadout"], r["monster"])].append(r)
    out = []
    for (lname, mid), group in sorted(buckets.items()):
        n = len(group)
        wins = sum(1 for r in group if r["result"] == "win")
        deaths = sum(1 for r in group if r["result"] == "death")
        escapes = sum(1 for r in group if r["result"] == "escape")
        hp = [r["hp_left"] for r in group]
        turns = [r["turns"] for r in group]
        out.append({
            "loadout": lname,
            "monster": mid,
            "monster_tier": group[0]["monster_tier"],
            "monster_pool": group[0]["monster_pool"],
            "monster_model": group[0]["monster_model"],
            "n": n,
            "win_rate": wins / n if n else 0.0,
            "death_rate": deaths / n if n else 0.0,
            "escape_rate": escapes / n if n else 0.0,
            "mean_hp_left": mean(hp),
            "mean_turns": mean(turns),
        })
    return out


FOCUS_IDS = {
    "shark", "harpy", "dragon", "golem", "goblin",
    "hornet_swarm", "vampire", "dire_wolf", "slime_boss",
    "ogre", "needleback", "wizard", "bandit", "mimic",
}

# Monsters where a free tank-and-leave win is surprising (special pressure).
PRESSURE_IDS = {
    "shark", "harpy", "dragon", "hornet_swarm", "dire_wolf", "slime_boss", "vampire",
}


def flag_outliers(agg: list[dict]) -> list[dict]:
    """Candidates for human design review — never auto-nerf.

    Named loadouts only. Focus on pressure monsters and true walls.
    Tankable stats-only freebies are expected under one-exchange rules
    (documented in ASSUMPTIONS) and are not listed.
    """
    flags = []
    for row in agg:
        reasons = []
        wr = row["win_rate"]
        dr = row["death_rate"]
        named = not str(row["loadout"]).startswith("rand_")
        if not named:
            continue
        mid = row["monster"]
        focus = mid in FOCUS_IDS
        pressure = mid in PRESSURE_IDS

        if dr >= 0.85 and (focus or row["monster_tier"] <= 2):
            reasons.append("near-unwinnable (death>=85%)")
        if pressure and wr >= 0.98 and row["mean_hp_left"] >= 4.5:
            reasons.append("pressure monster trivialized (wr>=98%, mean HP>=4.5)")
        has_defeat = any(
            tok in row["loadout"]
            for tok in ("fangs", "sledgehammer", "da_boot", "_boot", "boot_")
        )
        if mid == "dragon" and wr >= 0.9 and not has_defeat:
            reasons.append("Dragon beaten without Defeat tools (Net-down ATK or raw kill) — check pierce")
        if mid == "dragon" and "fangs" in row["loadout"] and "potion" not in row["loadout"] and dr >= 0.85:
            reasons.append("Fangs into Dragon pierce is lethal at full HP without potion")
        if mid == "harpy" and dr >= 0.7:
            reasons.append("Harpy Impatient multi-swing deletes this hand")
        if mid == "goblin" and dr >= 0.5:
            reasons.append("Goblin killing the player (usually a Block gap, not ATK immunity)")
        if mid == "dire_wolf" and dr >= 0.85:
            reasons.append("Dire Wolf Kill Shot (ATK=your HP) — need Defeat / kill before Done")
        if reasons:
            flags.append({**row, "reasons": reasons})
    flags.sort(key=lambda r: (-r["death_rate"], -r["win_rate"], r["monster"]))
    return flags


def write_heatmap_csv(agg: list[dict], path: Path) -> None:
    loadouts = sorted({r["loadout"] for r in agg})
    monsters = sorted({r["monster"] for r in agg})
    lookup = {(r["loadout"], r["monster"]): r["win_rate"] for r in agg}
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["loadout"] + monsters)
        for lname in loadouts:
            w.writerow([lname] + [f"{lookup.get((lname, m), float('nan')):.3f}" for m in monsters])


def write_heatmap_md(agg: list[dict], path: Path, focus_ids: set[str]) -> None:
    # Compact markdown table for focus monsters × named (non-rand) loadouts
    named = sorted({r["loadout"] for r in agg if not r["loadout"].startswith("rand_")})
    focus = sorted(focus_ids)
    lookup = {(r["loadout"], r["monster"]): r for r in agg}
    lines = [
        "# Win-rate heatmap (named loadouts × focus monsters)",
        "",
        "Values are win rate over Monte Carlo trials. Escapes count as non-wins.",
        "",
        "| loadout | " + " | ".join(focus) + " |",
        "|---| " + " | ".join("---" for _ in focus) + " |",
    ]
    for lname in named:
        cells = []
        for mid in focus:
            row = lookup.get((lname, mid))
            cells.append(pct(row["win_rate"]) if row else "-")
        short = lname if len(lname) < 42 else lname[:39] + "..."
        lines.append("| `" + short + "` | " + " | ".join(cells) + " |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def coverage_note(catalog: dict) -> tuple[int, int, list[str]]:
    items = live_items(catalog)
    supported = [it for it in items if it["supported"]]
    unsupported = [it["id"] for it in items if not it["supported"]]
    return len(supported), len(items), unsupported


def run_sample_ladders(catalog: dict, seed: int) -> list[dict]:
    """Short Pool-1 ladders for a few named hands."""
    rng = random.Random(seed + 99)
    by_m = {m["id"]: m for m in live_monsters(catalog)}
    ladders = {
        "pool1_mix_a": ["goblin", "golem", "hornet_swarm", "dragon"],
        "pool1_mix_b": ["wizard", "bandit", "ogre", "shark"],
        "focus_gauntlet": ["goblin", "harpy", "shark", "dragon"],
    }
    loadouts = named_loadouts(catalog)
    pick_names = [
        "t1_knife_shield_sai_net",
        "t2_fangs_boot_shield_net",
        "t2_flail_breastplate_knife_shield",
        "cheese_boot_sledge_fangs_smoke",
    ]
    results = []
    for lname in pick_names:
        if lname not in loadouts:
            continue
        for lad_name, ids in ladders.items():
            mons = [by_m[i] for i in ids if i in by_m]
            wins = 0
            n = 80
            died = defaultdict(int)
            hp_ends = []
            for t in range(n):
                sub = random.Random(seed + hash((lname, lad_name, t)) % (2**31 - 1))
                out = run_ladder(loadouts[lname], mons, hp_max=player_hp_max(catalog), rng=sub)
                if out["cleared"]:
                    wins += 1
                if out["died_to"]:
                    died[out["died_to"]] += 1
                hp_ends.append(out["hp_end"])
            results.append({
                "loadout": lname,
                "ladder": lad_name,
                "monsters": ids,
                "n": n,
                "clear_rate": wins / n,
                "mean_hp_end": mean(hp_ends),
                "died_to": dict(died),
            })
            _ = rng  # silence
    return results


def write_report(
    out_dir: Path,
    catalog: dict,
    agg: list[dict],
    flags: list[dict],
    ladders: list[dict],
    trials: int,
    seed: int,
    n_rows: int,
) -> None:
    focus = {m["id"] for m in focus_monsters(catalog)}
    sup, total, unsupported = coverage_note(catalog)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    # Per-focus summary across named loadouts
    focus_summary = []
    for mid in sorted(focus):
        rows = [r for r in agg if r["monster"] == mid and not r["loadout"].startswith("rand_")]
        if not rows:
            continue
        focus_summary.append({
            "monster": mid,
            "mean_wr": mean([r["win_rate"] for r in rows]),
            "min_wr": min(r["win_rate"] for r in rows),
            "max_wr": max(r["win_rate"] for r in rows),
            "mean_hp": mean([r["mean_hp_left"] for r in rows]),
            "mean_turns": mean([r["mean_turns"] for r in rows]),
            "model": rows[0]["monster_model"],
        })

    lines = []
    lines.append("# Spinheritance offline balance Monte Carlo")
    lines.append("")
    lines.append(f"Generated **{now}** · seed `{seed}` · trials/pair `{trials}` · duel rows `{n_rows}`")
    lines.append("")
    lines.append("Pure-data Python sim (`tools/sim/`). Catalog numbers were **not** changed.")
    lines.append("See `tools/sim/ASSUMPTIONS.md` for engine-parity gaps.")
    lines.append("")
    lines.append("## Item coverage")
    lines.append("")
    lines.append(f"- Supported ops in sim: **{sup}/{total}** live items")
    if unsupported:
        show = ", ".join(f"`{x}`" for x in unsupported[:24])
        more = "" if len(unsupported) <= 24 else f" … +{len(unsupported) - 24} more"
        lines.append(f"- Unsupported (ignored by bot): {show}{more}")
    lines.append("")
    lines.append("## Focus monsters — named loadouts")
    lines.append("")
    lines.append("| monster | model | mean win | min | max | mean HP left | mean turns |")
    lines.append("|---|---|---:|---:|---:|---:|---:|")
    for s in focus_summary:
        lines.append(
            f"| `{s['monster']}` | {s['model']} | {pct(s['mean_wr'])} | {pct(s['min_wr'])} | "
            f"{pct(s['max_wr'])} | {s['mean_hp']:.2f} | {s['mean_turns']:.2f} |"
        )
    lines.append("")
    lines.append("Full named×focus grid: [`heatmap_focus.md`](heatmap_focus.md). "
                 "Machine-readable: [`heatmap.csv`](heatmap.csv), [`summary.csv`](summary.csv).")
    lines.append("")
    lines.append("## Ladder smoke (80 trials each)")
    lines.append("")
    lines.append("| loadout | ladder | clear rate | mean HP end | top deaths |")
    lines.append("|---|---|---:|---:|---|")
    for lad in ladders:
        top = sorted(lad["died_to"].items(), key=lambda kv: -kv[1])[:3]
        top_s = ", ".join(f"{k}×{v}" for k, v in top) if top else "—"
        lines.append(
            f"| `{lad['loadout']}` | `{lad['ladder']}` | {pct(lad['clear_rate'])} | "
            f"{lad['mean_hp_end']:.2f} | {top_s} |"
        )
    lines.append("")
    lines.append("## Design-review candidates (do not auto-nerf)")
    lines.append("")
    lines.append(
        "Tankable monsters (no pierce / multi-swing) often show ~100% duel win under "
        "`one_encounter_then_gone` — that is expected and filtered out. See ASSUMPTIONS."
    )
    lines.append("")
    if not flags:
        lines.append("_No pairs crossed the outlier thresholds this run._")
    else:
        lines.append(f"**{len(flags)}** flagged pairs. Listed below (also `outliers.md`):")
        lines.append("")
        for i, f in enumerate(flags[:50], 1):
            why = "; ".join(f["reasons"])
            lines.append(
                f"{i}. `{f['loadout']}` vs `{f['monster']}` — win {pct(f['win_rate'])}, "
                f"death {pct(f['death_rate'])}, mean HP {f['mean_hp_left']:.2f} — {why}"
            )
    lines.append("")
    lines.append("## How to re-run")
    lines.append("")
    lines.append("```bash")
    lines.append("python3 tools/sim/balance_mc.py --trials 300 --seed 7 --out playtest/balance")
    lines.append("```")
    lines.append("")
    lines.append("## Next human steps")
    lines.append("")
    lines.append("1. Read flagged pairs; decide if the *card* or the *hand composition* is the problem.")
    lines.append("2. If a number should move, change it in Roster / catalog in a separate PR — not here.")
    lines.append("3. Extend `SUPPORTED_OPS` when a Pool-2+ card becomes balance-critical.")
    lines.append("")

    (out_dir / "REPORT.md").write_text("\n".join(lines), encoding="utf-8")

    # outliers.md twin
    o_lines = ["# Balance outliers — design review only", ""]
    for f in flags:
        o_lines.append(
            f"- `{f['loadout']}` vs `{f['monster']}`: win={pct(f['win_rate'])} "
            f"death={pct(f['death_rate'])} hp={f['mean_hp_left']:.2f} — "
            + "; ".join(f["reasons"])
        )
    (out_dir / "outliers.md").write_text("\n".join(o_lines) + "\n", encoding="utf-8")

    # meta json
    meta = {
        "generated_at": now,
        "seed": seed,
        "trials": trials,
        "supported_items": sup,
        "live_items": total,
        "unsupported_items": unsupported,
        "flag_count": len(flags),
        "assumptions": "tools/sim/ASSUMPTIONS.md",
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")


def write_resolver_map(out_dir: Path) -> None:
    text = """# Combat resolver map (read-only)

Where live combat resolution lives in Godot (for humans extending the sim).
This PR does **not** refactor these.

| Concern | Location |
|---|---|
| Item ops table | `scripts/main.gd` `ITEM_OPS` |
| Monster specials | `scripts/main.gd` `MONSTER_SPECIAL` |
| Done / enemy swing | `_apply_resolve_hits`, `_owner_attack`, `_swing` |
| Shark loop | `_blood_threshes`, `_shark_attack_player` |
| Item use body | `_use_item` (fangs, defeat_hp, …) |
| Bleed / potion | `_bleed`, `_try_potion` |
| Catalog flow text | `data/catalog.json` `combat_flow`, `rulings` |
| Constructed fights (editor) | `scripts/dev/logic_qa.gd` |

Offline sim twin: `tools/sim/combat_model.py`.
"""
    (out_dir / "RESOLVER-MAP.md").write_text(text, encoding="utf-8")


def self_test(catalog: dict) -> None:
    """Quick assertions for Boot / Fangs / Goblin / Block — fail loud if model drifts."""
    from combat_model import run_duel
    from catalog_load import items_by_id, monsters_by_id

    by_i = items_by_id(catalog)
    by_m = monsters_by_id(catalog)
    rng = random.Random(0)

    # Boot beats Goblin (1 HP < 6); ATK does not.
    st = run_duel([by_i["da_boot"]], by_m["goblin"], rng=rng)
    assert st.won and not st.dead, "Boot should defeat Goblin"
    st = run_duel([by_i["throwing_knife"], by_i["sai"]], by_m["goblin"], rng=rng)
    assert st.won and st.player_hp == 3, "ATK-only vs Goblin: tank 3, slice leaves"

    # Dragon pierce: Shield does not stop 6.
    st = run_duel([by_i["shield"]], by_m["dragon"], rng=rng)
    assert st.dead, "Shield alone should not save vs Dragon pierce"

    # Fangs vs Golem: take hit (3), defeat, heal 7 capped to 6.
    st = run_duel([by_i["fangs"]], by_m["golem"], rng=rng)
    assert st.won and st.player_hp == 6, f"Fangs vs Golem expected full heal, got {st.player_hp}"

    # Flail grows after bleed.
    st = run_duel(
        [by_i["spiked_flail"], by_i["shield"]],
        by_m["wizard"],
        rng=rng,
        prior_hp_loss_events=2,
    )
    assert st.won, "Flail at 4 ATK should kill Wizard 2 HP"
    print("self_test: ok")


def main() -> int:
    ap = argparse.ArgumentParser(description="Spinheritance offline balance Monte Carlo")
    ap.add_argument("--trials", type=int, default=200, help="Trials per loadout×monster pair")
    ap.add_argument("--seed", type=int, default=7)
    ap.add_argument("--random-hands", type=int, default=8, help="Extra random T1/T2 hands")
    ap.add_argument("--out", type=Path, default=REPO_ROOT / "playtest" / "balance")
    ap.add_argument("--catalog", type=Path, default=None)
    ap.add_argument("--self-test", action="store_true", help="Run model assertions and exit")
    args = ap.parse_args()

    catalog = load_catalog(args.catalog)
    if args.self_test:
        self_test(catalog)
        return 0

    out_dir: Path = args.out
    out_dir.mkdir(parents=True, exist_ok=True)

    rows, _ctx = run_matrix(catalog, trials=args.trials, seed=args.seed, random_hands=args.random_hands)
    agg = aggregate(rows)
    flags = flag_outliers(agg)
    ladders = run_sample_ladders(catalog, args.seed)

    # CSV raw (may be large) — write summary always; raw optional sample
    summary_path = out_dir / "summary.csv"
    with summary_path.open("w", encoding="utf-8", newline="") as f:
        fields = [
            "loadout", "monster", "monster_tier", "monster_pool", "monster_model",
            "n", "win_rate", "death_rate", "escape_rate", "mean_hp_left", "mean_turns",
        ]
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for row in agg:
            w.writerow(row)

    # Small trial sample for spot-checks (full matrix is huge).
    trials_path = out_dir / "trials_sample.csv"
    sample = rows[:: max(1, len(rows) // 400)][:400]
    with trials_path.open("w", encoding="utf-8", newline="") as f:
        fields = list(rows[0].keys()) if rows else []
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for row in sample:
            w.writerow(row)

    write_heatmap_csv(agg, out_dir / "heatmap.csv")
    focus_ids = {m["id"] for m in focus_monsters(catalog)}
    write_heatmap_md(agg, out_dir / "heatmap_focus.md", focus_ids)
    write_resolver_map(out_dir)
    # Copy assumptions pointer
    assumptions_src = Path(__file__).resolve().parent / "ASSUMPTIONS.md"
    (out_dir / "ASSUMPTIONS.md").write_text(
        assumptions_src.read_text(encoding="utf-8"), encoding="utf-8"
    )
    write_report(
        out_dir, catalog, agg, flags, ladders,
        trials=args.trials, seed=args.seed, n_rows=len(rows),
    )

    # README for tools/sim
    readme = Path(__file__).resolve().parent / "README.md"
    if not readme.exists():
        readme.write_text(
            "# Offline balance Monte Carlo\n\n"
            "```bash\npython3 tools/sim/balance_mc.py --trials 300 --seed 7\n```\n\n"
            "Outputs land in `playtest/balance/`. Assumptions: `ASSUMPTIONS.md`.\n",
            encoding="utf-8",
        )

    print(f"Wrote {summary_path}")
    print(f"Flagged pairs: {len(flags)}")
    print(f"Report: {out_dir / 'REPORT.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
