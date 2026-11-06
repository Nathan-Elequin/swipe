#!/usr/bin/env bash
# Tip smoke — headless tutorial rail invariants (no F5 / no Autopilot play-agent).
# Usage (repo root):
#   ./tools/qa/run_tip_smoke.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_tip_smoke.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for c in \
    "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "$HOME/Godot_v4.7.2-stable_linux.x86_64" \
    "Godot_v4.7.2-stable_linux.x86_64" \
    "godot" \
    "/usr/local/bin/godot"
  do
    if command -v "$c" >/dev/null 2>&1 || [[ -x "$c" ]]; then
      GODOT_BIN="$c"
      break
    fi
  done
fi

if [[ -z "${GODOT_BIN}" ]] || { ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; }; then
  echo "Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_* (matches project.godot features)." >&2
  exit 2
fi

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true

# Import once so .godot/ exists (CI / fresh checkout). Ignore non-zero if already imported.
set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >/tmp/tip-smoke-import.out 2>&1
IMP=$?
set -e
if [[ "$IMP" -ne 0 ]]; then
  echo "Note: --import exited $IMP (continuing; see /tmp/tip-smoke-import.out)"
fi

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/tip_smoke_selftest.gd
CODE=$?
set -e
if [[ "$CODE" -ne 0 ]]; then
  echo "TIP_SMOKE failed (exit $CODE)" >&2
  exit "$CODE"
fi

# Phantom Shroud presentation (full-black curse veil) — headless card check.
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/phantom_shroud_selftest.gd
SHROUD=$?
set -e
if [[ "$SHROUD" -ne 0 ]]; then
  echo "PHANTOM_SHROUD_SMOKE failed (exit $SHROUD)" >&2
  exit "$SHROUD"
fi
echo "TIP_SMOKE local run OK"
exit 0
