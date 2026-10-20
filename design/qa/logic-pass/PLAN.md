# Logic QA pass — plan

Status: **Covering pass** (per-verb states, all live cards, all keywords). Intake locked 2026-10-20. No second question round. Itch unfrozen **2026-10-20** (Nathan asked to update the playtest). No fixer swarm until findings are isolated.

Locked 2026-10-20 night: covering design, not a 57×54 grid. Oracle is what happens (plates + log). Fail grouped as one theme + one example. Keep judged after Done. Click must prove it fired. Live catalog names. Fix the combat log. Include Smoke / hub / cabin / map / draft / Undo. Medallion at full HP = Block 0. Grimoire with no last monster = cannot. Mid-pass two-readings cluster and keep moving.

## What this pass produces

1. **Happy path** — Ability names a number; dummy Golem/Wizard; log must show that number.
2. **Miss / formula-zero** — 0 is legal (Spiked Shield with no Attack item, Chain with 0 Block). Pass if the log matches.
3. **Named collisions** — one story per interaction (Cube eats the click, Goblin vs Attack, Eel vs Block, Flee on Spin, Quiet Bell silence, Keep, order swaps).
4. **Oracle** — expected sentence + combat log. No keyword `blk_min=1`. No Shift-vs-catalog-explainer as a combat Fail.
5. **Board** — Fails only. Click one answer, then Save notes.

## Locked decisions

| Topic | Decision |
|---|---|
| Oracle | Ability + Flow + Notes on the card. If a Paper Fight already named that collision, the Paper Fight wins. |
| Ability mismatch | FAIL vs Paper Fight when one exists; otherwise **NEEDS RULING**. Do not speculate. |
| New two-reading collision | Log **NEEDS RULING** with both readings. Keep the pass moving. Do not stop to Paper Fight mid-pass. |
| Balance / “felt strong” | Flag only. Never change numbers unless Nathan says so in that chat. |
| Item vs item | Order swaps for copy-last, hand-count, Sai-flip, Recycler, Bag of Holding, and similar, both orders, vs Golem / Goblin / Dragon. |
| Coverage cut | **Named scenarios** (~100–250 stories). Not the item×monster grid. Locked 2026-10-20. |
| Drive | Fully automated. `godot_exec` builds the fight. Injected clicks play the card and Done. Speed is animation-limited: raise `Engine.time_scale` during a fight, never skip an animation that fires a rule. |
| Evidence on a packet | Combat log for that fight. One screenshot only when the moment is confusing or many parts interact. Runtime digests may be used internally; they are not required on the packet. |
| Packets | Master `INDEX.md` plus one file per finding. Fixer agents take files whose “Files you may touch” do not overlap. |
| When fixers spawn | As soon as a finding is isolated and does not need a ruling — **after** the Bucket 0 method demo is approved. |
| `main.gd` contention | Before parallel combat fixers, extract the contested rules into smaller scripts so packets do not share `scripts/main.gd`. Do not do a giant rewrite on day one; extract only the slices the open packets need. |
| Where it runs | This chat is the conductor. After the demo is approved, verb-family tester agents are started from here. They share one Godot process, so **Godot input is serialized**. Checklist writing and later patches may run in parallel. |
| Itch | **Unfrozen 2026-10-20.** Export Web Playtest and `butler push` to `nathan-elequin/swipe-playtest` (`html5`) after playable changes (`playtest-ship.mdc`). |
| UI / art / copy found while testing | Side log for Pixel/Jam. Not a logic FAIL. **Exception:** FAIL if the player cannot tell what happened (inspect, Shift, or combat log hides or miscredits the number). |
| Retest | The fixer agent must re-run the same constructed fight and paste the new combat log into its `REPORT.md`. |
| Modes | Constructed card fights in **Challenge**. After that, only Adventure-only edges (Smoke Bomb opening, map, cabin, Keep-from-loot, and anything Ability marks Adventure). |
| Catalog | **Live mill plus Smoke Bomb** (Adventure always starts with it). Skip `retired`, `hold`, `flags.hide`, and other `todo` (Healing Potion, Hornet Swarm, Mimic). Locked 2026-10-19. |
| Surfaces | Everything a friend can click is in scope: hub, cabin, map, Feedback, tier list, pause, inspect, Shift, draft, Undo. That is its own verb family, not mixed into every card fight. |

## What we will not do

- Full **item × monster grid** (thousands of cells with a keyword checker). That mill is retired.
- Change Ability, Call name, or other locked copy.
- Draw or replace PNG bytes.
- Invent player-facing words (Jam owns `data/player-copy.json`).
- Stop the pass to analyze *why* a FAIL happened. Record expected, observed, log, repro. Move on.
- Spawn a swarm of fixers during the Bucket 0 demo.
- Skip itch because this pass is still running (freeze lifted 2026-10-20).

## Roster size (today)

- 68 items, 59 monsters in `data/catalog.json`.
- About 61 live items and 55 live monsters, plus todo / retired / Token.
- Full cross product is thousands of fights. We are not doing that.

## How a professional tester works here

Each checklist row has:

1. **Setup** — mode, wheel, hand, HP, Block, facing seat.
2. **Action** — what is clicked, in order.
3. **Expected** — quoted from Ability / Flow / Notes, or from the Paper Fight that named this collision.
4. **Observed** — combat log lines, plus HP / ATK / Block / spent-or-kept as the log shows them.
5. **Result** — PASS / FAIL / NEEDS RULING / BLOCKED (crash, stuck, cannot set up).

The tester does not rewrite the rule, does not pick a generous vs stingy reading, and does not “fix it while I’m here” unless it is crash/stuck (local only).

## Coverage cut

### Smoke (every catalog card)

One constructed Challenge fight per card.

- **Item smoke:** dummy monster with no special (or the weakest special-less mill monster we can spawn). Use the item. Click Done if the fight should continue. Record whether it spent, kept, the number that landed, and that the game was not stuck.
- **Monster smoke:** dummy hand that can legally take the hit or legally end the fight (a basic Attack and a basic Block). Spin that monster to face. Record the special firing (or not) from the log.
- **Retired / hold / hidden:** do not test. Do not spawn. Do not write FAIL packets. Park the row if one already exists.

### Unique abilities (must fire)

Every live unique ability gets at least one constructed fight that would FAIL if the special never ran. That includes numbers that are supposed to keep updating (Dire Wolf after your HP changes, Slime after it takes damage), not only the value on Spin.

A card also gets extra rows if its Ability/Flow uses any of:

- Always / on Spin
- Keep / return to hand / unplayable
- Copy (last item, neighbor ATK, “uses another card’s number”)
- Tracking (counters, even/odd, exact HP, delayed Defeat, tokens)
- Cheese (Defeat checks, Eject, Flee, skip the swing, set-HP tricks)
- Click then pick a target
- Neighbor / empty alcove / last monster / slices closing
- Pierce / ignore Block
- Cannot take Attack damage / other unhittable
- Extra swings
- Last in the formula
- Poison / Heal-on-death
- Undo across a special

Those cards are run against a **stand-in roster**, not against every monster:

| Stand-in | Why it exists |
|---|---|
| Special-less dummy | Baseline number |
| Goblin (no Attack damage) | Unhittable |
| Hornet Swarm or equal extra-swing | Two swings |
| Commander-style Neighbor buffer | Neighbor math |
| Dragon-style pierce | Block ignored |
| Flee-er (Hired Hand / Cowardly King class) | Combat can end without a hit |
| Empty alcove | No neighbor / no target |
| Last monster on the wheel | Close-up / last owner |
| Slime-style ATK = HP | Number that moves during the fight |
| Click-target item in hand | Extra click still legal |
| Keep item in hand | Hand count / last-item copy |

Item-item extra rows only when the card text names another item, last item, or item count (Bag of Holding, Recycler, Sai-after-any-item, formulas off hand size, copy last).

### Surfaces (everything clickable)

Separate checklist, after the Bucket 0 demo:

- Playtest hub: Brand New / Middle Progress / Continue / Feedback
- Challenge enter, draft, Spin, inspect, Shift, Undo, pause, Done / Take hit
- Cabin, map, radio, journal, rope, loft, and other live rooms
- Tier list (already reported: [#54](https://github.com/Nathan-Elequin/swipe/issues/54))
- Combat log readability (already reported: [#55](https://github.com/Nathan-Elequin/swipe/issues/55))
- Done / Take hit control (already reported: [#44](https://github.com/Nathan-Elequin/swipe/issues/44))

These are side-logged for Pixel/Jam unless the player cannot tell what happened, which is a FAIL.

## Godot MCP method

One editor, one running game. Friends’ itch page is not this environment.

1. Godot open, MCP addon on, game running (F5 playtest on this PC, or editor Play). If the game is not running, start it frozen.
2. `godot_exec` builds the scenario: Challenge mode, wheel, facing seat, hand, HP, Block, items-this-combat.
3. Inject the clicks a player would make (card, target if needed, Done).
4. Thaw at raised `Engine.time_scale` until the animation that applies the rule has finished. Then freeze again.
5. Read the combat log. Compare to the expected row. Write PASS / FAIL / NEEDS RULING / BLOCKED.
6. Reset `Engine.time_scale` to 1 before the next family, and before any human Play.

Do **not** bake this into the Web Playtest export. Setup lives in `design/qa/logic-pass/repro/` as `godot_exec` snippets. A thin helper may be added under `scripts/dev/` only if it is editor/authoring-gated the same way `shot_harness.gd` is. Never add `playtest` to `project.godot` features.

If two tester agents both need the game, the conductor queues them. Simultaneous `godot_input` on one process will corrupt both fights.

## Phases

### Phase 0 — method demo (this is the first thing after approval)

Scope: **Bucket 0** constructed fights in Challenge, plus one hub-to-fight click path so we know F5 is the same game.

Bucket 0 live items today: Throwing Knife, Shield, Sai, The Boot, Crossbow, Sledgehammer, Victory Flask, Quiet Bell, Net.

Bucket 0 live monsters today: Wizard, Golem, Goblin, Dire Wolf, Bandit, Slime Boss, Dragon, Needleback.

Do **not** smoke retired Bucket 0 rows (Dagger, Helmet, Bandana, Caltrops) or other todo (Healing Potion, Hornet Swarm, Mimic). **Do** smoke Smoke Bomb (Adventure opening). After the smoke demo, fill every live unique ability that the smoke pass did not prove (Dire Wolf after HP change, Slime after a hit, Flask after a Defeat, Shield then Done, Bandit at 0 vs many items, two Sais so the 2↔4 flip can fire).

Deep rows in the demo only for Bucket 0 high-risk: Boot, Sledgehammer, Throwing Knife, Crossbow, Sai, Net, Quiet Bell, Goblin, Dragon, Needleback, Dire Wolf, Bandit, Slime Boss, Keep-on-Throwing-Knife.

Deliverables before we stop and wait:

- Harness that can build a fight, click, capture the log
- `INDEX.md` with every demo row marked
- `VERBS.md` for Bucket 0 (and a stub list for later families)
- At least one real finding packet if anything FAILs; if nothing FAILs, one **dry-run packet** that shows the format using a known playtest note (tier list / combat log / Done button) so the fixer shape can be judged
- A short “what I would extract from `main.gd`” note if any FAIL would have to touch it

Then **stop**. Nathan approves or rewrites the method. No mill-wide pass and no fixer swarm yet.

### Phase 1 — method locked, rest of the mill

Conductor starts verb-family tester agents from this chat, one Godot queue:

1. Attack / Block / Heal / Done
2. Keep / spend / unplayable
3. Click then target
4. Neighbor / empty / last / wheel close-up
5. Always / on Spin
6. Copy / formulas / last item / hand count
7. Tracking / tokens / poison
8. Cheese / Defeat / Flee / skip
9. Extra swings / pierce / unhittable / last in the formula
10. Undo / inspect / Shift / log credit
11. Draft / loot on draw
12. Surfaces (hub, cabin, map, Feedback, tier list, pause)
13. Adventure-only edges
14. (removed) Retired / hold / hidden are out of this pass. Todo only if Nathan puts them back in.

Each family writes checklist rows, runs them when it has the Godot lock, appends `INDEX.md`, and drops finding files for FAILs.

### Phase 2 — extract, then parallel fixers

When a finding is isolated and does not need a ruling:

1. If two open packets would both edit `scripts/main.gd` (or the same other file), extract that slice first in the conductor chat. One commit-shaped change, then the packets name the new files.
2. Spawn one fixer agent per packet. `TASK.md` = the finding file. Strict “Files you may touch”.
3. Fixers do not `butler push`. The conductor ships itch after playable changes.
4. The fixer re-runs its constructed fight and pastes the new log into `REPORT.md`.
5. Conductor marks the INDEX row PASS or still FAIL.

NEEDS RULING rows stay in the INDEX until Nathan answers. They are not assigned to fixers.

### Phase 3 — unfreeze

Itch unfrozen **2026-10-20** (Nathan asked to update the playtest). `playtest-ship.mdc` is in force. Covering pass may continue locally.

## Finding packet (fixer handoff)

Path: `design/qa/logic-pass/findings/<id>-<slug>.md`

```
# <id> — <one line of what is wrong>
Status: OPEN
Family: <verb family>
Cards: <id list>
Phase: spin | fight | done | draft | hub | cabin | …

## Expected
Quoted Ability / Flow / Notes, or Paper Fight path + the sentence that wins.

## Observed
Combat log excerpt (required).
Screenshot path (only if confusing / many parts).

## Repro
1. Game running under Godot MCP, frozen.
2. godot_exec source (paste-ready).
3. Clicks, in order.
4. What to read in the log.

## Files you may touch
-

## Do not
- other combat files, catalog copy, PNG bytes, player-copy.json, butler push

## Acceptance
Re-run the repro. Paste the new combat log here. INDEX row becomes PASS only when that log matches Expected.
```

Master index columns: id, family, cards, result, packet path, files locked, fixer status.

## Conductor vs other agents

**This chat (conductor)**

- Owns the plan, the harness, `INDEX.md`, Godot start/stop/queue, `main.gd` extracts, itch freeze, and the Bucket 0 demo.
- Starts tester and fixer agents from here after the demo is approved.
- Does not need Nathan to paste notes or open GitHub.

**Verb-family tester agents**

- Read this PLAN, their checklist, Ability/Flow/Notes, matching Paper Fight files.
- Write expected rows before clicking.
- Run fights only while they hold the Godot lock from the conductor.
- Document. Do not patch unless the game is crashed or stuck and they cannot continue that row.

**Fixer agents**

- One packet each.
- Patch, retest that one repro, write `REPORT.md`.
- No itch push. No copy restyle. No PNG bytes.

Cursor subagents started from this chat are the “chats in concert.” They pick up files on disk. They will not all get a separate sidebar tab unless the product makes one; the INDEX is how work is visible.

## Itch freeze (lifted)

Lifted **2026-10-20**. Export Web Playtest and `butler push` to `nathan-elequin/swipe-playtest` (`html5`) after playable changes. Do not push the public `nathan-elequin/swipe` page unless Nathan says **promote**.

## Open playtest Issues already in scope

These are not linear auto-fixes. They belong in the surfaces / log-credit family after the demo:

- [#56](https://github.com/Nathan-Elequin/swipe/issues/56) Gargoyle art — Pixel. ART-REQUEST. Do not draw.
- [#54](https://github.com/Nathan-Elequin/swipe/issues/54) Tier list buckets, labels, left-to-right bank — tooling + copy (Jam).
- [#55](https://github.com/Nathan-Elequin/swipe/issues/55) Combat log should credit items/passives the way enemy knock-ons are nested — FAIL if the player cannot tell what happened; otherwise side log.
- [#44](https://github.com/Nathan-Elequin/swipe/issues/44) Done / Take hit control redesign — Pixel/feel, not a logic FAIL unless incoming damage is unreadable.

## Approval gate

Phase 0 is approved (2026-10-19). Nathan-facing results go on `board.html`. Stop after Bucket 0 until he says the method is good.
