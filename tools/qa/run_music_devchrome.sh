#!/usr/bin/env bash
# Music cutback + DevChrome toggle selftest.
# Usage (repo root):
#   ./tools/qa/run_music_devchrome.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_music_devchrome.sh
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
  echo "Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_*." >&2
  exit 2
fi

OUT="$(mktemp)"
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/music_devchrome_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
cat "$OUT"
if grep -q "MUSIC_DEVCHROME_OK" "$OUT"; then
  echo "MUSIC_DEVCHROME local run OK"
  exit 0
fi
echo "MUSIC_DEVCHROME failed (exit $CODE)" >&2
exit 1
