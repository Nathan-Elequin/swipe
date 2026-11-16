#!/usr/bin/env bash
# Biome unlock-all portal sequence selftest — headless.
# Usage (repo root):
#   ./tools/qa/run_biome_unlock_all.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_biome_unlock_all.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/biome-unlock-all.XXXXXX")"
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
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/biome_unlock_all_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- biome_unlock_all_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
if grep -q 'BIOME_UNLOCK_ALL_FAIL' "$OUT"; then
  echo "BIOME_UNLOCK_ALL failed" >&2
  exit 1
fi
if [[ "$CODE" -ne 0 ]]; then
  echo "BIOME_UNLOCK_ALL failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'BIOME_UNLOCK_ALL_OK' "$OUT"; then
  echo "BIOME_UNLOCK_ALL missing OK mark" >&2
  exit 1
fi
echo "BIOME_UNLOCK_ALL local run OK"
exit 0
