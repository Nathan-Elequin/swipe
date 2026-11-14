#!/usr/bin/env bash
# Flow overhaul selftest — first-return gating, first-light pause, dead portal.
# Usage (repo root):
#   ./tools/qa/run_flow_overhaul.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_flow_overhaul.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/flow-overhaul.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT
export XDG_DATA_HOME="$WORKDIR/xdg-data"
mkdir -p "$XDG_DATA_HOME"

echo "=== flow_overhaul_selftest ==="
set +e
OUT="$("$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/flow_overhaul_selftest.gd 2>&1)"
CODE=$?
set -e
echo "$OUT"
if echo "$OUT" | grep -q "FLOW_OVERHAUL_OK"; then
  echo "flow_overhaul: OK"
  exit 0
fi
echo "flow_overhaul: FAIL (exit $CODE)" >&2
exit 1
