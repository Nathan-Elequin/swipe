# Facing edge report

Read-only check from `tools/check_facing_edges.py`. Opaque means alpha > 0.
A frame is flagged when the left column, right column, or top row has 2 or more opaque pixels. The bottom row is allowed (feet).

rust_bucket frames have a flat grey backdrop that `_knock_backdrop` (`scripts/dungeon_art.gd` L446-479) clears before the portrait is shown. Edge hits on that backdrop are expected.

shark is not flagged. On every frame the opaque box starts at x=2, so the left and right columns are empty, and the top row is empty too.

Ids scanned: 58. Frames scanned: 232. Flagged ids: 43.

Flagged: almighty_worm, amalgam, anvil, beggar, berserker, bodyguard, bushido, cleric, clockwork_knight, cowardly_king, cultist, death_bell, dire_wolf, dragon, druid, eel, fairy, gargoyle, gelatinous_cube, goblin, golem, hired_hand, hydra, kobold_trapper, leech_league, magicat, martyr, merchant, mimic, mouse, needleback, phoenix, phoenix_egg, plague_doctor, prism, rust_bucket, shambling_mound, slime_boss, spider_queen, triclops, vampire, wraith, zombie

| id | canvas | bbox | L | R | T | flagged |
| --- | --- | --- | --- | --- | --- | --- |
| almighty_worm | 64x64 | f0 0,4 64x60, f1 0,6 64x58, f2 0,5 64x59, f3 0,4 64x60 | 6 | f0 8, f1 7, f2 8, f3 8 | 0 | yes |
| amalgam | 64x64 | 0,0 64x64 | f0 36, f1 36, f2 37, f3 37 | f0 44, f1 43, f2 43, f3 43 | f0 27, f1 22, f2 22, f3 31 | yes |
| anvil | 48x48 | 0,1 48x47 | 25 | 25 | 0 | yes |
| bandit | 48x48 | f0 1,2 46x46, f1 1,3 46x45, f2 1,2 46x46, f3 1,1 46x47 | 0 | 0 | 0 | no |
| basilisk | 64x64 | f0 3,2 58x62, f1 3,3 58x61, f2 1,3 61x61, f3 3,2 58x62 | 0 | 0 | 0 | no |
| beggar | 48x48 | f0 0,1 48x47, f1 0,0 48x48, f2 0,0 48x48, f3 0,0 48x48 | f0 36, f1 36, f2 35, f3 34 | f0 43, f1 44, f2 43, f3 41 | f0 0, f1 4, f2 4, f3 4 | yes |
| berserker | 48x48 | f0 1,2 46x46, f1 0,3 47x45, f2 1,2 46x46, f3 1,1 45x47 | f0 0, f1 15, f2 0, f3 0 | 0 | 0 | yes |
| bodyguard | 48x48 | f0 0,2 48x46, f1 0,2 48x46, f2 0,1 48x47, f3 0,0 48x48 | f0 7, f1 21, f2 21, f3 21 | f0 14, f1 14, f2 15, f3 16 | f0 0, f1 0, f2 0, f3 11 | yes |
| bushido | 48x48 | f0 0,2 48x46, f1 0,3 48x45, f2 0,3 48x45, f3 0,1 48x47 | f0 13, f1 13, f2 13, f3 14 | f0 16, f1 16, f2 15, f3 15 | 0 | yes |
| cleric | 48x48 | f0 0,2 47x46, f1 0,1 47x47, f2 0,0 47x48, f3 0,0 47x48 | f0 4, f1 4, f2 5, f3 6 | 0 | f0 0, f1 0, f2 5, f3 10 | yes |
| clockwork_knight | 64x64 | 0,1 63x63 | 15 | 0 | 0 | yes |
| commander | 64x64 | f0 8,1 47x63, f1 9,2 46x62, f2 8,2 47x62, f3 9,3 46x61 | 0 | 0 | 0 | no |
| cowardly_king | 64x64 | 2,0 60x64 | 0 | 0 | 4 | yes |
| cultist | 48x48 | f0 0,1 48x47, f1 0,0 48x48, f2 0,0 48x48, f3 0,0 48x48 | 27 | f0 35, f1 36, f2 36, f3 36 | f0 0, f1 17, f2 17, f3 17 | yes |
| death_bell | 64x64 | 0,1 64x63 | 26 | 29 | 0 | yes |
| dire_wolf | 48x48 | 0,0 47x48 | f0 42, f1 42, f2 43, f3 43 | 0 | 2 | yes |
| dragon | 64x64 | f0 1,13 62x51, f1 1,11 62x53, f2 0,11 63x53, f3 0,13 64x51 | f0 0, f1 0, f2 37, f3 37 | f0 0, f1 0, f2 0, f3 4 | 0 | yes |
| druid | 48x48 | f0 0,2 48x46, f1 0,3 48x45, f2 0,2 48x46, f3 0,2 48x46 | f0 30, f1 30, f2 31, f3 33 | f0 21, f1 21, f2 21, f3 22 | 0 | yes |
| eel | 48x48 | f0 0,2 47x46, f1 1,1 46x47, f2 1,1 46x47, f3 1,1 46x47 | f0 11, f1 0, f2 0, f3 0 | 0 | 0 | yes |
| fairy | 48x48 | f0 0,2 48x46, f1 0,2 48x46, f2 0,2 48x46, f3 0,3 48x45 | f0 43, f1 43, f2 43, f3 38 | f0 45, f1 45, f2 45, f3 42 | 0 | yes |
| gargoyle | 48x48 | f0 0,4 48x44, f1 0,3 48x45, f2 0,2 48x46, f3 0,3 48x45 | f0 28, f1 26, f2 28, f3 26 | f0 31, f1 30, f2 30, f3 30 | 0 | yes |
| gelatinous_cube | 64x64 | 0,0 64x64 | 5 | 43 | f0 42, f1 42, f2 40, f3 40 | yes |
| goblin | 48x48 | f0 0,2 48x46, f1 0,2 48x46, f2 0,1 48x47, f3 0,1 48x47 | 36 | f0 37, f1 37, f2 38, f3 38 | 0 | yes |
| golem | 48x48 | f0 0,0 47x48, f1 1,0 45x48, f2 1,0 45x48, f3 1,0 45x48 | f0 13, f1 0, f2 0, f3 0 | 0 | f0 10, f1 10, f2 10, f3 9 | yes |
| harpy | 48x48 | f0 5,10 38x38, f1 4,9 39x39, f2 4,10 39x38, f3 4,10 39x38 | 0 | 0 | 0 | no |
| hired_hand | 48x48 | f0 0,1 48x47, f1 0,2 48x46, f2 0,2 48x46, f3 0,2 48x46 | f0 10, f1 9, f2 9, f3 9 | 10 | 0 | yes |
| hollow | 48x48 | f0 3,3 42x45, f1 3,4 42x44, f2 3,3 42x45, f3 3,2 42x46 | 0 | 0 | 0 | no |
| hornet_swarm | 48x48 | f0 0,31 47x17, f1 2,30 44x18, f2 2,30 44x18, f3 2,30 44x18 | f0 1, f1 0, f2 0, f3 0 | 0 | 0 | no |
| hydra | 64x64 | 0,0 64x64 | f0 36, f1 33, f2 34, f3 34 | f0 39, f1 39, f2 39, f3 38 | f0 12, f1 11, f2 11, f3 10 | yes |
| juggernaut | 64x64 | 4,1 56x63 | 0 | 0 | 0 | no |
| kobold_trapper | 48x48 | 0,2 48x46 | 38 | 16 | 0 | yes |
| leech_league | 64x64 | 0,0 64x64 | f0 62, f1 62, f2 61, f3 62 | f0 61, f1 61, f2 60, f3 61 | f0 14, f1 15, f2 5, f3 6 | yes |
| lich | 64x64 | f0 5,2 53x62, f1 5,3 53x61, f2 5,4 54x60, f3 5,3 53x61 | 0 | 0 | 0 | no |
| magicat | 48x48 | f0 0,2 48x46, f1 0,2 48x46, f2 0,2 48x46, f3 0,1 48x47 | 30 | f0 36, f1 37, f2 41, f3 35 | 0 | yes |
| martyr | 48x48 | 0,1 48x47 | f0 15, f1 16, f2 16, f3 16 | 30 | 0 | yes |
| merchant | 48x48 | 0,1 48x47 | 2 | 3 | 0 | yes |
| mimic | 48x48 | f0 0,1 48x47, f1 0,1 48x47, f2 0,0 48x48, f3 0,1 48x47 | f0 47, f1 47, f2 48, f3 47 | f0 47, f1 47, f2 48, f3 47 | f0 0, f1 0, f2 48, f3 0 | yes |
| mouse | 48x48 | 1,0 46x48 | 0 | 0 | f0 15, f1 15, f2 15, f3 17 | yes |
| needleback | 48x48 | f0 0,1 48x47, f1 0,2 48x46, f2 0,2 48x46, f3 0,2 48x46 | f0 31, f1 30, f2 32, f3 32 | f0 25, f1 26, f2 26, f3 26 | 0 | yes |
| ogre | 64x64 | f0 3,2 57x62, f1 3,2 58x62, f2 2,4 59x60, f3 2,3 59x61 | 0 | 0 | 0 | no |
| phoenix | 64x64 | f0 0,1 64x63, f1 0,2 64x62, f2 0,3 64x61, f3 0,3 64x61 | f0 35, f1 36, f2 37, f3 36 | f0 45, f1 45, f2 44, f3 44 | 0 | yes |
| phoenix_egg | 48x48 | 0,1 48x47 | 27 | f0 31, f1 31, f2 31, f3 30 | 0 | yes |
| plague_doctor | 48x48 | 0,1 48x47 | f0 17, f1 16, f2 16, f3 15 | f0 36, f1 34, f2 34, f3 36 | 0 | yes |
| poison_frog | 48x48 | f0 1,4 45x44, f1 1,5 45x43, f2 1,4 45x44, f3 1,3 45x45 | 0 | 0 | 0 | no |
| prism | 64x64 | f0 0,2 64x62, f1 0,4 64x60, f2 0,4 64x60, f3 0,1 64x63 | f0 18, f1 18, f2 17, f3 17 | f0 15, f1 15, f2 13, f3 15 | 0 | yes |
| rust_bucket | 48x48 | 0,0 48x48 | 32 | 32 | 48 | yes |
| shambling_mound | 48x48 | 0,1 48x47 | 41 | 43 | 0 | yes |
| shark | 64x64 | f0 2,11 60x53, f1 2,11 60x53, f2 2,10 60x54, f3 2,7 60x57 | 0 | 0 | 0 | no |
| skeleton | 48x48 | f0 1,2 45x46, f1 1,3 45x45, f2 1,2 45x46, f3 1,1 45x47 | 0 | 0 | 0 | no |
| slime_boss | 64x64 | 0,3 64x61 | 36 | 37 | 0 | yes |
| spider_queen | 64x64 | f0 0,3 64x61, f1 0,3 64x61, f2 0,3 64x61, f3 0,1 64x63 | 19 | 49 | 0 | yes |
| triclops | 48x48 | f0 0,2 48x46, f1 0,3 48x45, f2 0,2 48x46, f3 0,1 48x47 | f0 37, f1 37, f2 37, f3 38 | f0 39, f1 38, f2 39, f3 40 | 0 | yes |
| two_headed_serpent | 64x64 | f0 2,2 60x62, f1 2,2 60x62, f2 2,2 60x62, f3 2,1 60x63 | 0 | 0 | 0 | no |
| vampire | 64x64 | f0 0,3 64x61, f1 0,4 64x60, f2 0,4 64x60, f3 0,2 64x62 | f0 36, f1 37, f2 39, f3 36 | f0 41, f1 39, f2 41, f3 40 | 0 | yes |
| wick | 48x48 | f0 1,2 45x46, f1 1,3 45x45, f2 1,3 45x45, f3 1,2 45x46 | 0 | 0 | 0 | no |
| wizard | 48x48 | f0 2,2 44x46, f1 1,2 45x46, f2 1,3 45x45, f3 1,2 45x46 | 0 | 0 | 0 | no |
| wraith | 48x48 | f0 0,2 48x46, f1 0,2 48x46, f2 0,1 48x47, f3 0,0 48x48 | f0 28, f1 29, f2 30, f3 32 | f0 33, f1 34, f2 35, f3 36 | f0 0, f1 0, f2 0, f3 16 | yes |
| zombie | 48x48 | 0,2 48x46 | f0 6, f1 4, f2 5, f3 8 | f0 12, f1 11, f2 12, f3 13 | 0 | yes |
