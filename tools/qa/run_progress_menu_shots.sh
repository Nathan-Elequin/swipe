#!/usr/bin/env bash
# Progress menu BEFORE/MID/AFTER + catalog stills (Xvfb).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for c in \
    "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "/tmp/godot-ci/Godot_v4.7.2-stable_linux.x86_64" \
    "/tmp/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "godot"
  do
    if command -v "$c" >/dev/null 2>&1 || [[ -x "$c" ]]; then
      GODOT_BIN="$c"
      break
    fi
  done
fi
if [[ -z "${GODOT_BIN}" ]] || { ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [[ ! -x "$GODOT_BIN" ]]; }; then
  echo "RUNTIME_UNAVAILABLE" >&2
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/progress-menu-shots.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

export XDG_DATA_HOME="$WORKDIR/xdg-data"
export XDG_CONFIG_HOME="$WORKDIR/xdg-config"
export XDG_CACHE_HOME="$WORKDIR/xdg-cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
export HOME="$WORKDIR/fake-home"
mkdir -p "$HOME"

OUT_DIR="${PROGRESS_MENU_OUT:-$ROOT/playtest/repot/outbox/REQ-20261108-progress-menu}"
mkdir -p "$OUT_DIR/shots"
SHA="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
export PROGRESS_SOURCE_SHA="${PROGRESS_SOURCE_SHA:-$SHA}"
OUT="$OUT_DIR/shots.log"

echo "Using Godot: $GODOT_BIN"
echo "SHA=$SHA PROGRESS_SOURCE_SHA=$PROGRESS_SOURCE_SHA"

RUNNER=("$GODOT_BIN" --path "$ROOT" --script res://scripts/dev/progress_menu_shots.gd)
if command -v xvfb-run >/dev/null 2>&1; then
  set +e
  xvfb-run -a -s '-screen 0 1680x1040x24' "${RUNNER[@]}" >"$OUT" 2>&1
  CODE=$?
  set -e
else
  set +e
  "${RUNNER[@]}" --headless >"$OUT" 2>&1
  CODE=$?
  set -e
fi

{
  echo "===== progress_menu_shots SHA=$SHA exit=$CODE ====="
  cat "$OUT"
} | tee "$OUT_DIR/shots.receipt.log"

if grep -q 'SHOTS_FAIL' "$OUT"; then
  echo "SHOTS failed (FAIL mark)" >&2
  exit 1
fi
if [[ "$CODE" -ne 0 ]] || ! grep -q 'SHOTS_OK' "$OUT"; then
  echo "SHOTS failed (exit $CODE)" >&2
  exit "${CODE:-1}"
fi
echo "SHOTS_OK SHA=$SHA"
exit 0
