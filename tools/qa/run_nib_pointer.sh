#!/usr/bin/env bash
# Nib pointer dock/clear + cog seat + padlock order selftest.
# Usage (repo root):
#   ./tools/qa/run_nib_pointer.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_nib_pointer.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/nib-pointer.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
export XDG_DATA_HOME="$WORKDIR/xdg-data"
export XDG_CONFIG_HOME="$WORKDIR/xdg-config"

"$GODOT_BIN" --headless --path "$ROOT" --import >/tmp/nib-pointer-import.out 2>&1 || true

OUT="$WORKDIR/selftest.out"
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/nib_pointer_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- nib_pointer_selftest.gd (exit $CODE) -----"
cat "$OUT"
exit "$CODE"
