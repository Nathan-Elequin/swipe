# Copy Log

## 2026-11-02 — Biome-enter splash multi-page narration (Spin lock)

Spin locked a connected sensory chain: three pages per tip biome under `splash.biome.<slug>.p1` / `.p2` / `.p3` for `verdant_hollow`, `crystal_cavern`, `ashen_crypt`, `cinder_forge`, `shadow_abyss`. Exact strings from Nathan 2026-11-02 lock file. Old single keys `splash.biome.<slug>` kept as unused fallback only. Chrome `splash.chrome.continue` = `click anytime` unchanged. Same splash BG across pages; click advances page then dismisses.

## 2026-11-02 — Biome-enter splash narration (Spin lock)

Spin locked first-person plain fiction for `splash.biome.verdant_hollow`, `splash.biome.crystal_cavern`, `splash.biome.ashen_crypt`, `splash.biome.cinder_forge`, and `splash.biome.shadow_abyss`. Values pasted exactly into `data/player-copy.csv` and `data/player-copy.json`. Chrome keys (`splash.chrome.biome|dungeon|delves|continue`) unchanged. Layout: narration bar grew to 340px / max 5 lines so the longer paragraphs fit at 1680×1040 without clipping Spin’s words.

## 2026-10-07 — Draft gate (copy id swipe-player-copy-v3-draftgate)

Approval: Nathan explicitly approved overriding his author-locked draft-gate lines on 2026-10-07 ("Yes, apply the new draft-gate lines."). Backup of the previous file: data/player-copy.backup-2026-10-07.json.

Locked lines:
- Header: "Take it or leave it?" (cue.ask)
- Risk rule: "The finer the loot, the fiercer its owner." (door.help — not wired in code yet)
- Item card subtitle: "Guarded by a {Weak|Tough|Deadly} monster" (door.guard = "Guarded by a {tier} monster" + tier.1/2/3.name — not wired yet)
- Take button: "Take it" (door.take — not wired yet)
- Pass button: "Leave it ({n} passes left)" / "Leave it (1 pass left)" (needs code to pass {n}; door.pass is currently "Leave it")
- After take / placement: "A monster approaches. Select their location." (cue.seat, door.seat)
- Out of passes: "Out of time" (cue.force, cue.steal, door.pass_none)
- Shift/map hint on this screen: removed

Tier naming rule: internal Tier 1/2/3 = player Weak/Tough/Deadly. Never show the word "Tier" to the player.

Design note: Dungeon must stay visible the whole time during drafting — layout task for Cursor, not copy.

Code/layout follow-ups: see design/CURSOR-DRAFT-GATE-TODO.md.
