#!/usr/bin/env bash
# Progress menu selftest runner — isolated XDG user://.
#
# Usage (repo root):
#   ./tools/qa/run_progress_menu.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_progress_menu.sh
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
  echo "RUNTIME_UNAVAILABLE: Godot 4.7.x not found. Set GODOT to Godot_v4.7.2-stable_*." >&2
  echo "Source-only fallback: python3 tools/qa/check_progress_menu.py" >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/progress-menu.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

export XDG_DATA_HOME="$WORKDIR/xdg-data"
export XDG_CONFIG_HOME="$WORKDIR/xdg-config"
export XDG_CACHE_HOME="$WORKDIR/xdg-cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
export HOME="$WORKDIR/fake-home"
mkdir -p "$HOME"

OUT="$WORKDIR/selftest.out"
echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
echo "Isolated XDG_DATA_HOME=$XDG_DATA_HOME"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$WORKDIR/import.out" 2>&1
set -e

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/progress_menu_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- progress_menu_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"

if [[ -n "${PROGRESS_MENU_LOG:-}" ]]; then
  cp "$OUT" "$PROGRESS_MENU_LOG"
fi

if [[ "$CODE" -ne 0 ]]; then
  echo "PROGRESS_MENU failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'PROGRESS_MENU_CEREMONY_OK' "$OUT"; then
  echo "PROGRESS_MENU missing OK mark" >&2
  exit 1
fi
echo "PROGRESS_MENU local run OK (isolated user-data)"
exit 0
