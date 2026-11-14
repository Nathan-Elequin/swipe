#!/usr/bin/env bash
# Package D board gates selftest — headless.
# Usage (repo root):
#   ./tools/qa/run_board_gates.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_board_gates.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/board-gates.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

IMPORT_OUT="$WORKDIR/import.out"
OUT="$WORKDIR/selftest.out"

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$IMPORT_OUT" 2>&1
IMP=$?
set -e
if [[ "$IMP" -ne 0 ]]; then
  echo "Note: --import exited $IMP (continuing; see $IMPORT_OUT)"
fi

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/board_gates_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- board_gates_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
if grep -q 'BOARD_GATES_FAIL' "$OUT"; then
  echo "BOARD_GATES failed (BOARD_GATES_FAIL in output; exit $CODE)" >&2
  exit 1
fi
if [[ "$CODE" -ne 0 ]]; then
  echo "BOARD_GATES failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'BOARD_GATES_OK' "$OUT"; then
  echo "BOARD_GATES missing OK mark" >&2
  exit 1
fi
echo "BOARD_GATES local run OK"
exit 0
