# Spinheritance animation + art handoff for a Cursor agent (start here)

Written 2026-10-21 by Grok Bot, at Nathan's request, so a Cursor agent can finish all of the remaining animation and art work using only this repo. Spinheritance was formerly called "Swipe". GitHub: `Nathan-Elequin/swipe`, default branch `main`, no CI.

**Everything you need is in this repo.** Earlier work ran on Grok Bot's Linux box and on Nathan's Windows PC "Cherry". Neither is reachable from a cloud agent, and you don't need them. A few history docs mention `C:\Users\Natha\...` paths or `<ART_KIT>` / `<ANIM_PITCH>` placeholders. Those point at the old copies; the in-repo copies are in this folder.

> Note on `.cursor/rules/swipe-design-loop.mdc`: that rule was written for "Pixel draws, agent wires". For **this** handoff Nathan has approved these differences:
> - You generate net-new art yourself through the PixelLab API and clean it up.
> - You push a branch and open a PR per pass.
> - You may merge a pass to `main` once its local QA step has passed.
>
> Every other rule there still holds: no player-copy edits, no "Tier", no new game dependencies, no save-format changes.

## 1. The game in one paragraph
Spinheritance is a Godot 4.7 (GL Compatibility) roguelite at 1680x1040 with pixel art at integer scales and Nearest filtering. A wheel of 4–8 monster seats surrounds a hub; the player spins, monsters attack, and the player plays item cards from a hotbar. Hero "Sai" starts solo each dungeon. The main code is in `scripts/main.gd` (~15k lines), `scripts/boss_wheel.gd` (the wheel), `scripts/item_card.gd`, `scripts/combat_stage.gd`, `scripts/dungeon_art.gd` (art loaders) and `scripts/bucket_reveal.gd`. Data is in `data/catalog.json` (59 monsters; 58 live, because `three_seeker` is not a live monster). `data/player-copy.json` holds player strings and is owned by Jam/Nathan.

## 2. State at handoff
The animation plan is 10 approved pitches (`specs/PITCH.md`) built in 6 passes (`design/visual/BUILD-ORDER.md`). The specs are in `design/visual/` (canonical). `specs/` here is an identical snapshot from 2026-10-21; if they ever differ, `design/visual/` wins.

| Pass | Scope | Status |
|---|---|---|
| 1 | Intent plate, Shark loop, HP-loss fix, bleed pulse | **Merged**: PR #71 https://github.com/Nathan-Elequin/swipe/pull/71 |
| 2 | Slash-portrait cut-ins (+250ms on each monster's first cut-in per run) | **Merged**: PR #72 https://github.com/Nathan-Elequin/swipe/pull/72 |
| 3 | Spin cascade ticker + Shift fast-forward (0.675 → 2.025) | **Merged**: PR #73 https://github.com/Nathan-Elequin/swipe/pull/73 |
| 4 | Poison pop, petrify creep/shatter, grappling hook yank, aura threads | **WIP draft**: PR #74 https://github.com/Nathan-Elequin/swipe/pull/74, branch `anim/pass4` |
| 5 | Sai twirl/split, marble swirl, hotbar shimmer, hover preview | Not started. **Final art is already on main** (see §5) |
| 6 | Wheel monsters, layout "B4" | Not started. No final art yet |

Art already on `main` (all final PixelLab run4 art, byte-identical to `art-source/run4/final`):
- `assets/ui/anim/intent_*`, `ticker_*`
- `assets/dungeon/anim/slash/*` for 54 monsters
- Pass 5 art, added by this handoff:
  - `assets/dungeon/anim/sai_*`, `marble_*`
  - `assets/ui/anim/deadly_sparkle_f0-3`, `intent_chip_plus`

Pass 4 art lives on `anim/pass4` only, so it doesn't conflict. Hornet Swarm and Almighty Worm slash art was deliberately left out of main; those two use the still fallback until they are re-rolled (task 7).

## 3. Ordered task list (with acceptance criteria)
Use one branch + PR per task group, named `anim/<passN-...>` or `art/<...>`.

### Task 1: Finish pass 4 (`anim/pass4`, PR #74)
Context:
- `pass4/PROGRESS.md` has the run notes.
- `pass4/PROMPT-fix.RECONSTRUCTED.md` is the fix prompt. The original was lost, so this is a rebuild; follow its intent.
- `pass4/12-prompt.txt` is the original pass 4 prompt (also in BUILD-ORDER.md).
- The fix + QA CLI run was killed mid-way. Its code edits and re-shot PNGs are committed in `918c7fa` but **unreviewed**.

Do:
1. Fix the SCRIPT ERROR seen in QA: `Out of bounds get index '5' (on base: 'Array')` at `main.gd:_apply_mark` (~L12498), called from `hook_fx.gd:101 throw`. It is probably a seat index from an 8-seat assumption, or a stale index after a collapse. Make every hook, poison, aura and petrify path seat-count agnostic (4–8 seats).
2. Poison colour: **ask Nathan, don't decide.** The game's poison is green (`#7dba7d` droplet, `#d8f0d0` number), the PixelLab art is purple (`#4a3a78`/`#7a6aa8`, `#8cbc48` accent). Put the question at the top of the PR. Leave the art as it is until he answers.
3. `assets/ui/anim/poison_lock.png` is still a 6x6 magenta placeholder. Generate it with PixelLab (a padlock at 24–48px, then `down` to 6x6, palette, outline) and keep `PLACEHOLDERS.md` accurate.
4. Hand off to **local QA** (see `CLOUD-SETUP.md` / `LOCAL-QA-PROMPT.md`). QA checks every shot in each spec's QA section, a 6-seat shot per spec, normal speed `Engine.time_scale == 0.675` and Shift = 2.025, and no new SCRIPT ERROR.

Accept when:
- the PR is out of draft and its description lists the shots
- the text audit shows 0 "Tier"/"ATK"
- the merge check against `movement` is noted in the PR
- the PR is merged to main.

### Task 2: Pass 5 (`anim/pass5-hotbar`)
Use the verbatim Pass 5 prompt in `design/visual/BUILD-ORDER.md`, with one change: **final art already exists** at every pass 5 path. Do NOT create placeholders over it; only create `PLACEHOLDERS.md` entries marking those files final.

Scope:
- sai twirl/split. Sai starts solo each dungeon; there is no merge asset, so the merge is the split frames reversed.
- marble swirl
- Weak/Tough/Deadly hotbar shimmer. The words Weak/Tough/Deadly may appear on cards as rank names, but never "Tier".
- hover-preview rule table (phase 1 only)

Exact strings: "Loaded" and "Loaded: your next Attack can hit any monster." These come from `PLAYER_COPY`; if a key is missing, flag it instead of writing copy.

Accept when the BUILD-ORDER pass 5 QA list passes in local QA.

### Task 3: Pass 6 (`anim/pass6-wheel-monsters`), layout B4
Read `design/visual/ANIM-wheel-monsters.md` and the Pass 6 prompt in BUILD-ORDER.md. Mockups: `mockups/layouts/crest/layout_B4_6.png` (design for 6 seats) and `layout_B4_8.png`. Medallion mockups: `mockups/layouts/crest/clean/med18_*.png`. Generator: `make_b4.py`.

Key rules:
- 96px monsters (24 native x4), frameless, on floor shadows.
- **Plain compact name tag**, un-notched.
- **18px ability medallion** with a 1px `#1c1814` rim, drawn at 3x, overlapping the tag's top edge by about 30% and the feet slightly.
- Z-order per seat: shadow < sprite < tag < medallion < HP/ATK badges.
- **HP heart LEFT, ATK star RIGHT** on every seat. All text upright.
- The full ability text shows on hover or for the facing seat.
- Seat-agnostic for 4–8 seats, designed for 6. Facing idle.
- `scripts/bucket_reveal.gd` (~L384–388): show HP before Attack. **Order change only**: keep the strings "Attack %s" and "HP %s" and the separator.

Placeholders first, per the prompt. Then hand off to local QA.

Accept when:
- every shot in the BUILD-ORDER pass 6 QA list is done, including 02/02b and 02c–e at 4, 5 and 7 seats with the fit-table clearances logged (all ≥ 0)
- nothing overlaps
- the text audit is clean.

### Task 4: Pass 6 art via PixelLab (`art/wheel-monsters`)
1. Medallion set: 20 ability-icon keys → `assets/ui/wheel/medallion_<key>.png`. The keys are sparkles, link, users, swords, layers, heart, droplet, ban, rotate, mountain, footprints, trending, shield, skull, copy, plus, wand, hammer, sword, palm. Each is a 20x20 file holding an 18px coin with a 1px `#1c1814` rim and a glyph ≤10px native.
2. `assets/ui/wheel/name_tag.png`: 32x32, 9-slice with 5px corners, no notch. Candidates are in `art-source/crest-pixellab/clean/tag_round_fixed.png`; regenerate if they don't fit.
3. Wheel bases + 2-frame breathe for the 58 live monsters: `assets/dungeon/anim/wheel/<id>_wheel_base.png` and `_breathe_f0/_f1`. Seed from `art-source/run4/final/bases/<id>_base.png`. `golem` and `wizard` have **no run4 base**; make them first.
4. Facing idles, 4–6 frames: `assets/dungeon/anim/facing/<id>_facing_idle_f0..`, 48x48, or 64x64 for Deadly.

Budget: about 174–190 gens for items 3–4. Check the balance first (1,724 on 2026-10-21; it renews around Nov 20). Batch 20–40 at a time, one contact sheet per batch.

5. Add the tag + medallion rows to `design/visual/ASSETS.md` (they are missing there).

### Task 5: Art follow-ups (`art/rerolls`)
- Re-roll the **Hornet Swarm** slash art (the three hornets fused into one body) and the **Almighty Worm** slash art (the close-up reads as a maw ring). Keep old and new side by side in the PR on a contact sheet; Nathan picks. Old ones are in `art-source/run4/final/assets/dungeon/anim/slash/`. Only the chosen set goes into `assets/dungeon/anim/slash/`.
- Redo the weak-motion FX: `ticker_token_stamp`, `poison_badge_drip` (wait for the colour decision), `intent_claw_burst`, `petrify_shatter`, `sai_split`, `hook_taut`. `heart_drip` and `poison_burst` were partly hand-drawn; leave them unless they look broken.

### Task 6 (paused; only if Nathan asks)
- Title teaser wiring: 64px Sprout is canonical, plus the logo and items. Brief: `title-teaser/src/intro_teaser_title_*.plan.md`, `title-teaser/ship/PIXEL-NOTES.md`, `title-teaser/src/torchlit-burrow-style-guide.md`. In the repo: `design/visual/title-teaser/`, `design/handoff/title-teaser/`.
- Gemini hero swap, `hero_drop_sack`.
- The `project.godot` name change. Never commit `project.godot` from a run unless that is the task.
- Later only on request: move buttons/counter art, a wheel-rotate anim.

## 4. Rules (non-negotiable)
- **Crypt Classic style.**
  - 1px `#100e0c` outline, light from the upper left.
  - No anti-aliasing, alpha 0 or 255 only. Gold is `#FFD84A`.
  - Nearest filter. Integer scales only.
  - Palette: `palette/spinheritance.hex`, plus the UI tokens in `design/visual/_COMMON.md`.
- **PixelLab makes all net-new art** through the API at `https://api.pixellab.ai/v2`.
  - Use pixflux with an init image + the palette `color_image`. A bitforge style image must be the same size as the output.
  - Check `/v2/balance` before every batch, and cap each batch.
  - Review one contact sheet per batch. You do the grid and palette cleanup.
  - Hand-draw only small fixes, or after 2 failed tries. See `PIXELLAB-USAGE.md`.
- **Never rewrite player-facing copy.** `data/player-copy.json` is owned by Jam/Nathan. If a string is missing or wrong, flag it in the PR. New strings go through `PLAYER_COPY.text(key, fallback)` with existing keys only.
- Never show the words **"Tier"** (Weak/Tough/Deadly are the only rank words) or **"ATK"/"atk"** to players.
- **Animation speed:** normal game animation speed is `ANIM_TIME_SCALE = 0.675` (`main.gd` L53), not 1.0. Shift fast-forward is 0.675 x 3 = **2.025**. A CLI run once reset it to 1.0, so check after every pass. Tweens and timers must respect `Engine.time_scale`.
- **Intents and cut-ins:** intent badges show the RAW hit and flash blue when Block soaks it. The first cut-in per monster per run holds +250ms. Sai starts solo each dungeon.
- Ignore mismatched item description text; Nathan will retune the wording.
- Don't change Space / `ui_accept` / the input map, and don't add a Spin shortcut.
- **Never commit:**
  - `.wrangler/`, `.art-ping.env`, `.art-ping.last`, `build/`
  - `project.godot`, `default_bus_layout.tres`
  - stray logs, `.godot/`, or `--import` churn on unrelated `.import` files
- Never print or commit secrets: `PIXELLAB_API_TOKEN`, art-ping webhook URLs/keys.
- Don't export, and don't push to itch.

## 5. Workflow
See `CLOUD-SETUP.md` for the split. In short:
- **Cloud agents** do PixelLab art, cleanup, specs and GDScript on a branch + PR.
- **Local QA**: Cursor on Cherry runs `LOCAL-QA-PROMPT.md`, using godot-mcp or the shot harness at 1680x1040.
- **Merge:** after local QA passes, merge the pass PR to `main`. Merging per pass is allowed (Nathan's rule).

For each pass:
1. Branch off the latest `origin/main`: `anim/passN-...` or `art/...`.
2. Commit in steps: `anim-passN(k): ...`.
3. Open the PR. Its description needs the files-changed summary, the shot list, open questions for Nathan, and a **movement dry-run note**.
4. Movement dry-run. **`origin/movement` shares no history with `main`** (checked 2026-10-21: separate root, so `git merge-tree` says "refusing to merge unrelated histories"). Do a file-level overlap check instead: list the files your branch changes vs `origin/main` (`git diff --name-only origin/main <branch>`), then flag any that also exist on `origin/movement` with different content (`git rev-parse origin/main:<f>` vs `origin/movement:<f>`). Put that list in the PR as a dry-run note. Example: pass 4 overlaps on `scripts/main.gd`, `scripts/dev/shot_harness.gd` and `assets/ui/anim/PLACEHOLDERS.md`. **Never** check out, merge into or push `movement`. Nathan has uncommitted work on it.
5. Once local QA passes, merge to main (squash or merge commit, matching #71–#73, which used merge commits).

## 6. How to QA
- The game must run **windowed**. The shot harness gives an empty viewport under `--headless`. Its CLI: `godot --path <worktree> -- --shots=<stem,...> --shots-out=res://design/visual/anim-qa/<spec>`. See `scripts/shot_cli.gd` and `scripts/dev/shot_harness.gd`.
  - Passes 1–4 added stems for their shots; add new stems for passes 5–6 in the same style.
  - Exit codes: 0 = ok, 1 = a skip or audit fail, 2 = bad args.
  - `godot --headless --path . --quit` (or `--script res://tools/qa/check_shot_cli.gd`) is fine for parse checks.
- godot-mcp (`addons/godot_mcp`, `.cursor/mcp.json`) attaches to whichever editor is open, which is often Nathan's on his `movement` checkout. Only use it when the editor is open on your worktree.
- Playtest folder and "approved" flow: see `.cursor/rules/playtest-approve.mdc`.
- Text audit: `scripts/dev/text_audit.gd` runs as part of the harness. It must show 0 "Tier" and 0 "ATK".
- Reference shots of what "good" looked like for passes 1–3 are in `qa-reference/pass1..3`.

## 7. File map (this folder)
| Path | What |
|---|---|
| `README.md` | this file |
| `TASK.md` | pointer for the design-loop rule |
| `KICKOFF-PROMPT.md` | paste into the Cursor cloud project to start |
| `CLOUD-SETUP.md` | cloud ↔ local split, secrets, Python deps, why Linux Godot is skipped |
| `LOCAL-QA-PROMPT.md` | paste into Cursor local on Cherry for each QA/merge step |
| `PIXELLAB-USAGE.md` | costs, params that worked, failure cases |
| `pixellab/` | sanitized runnable toolkit + `.env.example` + API docs snapshot |
| `specs/` | snapshot of `design/visual` specs + `PITCH.md` (approved top-10) + `QUESTIONS.md` |
| `mockups/` | pitch mockups, wheel size tests, layouts A–D, `layouts/crest/` (B1–B4; **B4 is the chosen one**: `layout_B4_6.png`, `layout_B4_8.png`, `clean/med18_*`, `make_b4.py`, `specgen/pass6.md`) |
| `qa-reference/` | key QA crops/grids from passes 1–3 |
| `palette/` | `spinheritance.hex` / `.gpl` (64 colours) + swatches |
| `pass4/` | run notes, the original prompt, the reconstructed fix prompt |
| `cli-history/` | passes 1–3 CLI prompts, fix prompts and PR bodies (style reference) |
| `title-teaser/` | paused title redo v3: plan/brief, style guide, storyboard, QA stills, refs, generator scripts |
| `art-source/run4/` | the run4 PixelLab working set: `final/` (repo layout, incl. hornet/worm old slash art), `final/bases/` (56 full-body bases), `showcase/` (contact sheets + GIFs), `raw/`, `base/`, `work/`, `refs/`, scripts, `calls.log`, `PROGRESS.md` |
| `art-source/run2/`, `run3/` | earlier runs: finals, showcases, scripts, logs |
| `art-source/early-runs/` | first PixelLab item/logo tests + scripts |
| `art-source/gemini-and-refs/` | Gemini concept folders 00–12, PixelLab items 13–21, `cleanup-*` tools, `_reference/refs` (in-game refs at x8/x16, palette), `PLATFORMS.md`, `PROMPTS.md` |
| `art-source/crest-pixellab/`, `layouts-pixellab/` | PixelLab medallion/tag/crest experiments behind the B-layouts |
| `MANIFEST.md` | sizes |

Scripts in `art-source/` are historical: paths were rewritten to `<ART_KIT>` etc. Use `pixellab/` to run anything.

## 8. Predicted pitfalls
See the "Pitfalls" section in `CLOUD-SETUP.md`.
