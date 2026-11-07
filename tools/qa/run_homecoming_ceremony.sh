#!/usr/bin/env bash
# Homecoming ceremony ownership + Verdant haul-gate selftest.
# Usage (repo root):
#   ./tools/qa/run_homecoming_ceremony.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_homecoming_ceremony.sh
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
  echo "RUNTIME_UNAVAILABLE: Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_*." >&2
  echo "Source-only fallback still runs: python3 tools/qa/check_cabinet_homecoming.py" >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/homecoming-ceremony.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

OUT="$WORKDIR/selftest.out"
echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$WORKDIR/import.out" 2>&1
set -e

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/homecoming_ceremony_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- homecoming_ceremony_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
if [[ -n "${HOMECOMING_CEREMONY_LOG:-}" ]]; then
  cp "$OUT" "$HOMECOMING_CEREMONY_LOG"
fi
if [[ "$CODE" -ne 0 ]]; then
  echo "HOMECOMING_CEREMONY failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'HOMECOMING_CEREMONY_OK' "$OUT"; then
  echo "HOMECOMING_CEREMONY missing OK mark" >&2
  exit 1
fi
echo "HOMECOMING_CEREMONY local run OK"
exit 0
