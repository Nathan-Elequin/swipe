#!/usr/bin/env bash
# Juggernaut next_run seed scan + fresh-seed entropy selftest.
# Usage (repo root):
#   ./tools/qa/run_juggernaut_seed_scan.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_juggernaut_seed_scan.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for c in \
    "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "$HOME/Godot_v4.7.2-stable_linux.x86_64" \
    "/tmp/godot/Godot_v4.7.2-stable_linux.x86_64" \
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
  echo "Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_*." >&2
  exit 2
fi

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/juggernaut_seed_scan_selftest.gd
CODE=$?
set -e
if [[ "$CODE" -ne 0 ]]; then
  echo "JUGGERNAUT_SEED_SCAN failed (exit $CODE)" >&2
  exit "$CODE"
fi
echo "JUGGERNAUT_SEED_SCAN local run OK"
exit 0
