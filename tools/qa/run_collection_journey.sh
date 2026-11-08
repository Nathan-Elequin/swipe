#!/usr/bin/env bash
# Journey A collection state projection selftest — headless, no real save I/O.
# Usage (repo root):
#   ./tools/qa/run_collection_journey.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_collection_journey.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/collection-journey.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

OUT="$WORKDIR/selftest.out"
echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/collection_journey_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- collection_journey_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
if [[ -n "${COLLECTION_JOURNEY_LOG:-}" ]]; then
  cp "$OUT" "$COLLECTION_JOURNEY_LOG"
fi
if [[ "$CODE" -ne 0 ]]; then
  echo "COLLECTION_JOURNEY failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'COLLECTION_JOURNEY_OK' "$OUT"; then
  echo "COLLECTION_JOURNEY missing OK mark" >&2
  exit 1
fi
echo "COLLECTION_JOURNEY local run OK"
exit 0
