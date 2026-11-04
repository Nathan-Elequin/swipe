# Spinheritance offline balance Monte Carlo

Generated **2026-11-04 19:21 UTC** · seed `7` · trials/pair `250` · duel rows `290000`

Pure-data Python sim (`tools/sim/`). Catalog numbers were **not** changed.
See `tools/sim/ASSUMPTIONS.md` for engine-parity gaps.

## Item coverage

- Supported ops in sim: **29/67** live items
- Unsupported (ignored by bot): `grimoire`, `knucklers`, `poison_flask`, `cursed_scroll`, `spider_egg`, `pocketwatch`, `grappling_hook`, `grief_jar`, `mirror_shard`, `echo_bell`, `quiet_bell`, `iron_chain`, `counting_beads`, `last_match`, `measuring_tape`, `mute_stone`, `shuriken`, `miasma`, `bag_of_marbles`, `marble`, `hex`, `ale_flagon`, `napalm`, `lucky_nickel` … +14 more

## Focus monsters — named loadouts

| monster | model | mean win | min | max | mean HP left | mean turns |
|---|---|---:|---:|---:|---:|---:|
| `bandit` | simplified | 100.0% | 100.0% | 100.0% | 6.00 | 1.42 |
| `dire_wolf` | simplified | 91.7% | 0.0% | 100.0% | 5.67 | 2.00 |
| `dragon` | full | 58.3% | 0.0% | 100.0% | 3.17 | 3.17 |
| `goblin` | full | 100.0% | 100.0% | 100.0% | 5.50 | 1.83 |
| `golem` | stats_only | 100.0% | 100.0% | 100.0% | 5.75 | 2.75 |
| `harpy` | full | 100.0% | 100.0% | 100.0% | 3.42 | 2.25 |
| `hornet_swarm` | full | 100.0% | 100.0% | 100.0% | 6.00 | 1.42 |
| `mimic` | stats_only | 100.0% | 100.0% | 100.0% | 5.42 | 2.83 |
| `needleback` | stats_only | 100.0% | 100.0% | 100.0% | 5.75 | 2.08 |
| `ogre` | stats_only | 100.0% | 100.0% | 100.0% | 5.33 | 2.83 |
| `shark` | full | 100.0% | 100.0% | 100.0% | 5.17 | 2.92 |
| `slime_boss` | simplified | 83.3% | 0.0% | 100.0% | 3.92 | 3.08 |
| `vampire` | stats_only | 100.0% | 100.0% | 100.0% | 5.58 | 2.08 |
| `wizard` | stats_only | 100.0% | 100.0% | 100.0% | 6.00 | 1.50 |

Full named×focus grid: [`heatmap_focus.md`](heatmap_focus.md). Machine-readable: [`heatmap.csv`](heatmap.csv), [`summary.csv`](summary.csv).

## Ladder smoke (80 trials each)

| loadout | ladder | clear rate | mean HP end | top deaths |
|---|---|---:|---:|---|
| `t1_knife_shield_sai_net` | `pool1_mix_a` | 0.0% | 0.00 | hornet_swarm×80 |
| `t1_knife_shield_sai_net` | `pool1_mix_b` | 0.0% | 0.00 | shark×80 |
| `t1_knife_shield_sai_net` | `focus_gauntlet` | 0.0% | 0.00 | dragon×80 |
| `t2_fangs_boot_shield_net` | `pool1_mix_a` | 0.0% | 0.00 | dragon×80 |
| `t2_fangs_boot_shield_net` | `pool1_mix_b` | 100.0% | 3.00 | — |
| `t2_fangs_boot_shield_net` | `focus_gauntlet` | 0.0% | 0.00 | dragon×80 |
| `t2_flail_breastplate_knife_shield` | `pool1_mix_a` | 0.0% | 0.00 | hornet_swarm×80 |
| `t2_flail_breastplate_knife_shield` | `pool1_mix_b` | 0.0% | 0.00 | shark×80 |
| `t2_flail_breastplate_knife_shield` | `focus_gauntlet` | 0.0% | 0.00 | shark×80 |
| `cheese_boot_sledge_fangs_smoke` | `pool1_mix_a` | 100.0% | 2.00 | — |
| `cheese_boot_sledge_fangs_smoke` | `pool1_mix_b` | 0.0% | 0.00 | shark×80 |
| `cheese_boot_sledge_fangs_smoke` | `focus_gauntlet` | 100.0% | 3.00 | — |

## Design-review candidates (do not auto-nerf)

Tankable monsters (no pierce / multi-swing) often show ~100% duel win under `one_encounter_then_gone` — that is expected and filtered out. See ASSUMPTIONS.

**63** flagged pairs. Listed below (also `outliers.md`):

1. `t2_fangs_crossbow_helmet_medallion` vs `dragon` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%); Fangs into Dragon pierce is lethal at full HP without potion
2. `t2_flail_breastplate_knife_shield` vs `dragon` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%)
3. `t2_gauntlets_helmet_fangs_shield` vs `dragon` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%); Fangs into Dragon pierce is lethal at full HP without potion
4. `t2_lantern_flail_breastplate_knife` vs `dragon` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%)
5. `t1_bracers_knife_shield_boot` vs `slime_boss` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%)
6. `t2_lantern_flail_breastplate_knife` vs `slime_boss` — win 0.0%, death 100.0%, mean HP 0.00 — near-unwinnable (death>=85%)
7. `block_wall_shield_breastplate_net_helmet` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
8. `cheese_boot_sledge_fangs_smoke` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
9. `t1_boot_net_shield_knife` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
10. `t1_bracers_knife_shield_boot` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
11. `t1_knife_shield_sai_net` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
12. `t2_fangs_boot_shield_net` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
13. `t2_fangs_crossbow_helmet_medallion` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
14. `t2_flail_breastplate_knife_shield` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
15. `t2_gauntlets_helmet_fangs_shield` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
16. `t2_sledge_knife_net_potion` vs `dire_wolf` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
17. `block_wall_shield_breastplate_net_helmet` vs `dragon` — win 100.0%, death 0.0%, mean HP 1.00 — Dragon beaten without Defeat tools (Net-down ATK or raw kill) — check pierce
18. `cheese_boot_sledge_fangs_smoke` vs `dragon` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
19. `t1_boot_net_shield_knife` vs `dragon` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
20. `t1_bracers_knife_shield_boot` vs `dragon` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
21. `t1_knife_shield_sai_net` vs `dragon` — win 100.0%, death 0.0%, mean HP 1.00 — Dragon beaten without Defeat tools (Net-down ATK or raw kill) — check pierce
22. `t2_fangs_boot_shield_net` vs `dragon` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
23. `t2_sledge_knife_net_potion` vs `dragon` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5); Dragon beaten without Defeat tools (Net-down ATK or raw kill) — check pierce
24. `cheese_boot_sledge_fangs_smoke` vs `harpy` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
25. `t2_fangs_boot_shield_net` vs `harpy` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
26. `t2_fangs_crossbow_helmet_medallion` vs `harpy` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
27. `t2_gauntlets_helmet_fangs_shield` vs `harpy` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
28. `block_wall_shield_breastplate_net_helmet` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
29. `cheese_boot_sledge_fangs_smoke` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
30. `t1_boot_net_shield_knife` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
31. `t1_bracers_knife_shield_boot` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
32. `t1_knife_shield_sai_net` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
33. `t1_teach_knife_shield_net_smoke` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
34. `t2_fangs_boot_shield_net` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
35. `t2_fangs_crossbow_helmet_medallion` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
36. `t2_flail_breastplate_knife_shield` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
37. `t2_gauntlets_helmet_fangs_shield` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
38. `t2_lantern_flail_breastplate_knife` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
39. `t2_sledge_knife_net_potion` vs `hornet_swarm` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
40. `block_wall_shield_breastplate_net_helmet` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
41. `cheese_boot_sledge_fangs_smoke` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
42. `t1_boot_net_shield_knife` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
43. `t1_bracers_knife_shield_boot` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
44. `t2_fangs_boot_shield_net` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
45. `t2_fangs_crossbow_helmet_medallion` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
46. `t2_gauntlets_helmet_fangs_shield` vs `shark` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
47. `t2_lantern_flail_breastplate_knife` vs `shark` — win 100.0%, death 0.0%, mean HP 5.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
48. `block_wall_shield_breastplate_net_helmet` vs `slime_boss` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
49. `cheese_boot_sledge_fangs_smoke` vs `slime_boss` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)
50. `t2_fangs_boot_shield_net` vs `slime_boss` — win 100.0%, death 0.0%, mean HP 6.00 — pressure monster trivialized (wr>=98%, mean HP>=4.5)

## How to re-run

```bash
python3 tools/sim/balance_mc.py --trials 300 --seed 7 --out playtest/balance
```

## Next human steps

1. Read flagged pairs; decide if the *card* or the *hand composition* is the problem.
2. If a number should move, change it in Roster / catalog in a separate PR — not here.
3. Extend `SUPPORTED_OPS` when a Pool-2+ card becomes balance-critical.
