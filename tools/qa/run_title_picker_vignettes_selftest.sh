#!/usr/bin/env bash
# Headless New Game picker card vignette selftest.
# Usage (repo root):
#   ./tools/qa/run_title_picker_vignettes_selftest.sh
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
    "godot"
  do
    if command -v "$c" >/dev/null 2>&1 || [[ -x "$c" ]]; then
      GODOT_BIN="$c"
      break
    fi
  done
fi

if [[ -z "${GODOT_BIN}" ]] || { ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; }; then
  echo "Godot 4.7.x not found." >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/title-picker-vignettes-selftest.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
export XDG_DATA_HOME="$WORKDIR/xdg-data"
mkdir -p "$XDG_DATA_HOME"

echo "=== title_picker_vignettes_selftest ==="
set +e
OUT="$("$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/title_picker_vignettes_selftest.gd 2>&1)"
CODE=$?
set -e
echo "$OUT"
if echo "$OUT" | grep -q "TITLE_PICKER_VIGNETTES_OK"; then
  echo "title_picker_vignettes_selftest: OK"
  exit 0
fi
echo "title_picker_vignettes_selftest: FAIL (exit $CODE)" >&2
exit 1
