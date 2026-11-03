---
id: REQ-20261103-look-c-in-chrome-tags
status: open
priority: high
branch: cursor/look-c-in-chrome-tags-a83f
base: playtest/latest
created: 2026-11-03T06:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → fight with Throwing Knife, Net, Sling, Crossbow, and Hired Hand when available
---

# Look C — in-chrome mode tags (combat selector)

Visual/UI only. Mode language C: Knife / Net / Magnet options render as cream tags **inside** the starter item card under the sprite (same seat height). Clone choice tiles over other hotbar seats are gone. Cancel X, dim, CHOICE toss aura, Take Decline/Continue, and wheel aim must still work. Doop refs: https://doop.design/c/8a-B18k4cY (C1 Knife, C2 Net×3, D1 hand pick, E1 Hired Hand Decline, F1 Crossbow).

## What to verify

- Throwing Knife second click: two cream tags on the Knife seat (“ATK 3, discard” / “ATK 1, keep”); no floating ItemCard clones above the bar; sprite shrinks a touch; card height matches idle seats; cancel X top-right; other seats dimmed; CHOICE aura on Knife.
- Net second click: three crammed tags (−1/−2/−3 Attack); slight sprite overlap OK; same seat height; no clones.
- Magnet (if same choose path): three in-chrome tags (Highest / Lowest / Off); no clones.
- Sling / overfill toss: CHOICE aura on legal hand cards + cancel X on starter; no mode/clone tiles over seats.
- Hired Hand: cream Take arc reads Decline; glowing pay targets; no Feedback mode pills.
- Crossbow wheel aim: legal seats glow CHOICE; hand dims; cancel X on Crossbow; no monster names on hotbar.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Use Throwing Knife → mode open | Two cream tags on Knife; cancel X; dims; no clone tiles over seats | 01-knife-look-c.png |
| 02 | fight | Use Net → mode open | Three cream tags on Net; same height; no clones | 02-net-look-c.png |
| 03 | fight | Use Sling → pick open | CHOICE on legal cards; cancel X on Sling; illegal dim | 03-sling-hand-pick.png |
| 04 | fight | Hired Hand offer | Take arc = Decline; CHOICE on pay targets | 04-hired-hand-decline.png |
| 05 | fight | Use Crossbow → aim | Wheel seats glow; hand dim; cancel on Crossbow | 05-crossbow-wheel.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- No ItemCard clones floating above the hotbar for Knife/Net/Magnet.
- Tags readable inside starter chrome; card height unchanged vs idle neighbors.
- Cancel / dim / CHOICE toss / Decline / wheel aim still match the locked mocks.

## Outbox path

`playtest/repot/outbox/REQ-20261103-look-c-in-chrome-tags/`
