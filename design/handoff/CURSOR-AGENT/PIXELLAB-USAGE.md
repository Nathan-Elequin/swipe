# PixelLab usage notes (runs 2–4, 2026-10-20)

Account: Nathan's PixelLab, nathan.elequin@gmail.com. The API key is on the pixellab.ai account page. Give it to the agent as env `PIXELLAB_API_TOKEN`: a Cursor **cloud secret** with that exact name, or a user env var on Cherry for Cursor local. **Never write the token into any file, log, commit, PR or chat.**

## Balance and costs
- Tier 1 subscription: **2,000 generations a month**. Balance was **1,724** on 2026-10-21 02:30 CT. It renews around **Nov 20**.
- Check `GET /v2/balance` (free) before every batch. Set `PL_BUDGET` per batch, and stop and report if a batch would take the balance below about 200.
- The account is shared with Nathan. Run4 saw about 20 generations leave the balance that weren't in its log, so count your spend from `calls.log`, not from the balance delta.

| Run | Gens | What |
|---|---|---|
| run2 | ~22 (20 calls, trial balance) | first animate-with-text tests (Sprout run, a few monster anims) |
| run3 | 39 (+2 touch-up) | bases via pixflux/bitforge, 14 animations, 1 pro-flash hero (6 gens) |
| run4 | 212 | 18 UI bases, 14 UI anims, 56 monster bases (+rerolls), 56 cut-in portrait anims, rerolls |

Per call:
- pixflux / bitforge image: 1 gen
- animate-with-text-v3: 1 gen for 4, 6 or 8 frames
- `/create-image-pro-flash` 128px: about 6 gens (ask `/pro-flash/cost` first)
- A 500 error on a bad request was **not charged**.

## Endpoints and params that worked
- **`/create-image-pixflux`** (most art):
  - `description`, `image_size`, `no_background: true`, `text_guidance_scale: 8`, `seed`
  - `outline: "single color black outline"`, `shading: "medium shading"`, `detail: "medium detail"`, `view: "side"`, `direction: "east"`
  - `color_image`: a tiny PNG of the palette (spinheritance.hex + the UI token colours + the poison purple ramp; see `lib.palette_img()`)
  - Optional `init_image` + `init_image_strength` (120–220). The init is a rough blocked-in drawing at the target size.
- **`/create-image-bitforge`**: style-guided. **`style_image` must be exactly the output size**, otherwise you get a 500 (seen at 32/64 with a 48px style). Minimum size is 16.
- **`/animate-with-text-v3`**:
  - `first_frame` (base64 PNG), `action`, `frame_count` (4/6/8), `no_background`, `seed`
  - Optional `last_frame`, used for the sai single → pair split
  - Returns `background_job_id`; poll `/background-jobs/{id}` until the status is not processing/pending/queued
  - Output frame 0 is usually the input. Run4 used frames 1..N; sai_split used 0,2..8.
- **Small UI (8–16px)**: generate at 2x–4x (32–64px), then `down()` + `clean()` + `fit()` to native. Generating at native 8px directly is mush.
- **Monster bases**: full body facing right, `"three-quarter side view, high detail pixel art monster, clean readable silhouette, crisp 1px dark outline, 3-4 tone shading lit from upper left, dark fantasy dungeon game"`.
  - Init from the current 16px still, upscaled **smooth (bicubic) to 80px** with strength 80. This beat a blocky 6x nearest init at strength 160, which just produced enlarged 16px sprites.
  - Three monsters went text-only, with no init: gelatinous_cube, leech_league, needleback.
- **Cut-in portraits**: crop the head close-up from the base (`pport.py`: centred blob for amorphous bodies, top-right head for wide bodies). Then animate with `"close-up anime cut-in portrait of the {desc}: {action}; dramatic, keeps the same character design"`.
- Concurrency 2–3. Retry on 429/502/503/504 with backoff.

## Cleanup every output needs (the agent does this)
- Snap to the palette (Lab nearest). Remove islands under 3–4 px and orphan pixels.
- Rebuild the 1px `#100e0c` outline. Keep light from the upper left. No anti-aliasing and no semi-transparent pixels (alpha is 0 or 255).
- Bottom-align feet across frames. A 1px vertical jitter between frames is a common bug.
- Integer scales only. Import with Nearest.

## Failure cases seen
- The rope tile came out as a black bar → rerolled with a 32x64 "thick braided rope filling the full width", then `/8`, and a side outline added by hand.
- sai_split mid frames lost the sai → reroll prompt "spins quickly like a propeller with the blade always visible, then it separates into two crossed sais", with `last_frame` = the pair.
- heart_drip had no drip, and the poison bubble snapped blue with no burst → rerolls plus **hand touch-ups after 2 fails**: heart_drip got a progressive drain and tip drip, poison_burst got its f2/f3 droplet ring. Originals are in `art-source/run4/work/pre_hand/`.
- The wolf design faced LEFT → mirrored the base. Check facing on every base.
- Victory "raised fists" failed twice (arms stayed down) → hand-drawn.
- scroll_unfurl jumped from rolled to open, and the reroll only tilted it → kept r1 and hand-drew the in-betweens.
- Hornet Swarm: the old base was blocky, and the new s43 base fused the three hornets into one body → **needs a re-roll** (task list).
- Almighty Worm: the close-up reads as a maw ring, not a worm → **needs a re-roll**.
- Weak motion, needs a redo: ticker_token_stamp, poison_badge_drip, intent_claw_burst, petrify_shatter, sai_split, hook_taut. heart_drip and poison_burst are partly hand-drawn already.
- Poison colour: the art came out **purple** (#4a3a78/#7a6aa8, green accent #8cbc48) because the spec said "purple-green", but the in-game poison is **green** (#7dba7d droplet, #d8f0d0 number). **Nathan must pick** before more poison art is made.
