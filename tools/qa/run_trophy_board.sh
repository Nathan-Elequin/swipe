#!/usr/bin/env bash
# Trophy board Package B — model selftest + optional shots.
# Usage (repo root):
#   ./tools/qa/run_trophy_board.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_trophy_board.sh
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
  echo "Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_* (matches project.godot features)." >&2
  exit 2
fi

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >/tmp/trophy-board-import.out 2>&1
IMP=$?
set -e
if [[ "$IMP" -ne 0 ]]; then
  echo "Note: --import exited $IMP (continuing; see /tmp/trophy-board-import.out)"
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/trophy-board.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
OUT="$WORKDIR/selftest.out"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/trophy_board_model_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- trophy_board_model_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
if [[ "$CODE" -ne 0 ]]; then
  echo "TROPHY_BOARD_MODEL failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'TROPHY_BOARD_MODEL_OK' "$OUT"; then
  echo "TROPHY_BOARD_MODEL missing OK mark" >&2
  exit 1
fi

SHOT_OUT="$WORKDIR/shots.out"
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/trophy_board_shots.gd >"$SHOT_OUT" 2>&1
SHOT=$?
set -e
echo "----- trophy_board_shots.gd (exit $SHOT) -----"
cat "$SHOT_OUT"
echo "----- end -----"
if [[ "$SHOT" -ne 0 ]]; then
  echo "TROPHY_BOARD_SHOTS failed (exit $SHOT) — model still OK" >&2
  exit "$SHOT"
fi

echo "TROPHY_BOARD local run OK"
exit 0
