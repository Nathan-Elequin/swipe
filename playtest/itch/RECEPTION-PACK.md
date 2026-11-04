# Spinheritance — itch reception pack (copy + shot list)

**Tip SHA this pack was grounded on:** `87598dd4` (`playtest/latest`)  
**Engine:** Godot 4.7 (GL Compatibility) · Web Playtest export → `nathan-elequin/spinheritance-playtest` (`html5`)  
**Scope of this file:** store copy drafts + capture list for Pixel. No butler upload. No gameplay edits.

---

## 0. What tip actually ships (do not invent)

Grounded in `project.godot`, `data/campaign.json`, `data/player-copy.json`, `data/script-names.json`, `scripts/dev_flags.gd`, `scripts/cabin/road_frame.gd`, `scripts/cabin/rope_exit.gd`, `scripts/campaign_map.gd` / `held_map.gd`, `scripts/playtest_hub.gd`, `scripts/main.gd`.

### Live on the playtest build

1. **Playtest hub** — Brand New / Middle Progress / Continue / Feedback (F2) / Tier List. Friends land here first.
2. **Brand New → road to cabin** — intro stills, then approach → ambush → “Go through the tutorial with Nib?” (Yes / Skip). Cabin stays hidden under the road frame until tutorial finish or Skip.
3. **Nib tutorial** — ambush wheel fight that teaches Spin, Attack / Block / Defeat / Keep / Move, then arrive splash into the cabin.
4. **Cabin hub** — Front Room, Trophy Hall (five biome cabinets), Study, Workshop, Loft, Outpost. Nib, Grandpa’s Map, Melodeon, journal, will, training dummy, etc.
5. **Campaign map** — Grandpa’s Map of Mount Grumblegut. Five biomes, each meaner than the last; living Deadlies patrol on the parchment. **Endless** stays sealed until all five cabinets are full.
6. **Biomes (cabinet / splash names from tip)**  
   - Verdant Hollow · Crystal Cavern · Ashen Crypt · Cinder Forge · Shadow Abyss  
   Entering a tip biome shows splash narration, then the delve.
7. **Delve combat** — six-seat monster wheel, Spin to face one, hotbar items, **3 Moves per dungeon**, Keep items, draft loot between seats. Die and the haul does not come home.
8. **Rope Exit (diegetic)** — after a clear: knotted rope ladder tagged with Grandpa’s name (Climb / **Bank home**), cavern gate (**Push deeper**), peek in the sack, biome cabinet chip `{n}/5`. Nib blocks Push while that biome’s cabinet is under 5/5 and sends you home with the haul.
9. **Trophy Hall loop** — bank uniques into the matching biome case (quota 5). Fill a case to unlock the next dungeon on the map.
10. **Feedback tooling** — right-click any item/monster; F2 Feedback; optional phone voice-memo chip on the hub intro.

### Not a separate player mode on tip (do not pitch as live)

- **Old Gatehouse (classic Adventure route)** and **Long Drop (Challenge Mode)** are **archived**. `DevFlags.SHOW_OLD_GATEHOUSE` / `SHOW_LONG_DROP` are `false`; player exports never show those map routes (`scripts/dev_flags.gd`).
- Campaign delves set `adventure = true` and `challenge_route = false` (Moves on, six seats). Title-overlay pills may still read “Adventure Mode” / “Challenge Mode” in code, but both open the **campaign map**, not the archived dual routes.
- Do **not** write itch copy that promises a pick between Adventure and Challenge as two shipped modes.

### Numbers useful for longer copy (catalog tip)

- ~65 live items · ~56 live monsters (`data/catalog.json` statuses).
- Cabinets: 5 uniques per biome (`cabinet_quota`). Starter loot mix 3/2/1 across unlocked pools. Wheel 6 + reserve 4.

### Locked voice (do not rewrite)

- Title: **Spinheritance**
- Tagline (player-copy): **Where there's a will, there's a slay.**
- Project description string: **Steal the shiny. Fight who owned it.**
- Hero (Nib’s name): **Sprout** · Executor: **Nib** · Grandpa: **Bartleby "Lucky" Snatchwick** · Mountain: **Mount Grumblegut** / **the Grumble**

---

## 1. Short blurb (itch short text)

Itch short description is tight (~140 characters). Pick one; do not paste two.

**A (tagline-led, ~88)**  
Where there's a will, there's a slay. Spin the dungeon wheel, bank the haul, fill Grandpa's cabinets.

**B (verb-led, ~118)**  
Inherit the will. Spin a monster wheel under Mount Grumblegut, Bank or Push at the rope, and fill five biome cabinets.

**C (playtest-honest, ~120)**  
Playtest build: cabin → map → five biomes. Spin, Keep, Move. Rope Exit to Bank home or Push deeper. Feedback welcome (F2).

**Recommended for the public-facing short field:** **A**. Use **C** if the page stays clearly labeled as playtest-only.

---

## 2. Longer description draft (itch “Description”)

Paste-ready HTML-ish markdown. Keep “Tier / ATK / atk” out of player-facing sentences (house rule).

```markdown
# Spinheritance

**Where there's a will, there's a slay.**

Grandpa Lucky Snatchwick left you a will, a cabin on Kettle Hill, and a mountain that still has his stuff. Nib — the imp executor — walks you home. The path fills with teeth. Then the real work starts: delve Mount Grumblegut, spin the dungeon wheel, and bring curiosities home to the Snatchwick Cabinet of Considerable Curiosities.

## What you do

- **Spin the wheel.** Six monsters around you. Spin to face one. Read them. Plan your hand.
- **Use it, Keep it, or lose your head.** Items hit, block, defeat, or bend the rules. Some you Keep for the next fight — if you bleed for them.
- **Move without Spinning.** Three Moves a dungeon step you to the next seat without triggering a Spin.
- **Bank or Push at Grandpa's rope.** After a clear, Climb the tagged rope ladder to **Bank home**, or open the cavern gate to **Push deeper** with your sack. Die, and none of it comes home. Fill a biome's cabinet (5 uniques) before Nib lets you push past that belly.
- **Fill five biomes.** Verdant Hollow → Crystal Cavern → Ashen Crypt → Cinder Forge → Shadow Abyss. Endless stays sealed until every cabinet is full.

## Playtest notes

This page is the **friends playtest** build (Godot 4.7 web).

- Hub: **Brand New**, **Middle Progress**, **Continue**, **Feedback**.
- Right-click any item or monster to leave a note. **F2** opens Feedback. A phone voice memo while you play is gold.
- Expect sharp edges. Be picky. Break combos. Tell us what confused you.

## Controls (web)

Mouse to play. Space advances some talk. Shift holds inspect detail where the game offers it.

Made with Godot 4. Art and audio are CC0 sources credited in-cabin (Patents Pending).
```

### Optional one-line under the embed

`Playtest · Stop if it soft-locks · F2 sends notes straight to the inbox`

---

## 3. Tags / classification notes

itch does not have a single rigid taxonomy; use these as checklist picks when editing the page.

| Field | Tip-grounded suggestion | Notes |
|---|---|---|
| **Kind of project** | Game | |
| **Release status** | In development / Playtesting | Do not mark Released. |
| **Genre** | Strategy, Adventure | Wheel-spin combat + cabin / map meta. Avoid “Deckbuilder” unless you add a clarifying custom tag — loot is a hotbar, not a drawn deck in the Slay-the-Spire sense. |
| **Tags (multi)** | `roguelike`, `turn-based`, `pixel-art`, `dungeon`, `singleplayer`, `browser`, `webgl`, `godot`, `prototype`, `playtest` | `roguelike` = per-delve risk (death loses the haul) + biome climb; not a procedural overworld. |
| **Inputs** | Mouse | Keyboard assists (Space / Shift / F2). |
| **Platforms** | HTML5 | Web Playtest preset only for friends. |
| **Pricing** | Free | Playtest. |
| **Content warnings** | Cartoon violence, mild fantasy peril | No blood-porn; monster fight game. |
| **Custom / vibe words** | inheritance, cabin, trophy hall, spin, will | Match locked names; don’t invent new mode names. |

**Classification traps to avoid**

- Do not tag or describe **Challenge Mode / Long Drop** or **Gatehouse Adventure** as current modes.
- Do not promise Steam / desktop download on this page (exports are Web + Web Playtest only).
- Do not put the word **Tier** or **ATK** in store copy.

---

## 4. Recommended screenshot / GIF shot list (10)

Capture in-game at **1680×1040** (project viewport), nearest / pixel-faithful. Prefer GIFs for motion rows; stills OK where noted. Pixel owns framing and export.

| # | Moment | Where / how to reach | Still or GIF | Why it sells |
|---|---|---|---|---|
| 1 | **Playtest hub** | Boot F5 / Web Playtest → hub with Brand New / Middle Progress / Continue / Feedback | Still | Honest first frame friends see. |
| 2 | **Road ambush + tutorial ask** | Brand New → after intro stills → road frame ambush → Yes/Skip overlay | GIF (~4–6s) | First drama; Nib’s road; choice to learn. |
| 3 | **Tutorial wheel mid-fight** | Yes on tutorial → Spin / hotbar / Nib chrome visible (e.g. after first Defeat or Block teach) | GIF (~5–8s) | Teaches the verb without cabin chrome. |
| 4 | **Cabin Front Room** | Post-tutorial arrive (or Skip → arrive) → free cabin, Nib visible | Still | Cozy fantasy hook; “home base.” |
| 5 | **Grandpa’s Map (held)** | Cabin → Grandpa’s Map / Outpost map → living parchment with Verdant START and patrol Deadlies | GIF (~4–6s) | Biome climb + living map is unique. |
| 6 | **Biome splash → delve** | Start Verdant Hollow (or next unlocked) → splash narration → dissolve into wheel | GIF (~5–7s) | Atmosphere; proves biomes are real. |
| 7 | **Wheel Spin landing** | Any delve → Spin → pointer settles → intent / ability moment | GIF (~3–5s) | Core loop icon. Cover-GIF candidate. |
| 8 | **Hotbar plan (Keep / Move)** | Fight with Keep-greyed item and Move pips visible (tutorial end or early Verdant) | Still or short GIF | Shows depth beyond “click damage.” |
| 9 | **Rope Exit diegetic** | Clear a dungeon → Rope Exit cavern: rope ladder + gate + Bank/Push chrome + cabinet chip | GIF (~5–8s) | Bank vs Push decision; signature screen. |
| 10 | **Trophy Hall cabinets** | Bank home with new uniques → hall cases / extract banner / `{n}/5` progress | Still | Meta goal; “fill the cabinets.” |

### Optional extras (if Pixel has room)

| # | Moment | Notes |
|---|---|---|
| 11 | **Push blocked by Nib** | Hover Push under 5/5 → interrupt → home to that biome’s case | Shows the cabinet gate without a paragraph. |
| 12 | **Deeper biome look** | Crystal Cavern or Ashen Crypt wheel + ambient | Proves the mountain changes; don’t fake art. |

### Capture notes for Pixel

- Prefer **Brand New** for shots 2–3; **Middle Progress** can speed 5–10 if cabinets/map are already open.
- Do not shoot editor filesystem, Roster (F6), or debug Quick Start chrome.
- Avoid UI that shows **Tier** / **ATK** labels; crop or use player inspect copy.
- Cover GIF recommendation: **#7** (Spin landing) or **#9** (Rope Exit). First page image should be gameplay motion, not logo-only.

---

## 5. Trailer beat sheet (15–30 seconds)

Silent-friendly; assume itch autoplay muted until click. Target **20–24s**. No invented modes.

| Time | Visual | On-screen text (optional) | Audio cue |
|---|---|---|---|
| 0.0–2.0 | Black → title card **Spinheritance** | Where there's a will, there's a slay. | Soft cabin / title sting |
| 2.0–5.0 | Road approach → ambush still shakes → teeth on the path | The path fills with teeth. | Ambush sting |
| 5.0–9.0 | Tutorial / early wheel: Spin → land → one clean Defeat | Spin the dungeon. | Wheel tick + hit |
| 9.0–12.0 | Hotbar use + Keep grey + Move step (no Spin poke) | Use it. Keep it. Move. | Item + Move |
| 12.0–16.0 | Biome splash (Verdant) → dissolve → mid-fight wheel with Deadly on the ring | Mount Grumblegut has five bellies. | Biome music hit |
| 16.0–21.0 | Rope Exit: peek sack → hover Climb vs Push → Bank wipe up the shaft **or** gate open deeper | Bank home — or Push deeper. | Rope / gate |
| 21.0–24.0 | Trophy Hall case filling / map wax stamps lighting | Bring his things home. | Homecoming sting |
| 24.0–26.0 | Playtest hub or cabin idle + URL | Playtest live · F2 feedback | Soft out |

**Hard cuts:** never linger on menus >1.5s except the final CTA. No Challenge/Gatehouse archive UI. No “Tier list” screen in the trailer (save that for playtest friends who already know).

**Alt 15s cut:** 0–2 title · 2–6 Spin fight · 6–10 Rope Exit · 10–13 cabinets · 13–15 CTA.

---

## 6. Butler / existing itch copy

- No prior `playtest/itch/*` copy file existed on tip; this pack is the new home for reception drafts.
- **Do not** change export presets, `addons/build_stamp`, or butler scripts in this PR.
- Friends page remains `nathan-elequin/spinheritance-playtest` channel `html5`. Do not promote to `nathan-elequin/swipe` without an explicit **promote**.
- Applying this text on itch is a manual dashboard edit (or a later Nathan-asked upload pass). This PR only lands the markdown.

---

## 7. Handoff

| Who | Does |
|---|---|
| **Nathan** | Approves which short blurb (A/B/C) and whether the long description goes live as-is. |
| **Pixel** | Captures #1–#10 (and optional #11–#12); picks cover GIF; does not rewrite locked names. |
| **Cursor (this PR)** | Copy + shot list only. No merge required from the authoring agent. |
