# Cursor prompts — Direction A screens

Build order: theme setup → hand-card → wheel → placement → fight → inspect → pause → how-to-play → title → victory → defeat → draft-gate v2. Max 2 tweak rounds per screen, then flag it.

Copy keys Jam is adding for this pack: `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`. Jam is also changing the text of the existing keys `door.owner` and `door.shiny`. Cursor reads all of them through PLAYER_COPY and never hard-codes them.

## 0 · Theme setup (once)
```text
Read design/visual/style-guide.md. Create themes/swipe_theme.tres with the type variations in section 4, add the three OFL fonts (Pixelify Sans, Silkscreen, VT323 from Google Fonts) to assets/ui/fonts/ with antialiasing off, and apply the pixel-snap and nearest-filter project settings from section 1. Don't change gameplay code or anything under data/. List anything you couldn't set.
```

## title
```text
Read design/visual/style-guide.md and design/visual/SCREEN-title.md, and look at the mockup PNG(s) they link.
Build scenes/ui/title_screen.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/title_screen_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## how-to-play
```text
Read design/visual/style-guide.md and design/visual/SCREEN-how-to-play.md, and look at the mockup PNG(s) they link.
Build scenes/ui/talk_box.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/talk_box_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## wheel
```text
Read design/visual/style-guide.md and design/visual/SCREEN-wheel.md, and look at the mockup PNG(s) they link.
Build scenes/ui/wheel_hud.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/wheel_hud_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## placement
```text
Read design/visual/style-guide.md and design/visual/SCREEN-placement.md, and look at the mockup PNG(s) they link.
Build scenes/ui/placement.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/placement_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## fight
```text
Read design/visual/style-guide.md and design/visual/SCREEN-fight.md, and look at the mockup PNG(s) they link.
Build scenes/ui/fight.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/fight_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## victory
```text
Read design/visual/style-guide.md and design/visual/SCREEN-victory.md, and look at the mockup PNG(s) they link.
Build scenes/ui/victory.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/victory_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## defeat
```text
Read design/visual/style-guide.md and design/visual/SCREEN-defeat.md, and look at the mockup PNG(s) they link.
Build scenes/ui/defeat.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/defeat_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## pause
```text
Read design/visual/style-guide.md and design/visual/SCREEN-pause.md, and look at the mockup PNG(s) they link.
Build scenes/ui/pause_menu.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Opening pause must close inspect first.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/pause_menu_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## inspect
```text
Read design/visual/style-guide.md and design/visual/SCREEN-inspect.md, and look at the mockup PNG(s) they link.
Build scenes/ui/inspect_plate.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/inspect_plate_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## hand-card
```text
Read design/visual/style-guide.md and design/visual/SCREEN-hand-card.md, and look at the mockup PNG(s) they link.
Build scenes/ui/hand_card.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/hand_card_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```

## draft-gate
```text
Read design/visual/style-guide.md and design/visual/specs/DRAFT-GATE-SPEC.md and design/visual/SCREEN-draft-gate.md, and look at the mockup PNG(s) they link.
Build scenes/ui/draft_gate.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/draft_gate_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
