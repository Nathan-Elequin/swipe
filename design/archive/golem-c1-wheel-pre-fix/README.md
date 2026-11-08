# golem-c1-wheel-pre-fix

Archived **before** SP-46 wheel path fix (2026-11-08).

- `golem_wheel_idle_f0..f3` — old armored 48×48 seats that `monster_wheel_frames` preferred over C1
- `golem_wheel_base` + `breathe_f0/f1` — C1 clay art at wrong native **24×24** (never reached while idle existed)

Live fix: wheel idle/base/breathe are 48×48 byte-copies of C1 facing idle (Weak/Tough seat size).
