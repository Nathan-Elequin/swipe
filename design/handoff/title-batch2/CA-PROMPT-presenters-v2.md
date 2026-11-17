# DRAFT CloudAgent prompt: Title presenters v2 (stronger present/bow) · DO NOT LAUNCH until approved

Launch settings: model **grok-4.5**, effort **low**, fast **false**. Repo `Nathan-Elequin/swipe`, base branch **`playtest/latest`**. Work branch: `pixel/title-presenters-v2`. Open **one PR** into `playtest/latest`, titled `art: title presenters v2 (stronger present/bow)`. Do **not** merge.

---

You are installing the **batch-2 presenter animations** for the Spinheritance title redesign (Direction 1, Living trophy room). Don't redesign the layout, invent copy, or touch flow logic. The title visual layer **already merged** as [PR #547](https://github.com/Nathan-Elequin/swipe/pull/547) and is on `playtest/latest`. Rebase onto current tip. The repo already has `assets/ui/title/` from the first art pack (progress icons, goal rings, window divider, and the weaker v1 present frames). **Do not reinstall those icons/rings/windows.** This PR only replaces/adds presenter frames (and optional pane/emblem extras below).

Important: the v1 **gargoyle present frames still include a dirt / ground pedestal**. This pack's gargoyle frames are trimmed. Replacing them is the point of the PR.

## 0. Gate: wait for green Tip smoke (first, and again before you open the PR)

1. `git fetch origin playtest/latest` and record the tip SHA.
2. Check `Tip smoke` (`.github/workflows/tip-smoke.yml`) for that SHA:
   ```
   gh run list --workflow tip-smoke.yml --branch playtest/latest --limit 5 --json headSha,status,conclusion
   ```
3. If it's not `completed/success` for the current tip, wait and re-poll every 5 minutes for up to 90 minutes. Don't start code changes on a red or pending tip.
4. If it's still red after 90 minutes, stop and report the failing job and its log tail. Don't try to fix tip smoke in this PR.
5. Locally, run `tools/qa/run_tip_smoke.sh` (Godot 4.7.2 headless) on your branch before you push. It must pass.

## 1. Extract the art

The pack is at **`/cursor/stores/bot/handoff/title-batch2/batch2.tgz`**. Also copy `SHA256SUMS` and this prompt from the same folder.

```
mkdir -p /tmp/title-batch2 && tar -tzf /cursor/stores/bot/handoff/title-batch2/batch2.tgz | head
tar -xzf /cursor/stores/bot/handoff/title-batch2/batch2.tgz -C /tmp/title-batch2
# archive root is `batch2/`
```

Install every PNG under `batch2/assets/ui/title/presenters/` into the repo at the same path: `assets/ui/title/presenters/{monster}_present_f0..f5.png` (6 frames, native 48×48 or 64×64 — match the existing facing idle canvas for that monster).

- Verify bytes against `batch2/SHA256SUMS` for the presenter paths (`sha256sum -c`).
- Import every new PNG as 2D Pixel: Filter off, Mipmaps off, Lossless. Let Godot generate `.import` files and commit them.
- The recommended hero takes are already the shipped files: goblin `fc6_s41`, gargoyle `fc6_s43` (dirt base trimmed), lich `fc6_s43`. Don't swap them unless a file is missing.
- **Gargoyle must have no dirt / ground pedestal** under the gold claws. If you find a brown mound, stop and report.
- Do not install raw `source/pixellab/` takes into `assets/`. Those are alternates only.

## 2. Wire per `design/visual/SCREEN-title.md`

Read the spec. Follow it exactly. If the spec and this pack disagree on frame count, **this pack wins for presenters**: ship **6 frames** (`f0..f5`) and play them once at 10 fps, then hold the last frame (spec §1.4 timing still applies).

- Title rows stay **goblin / gargoyle / lich** (Continue-or-New-Game / Settings / Feedback). Update their `present` SpriteFrames to the new 6-frame strips. Idle frames stay the existing `assets/dungeon/anim/facing/*_facing_idle_f0..f3.png`.
- At rest: frame `idle_f0`, not playing. Focused row: `idle` at 4 fps. On select: `present` once at 10 fps, hold last. Reduced motion: stay on f0.
- Install the **other biome presenters** in the same folder (Ashen Crypt, Cinder Forge, and the rest of the catalog pools). Do **not** add new title rows. They are available for:
  - any already-specified hook that wants a biome-signature monster, and
  - a small lookup `scripts/ui/title_presenters.gd` (or equivalent) mapping `pool/biome slug → default presenter id` so a later Pixel/Spin PR can use them without another art install:
    - b1 Verdant Hollow → `goblin`
    - b2 Crystal Cavern → `gargoyle`
    - b3 Ashen Crypt → `zombie` (fallback `wraith` if zombie frames are missing)
    - b4 Cinder Forge → `imp` (fallback `plague_doctor` or `cowardly_king`)
    - b5 Shadow Abyss → `lich`
- Picker cards stay goblin / gargoyle / lich per spec §3 unless the visual layer already parameterized the presenter; if it did, keep that API and just point it at the new frames.
- **Copy:** never show "Tier" or "ATK", never bake English player text. Don't edit `data/player-copy.json`.
- **No shaders.** Don't touch Spin-owned flow.


## 2b. Optional extras in the same pack (install, wire only if cheap)

These are in the tarball and listed in `SHA256SUMS`. They are not required for the presenter PR to merge. If they install cleanly, include them in this PR; otherwise leave them in the tree unused and say so.

- `assets/ui/title/panes/pane_{verdant,crystal,ashen,cinder,shadow}.png` — native **56×154**, one tall diorama per title-board window. If you wire them, they replace the per-window crop of `face_bg_*` inside `Window_i` (clip 56×154). Don't change window layout, icons, or caps.
- `assets/ui/title/emblem/{verdant,crystal,ashen,cinder,shadow}_36.png` — native **36×36** alternate sprout / crystal / skull / flame / moon emblems. Only swap them into the existing 36×36 progress plates or goal rings if they clearly read better than the emblems already shipped in #547; otherwise ship the files and don't swap.
- `assets/ui/title/frame/frame9_32.png` — 32×32 wood/gold 9-slice (if present). Optional intro-panel or card chrome.

## 3. Selftest

Extend or add `scripts/dev/title_presenters_v2_selftest.gd` (and a `tools/qa/run_title_presenters_v2_selftest.sh` wrapper grepping `TITLE_PRESENTERS_V2_OK`). Hook it from `tools/qa/run_tip_smoke.sh` if that's already the pattern for title visual tests; otherwise run it from the wrapper and from your PR checklist. Assert:

1. Every shipped `*_present_f0..f5.png` loads, is 48×48 or 64×64 matching that monster's facing idle, filter off, and has a non-empty opaque bbox.
2. Goblin, gargoyle and lich present SpriteFrames have **6** frames and play at 10 fps, once, then hold.
3. Gargoyle present frames have **no** brown dirt pedestal (opaque pixels in the dirt-brown range must not form a mound under the claws; compare against facing idle only after noting the idle *does* have that mound — the present frames must not).
4. Reduced motion: presenters stay on frame 0 during a hover/select.
5. Text sweep: no visible label contains `Tier` or `ATK`.

## 4. Before the PR

- Run `tools/qa/run_tip_smoke.sh` and the presenter selftest. Both must be green.
- Re-run the §0 gate. If the tip moved, rebase and re-run.
- PR body: spec link, list of monster ids shipped, hero take names (goblin fc6_s41, gargoyle fc6_s43, lich fc6_s43), note that v1 presents were subtle idle loops and these are stronger bows that hold, embed a contact/GIF if useful, selftest output.
- Do **not** merge. Don't edit Spin-owned flow or copy. Don't start the picker-card or intro-frame PRs in this branch.
