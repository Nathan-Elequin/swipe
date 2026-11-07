#!/usr/bin/env bash
# Homecoming ceremony ownership + Verdant haul-gate + persistence-safety selftest.
#
# CRITICAL PRECAUTIONS (do NOT run against Nathan's live profile casually):
#   1) Application seam: selftest sets cabin._persist_writes=false before any ack/_save.
#   2) Runner isolation: XDG_DATA_HOME (and HOME fallbacks) redirected into mktemp workdir
#      so Godot user:// cannot resolve to ~/.local/share/godot/app_userdata/Spinheritance.
#   3) Probe hash: suite compares user://home_cabin.json meta before/after; must be unchanged.
#
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
  echo "Source-only fallback: python3 tools/qa/check_cabinet_homecoming.py" >&2
  echo "Do NOT run homecoming_ceremony_selftest.gd against a live play profile until Godot+this runner are used." >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/homecoming-ceremony.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

# Genuine user-data isolation (Godot Linux respects XDG_DATA_HOME for user://).
export XDG_DATA_HOME="$WORKDIR/xdg-data"
export XDG_CONFIG_HOME="$WORKDIR/xdg-config"
export XDG_CACHE_HOME="$WORKDIR/xdg-cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
# Belt: if any code expands ~ via HOME, keep it inside the workdir too.
export HOME="$WORKDIR/fake-home"
mkdir -p "$HOME"

OUT="$WORKDIR/selftest.out"
REAL_PROBE_NOTE="$WORKDIR/isolation.note"
{
  echo "WORKDIR=$WORKDIR"
  echo "XDG_DATA_HOME=$XDG_DATA_HOME"
  echo "HOME=$HOME"
  echo "Expected isolated user:// under: $XDG_DATA_HOME/godot/app_userdata/"
} >"$REAL_PROBE_NOTE"

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
echo "Isolated XDG_DATA_HOME=$XDG_DATA_HOME (live ~/.local/share/godot NOT used)"

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
echo "----- isolation -----"
cat "$REAL_PROBE_NOTE"
echo "----- end isolation -----"

if [[ -n "${HOMECOMING_CEREMONY_LOG:-}" ]]; then
  cp "$OUT" "$HOMECOMING_CEREMONY_LOG"
  cp "$REAL_PROBE_NOTE" "${HOMECOMING_CEREMONY_LOG}.isolation"
fi

# Fail closed if suite claims OK but safety asserts missing from output.
if [[ "$CODE" -ne 0 ]]; then
  echo "HOMECOMING_CEREMONY failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'HOMECOMING_CEREMONY_OK' "$OUT"; then
  echo "HOMECOMING_CEREMONY missing OK mark" >&2
  exit 1
fi
if ! grep -q 'SAFE.ack_save_noop_same_meta' "$OUT" || ! grep -q 'PASS ASSERT SAFE.ack_save_noop_same_meta' "$OUT"; then
  echo "HOMECOMING_CEREMONY missing/failed persistence-safety assert — refusing fake pass" >&2
  exit 1
fi
if ! grep -q 'UNCOVERED.live_dialog_fx_cancel' "$OUT"; then
  echo "HOMECOMING_CEREMONY must label live H11 uncovered" >&2
  exit 1
fi
echo "HOMECOMING_CEREMONY local run OK (isolated user-data; live H11 still UNCOVERED)"
exit 0
