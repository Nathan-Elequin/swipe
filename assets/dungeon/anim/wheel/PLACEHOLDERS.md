# Pass 6 wheel / facing placeholders

PixelLab art is not in yet. These files sit at the final paths so code can ship.
Overwrite in place on `art/wheel-monsters` (Task 4); no code change.

Method: current still (`assets/dungeon/extra/<id>.png`, stored at 4x) downscaled ÷4 to native, then nearest-resized to 24px tall (≤24×28) for wheel, and to a 48×48 (Weak/Tough) or 64×64 (Deadly) canvas for facing. Breathe f0/f1 are identical copies of the wheel base.

`name_tag.png` is a copy of `design/handoff/CURSOR-AGENT/art-source/layouts-pixellab/clean/plate9.png` (32×32, 9-slice 5px corners, no notch).
Medallions are blank 18px coins with a 1px `#1c1814` rim and the current SVG rasterised to 10px.

Live monsters: 58 (catalog minus `three_seeker`).

## Wheel + facing

- `wizard`: `wheel/wizard_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/wizard_facing_idle_f0..f3`
- `golem`: `wheel/golem_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/golem_facing_idle_f0..f3`
- `goblin`: `wheel/goblin_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/goblin_facing_idle_f0..f3`
- `skeleton`: `wheel/skeleton_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/skeleton_facing_idle_f0..f3`
- `hornet_swarm`: `wheel/hornet_swarm_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/hornet_swarm_facing_idle_f0..f3`
- `lich`: `wheel/lich_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/lich_facing_idle_f0..f3`
- `ogre`: `wheel/ogre_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/ogre_facing_idle_f0..f3`
- `vampire`: `wheel/vampire_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/vampire_facing_idle_f0..f3`
- `berserker`: `wheel/berserker_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/berserker_facing_idle_f0..f3`
- `dire_wolf`: `wheel/dire_wolf_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/dire_wolf_facing_idle_f0..f3`
- `bandit`: `wheel/bandit_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/bandit_facing_idle_f0..f3`
- `leech_league`: `wheel/leech_league_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/leech_league_facing_idle_f0..f3`
- `wraith`: `wheel/wraith_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/wraith_facing_idle_f0..f3`
- `mimic`: `wheel/mimic_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/mimic_facing_idle_f0..f3`
- `two_headed_serpent`: `wheel/two_headed_serpent_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/two_headed_serpent_facing_idle_f0..f3`
- `slime_boss`: `wheel/slime_boss_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/slime_boss_facing_idle_f0..f3`
- `spider_queen`: `wheel/spider_queen_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/spider_queen_facing_idle_f0..f3`
- `commander`: `wheel/commander_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/commander_facing_idle_f0..f3`
- `dragon`: `wheel/dragon_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/dragon_facing_idle_f0..f3`
- `needleback`: `wheel/needleback_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/needleback_facing_idle_f0..f3`
- `gelatinous_cube`: `wheel/gelatinous_cube_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/gelatinous_cube_facing_idle_f0..f3`
- `gargoyle`: `wheel/gargoyle_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/gargoyle_facing_idle_f0..f3`
- `harpy`: `wheel/harpy_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/harpy_facing_idle_f0..f3`
- `kobold_trapper`: `wheel/kobold_trapper_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/kobold_trapper_facing_idle_f0..f3`
- `clockwork_knight`: `wheel/clockwork_knight_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/clockwork_knight_facing_idle_f0..f3`
- `basilisk`: `wheel/basilisk_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/basilisk_facing_idle_f0..f3`
- `hollow`: `wheel/hollow_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/hollow_facing_idle_f0..f3`
- `beggar`: `wheel/beggar_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/beggar_facing_idle_f0..f3`
- `wick`: `wheel/wick_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/wick_facing_idle_f0..f3`
- `anvil`: `wheel/anvil_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/anvil_facing_idle_f0..f3`
- `bodyguard`: `wheel/bodyguard_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/bodyguard_facing_idle_f0..f3`
- `cowardly_king`: `wheel/cowardly_king_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/cowardly_king_facing_idle_f0..f3`
- `merchant`: `wheel/merchant_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/merchant_facing_idle_f0..f3`
- `juggernaut`: `wheel/juggernaut_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/juggernaut_facing_idle_f0..f3`
- `cleric`: `wheel/cleric_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/cleric_facing_idle_f0..f3`
- `martyr`: `wheel/martyr_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/martyr_facing_idle_f0..f3`
- `prism`: `wheel/prism_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/prism_facing_idle_f0..f3`
- `plague_doctor`: `wheel/plague_doctor_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/plague_doctor_facing_idle_f0..f3`
- `hired_hand`: `wheel/hired_hand_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/hired_hand_facing_idle_f0..f3`
- `hydra`: `wheel/hydra_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/hydra_facing_idle_f0..f3`
- `zombie`: `wheel/zombie_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/zombie_facing_idle_f0..f3`
- `triclops`: `wheel/triclops_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/triclops_facing_idle_f0..f3`
- `shambling_mound`: `wheel/shambling_mound_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/shambling_mound_facing_idle_f0..f3`
- `almighty_worm`: `wheel/almighty_worm_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/almighty_worm_facing_idle_f0..f3`
- `cultist`: `wheel/cultist_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/cultist_facing_idle_f0..f3`
- `bushido`: `wheel/bushido_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/bushido_facing_idle_f0..f3`
- `shark`: `wheel/shark_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/shark_facing_idle_f0..f3`
- `death_bell`: `wheel/death_bell_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/death_bell_facing_idle_f0..f3`
- `phoenix_egg`: `wheel/phoenix_egg_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/phoenix_egg_facing_idle_f0..f3`
- `phoenix`: `wheel/phoenix_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/phoenix_facing_idle_f0..f3`
- `amalgam`: `wheel/amalgam_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/amalgam_facing_idle_f0..f3`
- `fairy`: `wheel/fairy_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/fairy_facing_idle_f0..f3`
- `eel`: `wheel/eel_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/eel_facing_idle_f0..f3`
- `druid`: `wheel/druid_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/druid_facing_idle_f0..f3`
- `mouse`: `wheel/mouse_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/mouse_facing_idle_f0..f3`
- `magicat`: `wheel/magicat_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/magicat_facing_idle_f0..f3`
- `rust_bucket`: `wheel/rust_bucket_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/rust_bucket_facing_idle_f0..f3`
- `poison_frog`: `wheel/poison_frog_wheel_base.png`, `_breathe_f0`, `_breathe_f1`; `facing/poison_frog_facing_idle_f0..f3`

## UI

- `assets/ui/wheel/name_tag.png`
- `assets/ui/wheel/medallion_sparkles.png`
- `assets/ui/wheel/medallion_link.png`
- `assets/ui/wheel/medallion_users.png`
- `assets/ui/wheel/medallion_swords.png`
- `assets/ui/wheel/medallion_layers.png`
- `assets/ui/wheel/medallion_heart.png`
- `assets/ui/wheel/medallion_droplet.png`
- `assets/ui/wheel/medallion_ban.png`
- `assets/ui/wheel/medallion_rotate.png`
- `assets/ui/wheel/medallion_mountain.png`
- `assets/ui/wheel/medallion_footprints.png`
- `assets/ui/wheel/medallion_trending.png`
- `assets/ui/wheel/medallion_shield.png`
- `assets/ui/wheel/medallion_skull.png`
- `assets/ui/wheel/medallion_copy.png`
- `assets/ui/wheel/medallion_plus.png`
- `assets/ui/wheel/medallion_wand.png`
- `assets/ui/wheel/medallion_hammer.png`
- `assets/ui/wheel/medallion_sword.png`
- `assets/ui/wheel/medallion_palm.png`
