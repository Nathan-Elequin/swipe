#!/usr/bin/env bash
# House unlock after first successful full dungeon return — isolated selftest.
# Does not write Nathan's live Godot userdata.
#
# Usage (repo root):
#   ./tools/qa/run_house_unlock_first_return.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_house_unlock_first_return.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for c in \
    "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "$HOME/Godot_v4.7.2-stable_linux.x86_64" \
    "/tmp/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "${RUNNER_TEMP:-/tmp}/godot/Godot_v4.7.2-stable_linux.x86_64" \
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
  echo "RUNTIME_UNAVAILABLE: Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_*." >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/house-unlock-first-return.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

export XDG_DATA_HOME="$WORKDIR/xdg-data"
export XDG_CONFIG_HOME="$WORKDIR/xdg-config"
export XDG_CACHE_HOME="$WORKDIR/xdg-cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
export HOME="$WORKDIR/fake-home"
mkdir -p "$HOME"

OUT="$WORKDIR/selftest.out"
echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
echo "Isolated XDG_DATA_HOME=$XDG_DATA_HOME"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$WORKDIR/import.out" 2>&1
set -e

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/house_unlock_first_return_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- house_unlock_first_return_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"

if [[ "$CODE" -ne 0 ]]; then
  echo "HOUSE_UNLOCK_FIRST_RETURN failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'HOUSE_UNLOCK_FIRST_RETURN_OK' "$OUT"; then
  echo "HOUSE_UNLOCK_FIRST_RETURN missing OK mark" >&2
  exit 1
fi
for need in \
  TUT.no_haul_credit \
  TUT.rooms_stay_main \
  LOSS.no_haul \
  LOSS.rooms_stay_main \
  WIN0.haul_and_key_due \
  WIN3.haul_and_key_due \
  RECOVER.partial_fills_rest \
  SAFE.save_noop_same_meta
do
  if ! grep -q "PASS ASSERT $need" "$OUT"; then
    echo "HOUSE_UNLOCK_FIRST_RETURN missing/failed assert $need" >&2
    exit 1
  fi
done
echo "HOUSE_UNLOCK_FIRST_RETURN local run OK (isolated; fresh-save GUI still UNCOVERED)"
exit 0
