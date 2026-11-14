#!/usr/bin/env bash
# Package A legacy removal migration — isolated selftest.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GODOT_BIN="${GODOT:-}"
if [[ -z "$GODOT_BIN" ]]; then
  for c in \
    "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "$HOME/Godot_v4.7.2-stable_linux.x86_64" \
    "/tmp/godot/Godot_v4.7.2-stable_linux.x86_64" \
    "${RUNNER_TEMP:-/tmp}/godot/Godot_v4.7.2-stable_linux.x86_64" \
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
  exit 2
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/legacy-removal.XXXXXX")"
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

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$WORKDIR/import.out" 2>&1
set -e

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/legacy_removal_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- legacy_removal_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"

if [[ "$CODE" -ne 0 ]]; then
  echo "LEGACY_REMOVAL failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'LEGACY_REMOVAL_OK' "$OUT"; then
  echo "LEGACY_REMOVAL missing OK mark" >&2
  exit 1
fi
echo "LEGACY_REMOVAL local run OK"
exit 0