#!/usr/bin/env bash
# P4 continuation inventory / reroll proof — isolated Godot user-data sandbox.
# Does not read/write ~/.local/share/godot/app_userdata/Spinheritance.
#
# Usage (repo root):
#   ./tools/qa/run_continuation_inventory_probe.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_continuation_inventory_probe.sh
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
  echo "Godot 4.7.x not found. Set GODOT." >&2
  exit 2
fi

REAL_USER="$HOME/.local/share/godot/app_userdata/Spinheritance"
HASH_BEFORE="$(mktemp)"
HASH_AFTER="$(mktemp)"
cleanup() {
  rm -f "$HASH_BEFORE" "$HASH_AFTER"
  rm -rf "${SANDBOX:-}"
}
trap cleanup EXIT

if [[ -d "$REAL_USER" ]]; then
  if ! sha256sum "$REAL_USER"/home_cabin.json "$REAL_USER"/campaign_save.json \
      "$REAL_USER"/playtest_meta.json "$REAL_USER"/bucket_progress.json \
      2>/dev/null | sort >"$HASH_BEFORE"; then
    sha256sum "$REAL_USER"/*.json 2>/dev/null | sort >"$HASH_BEFORE" || : >"$HASH_BEFORE"
  fi
else
  : >"$HASH_BEFORE"
fi

SANDBOX="$(mktemp -d /tmp/p4-continuation-inventory-sandbox-XXXXXX)"
export XDG_DATA_HOME="$SANDBOX"
echo "Using Godot: $GODOT_BIN"
echo "Sandbox XDG_DATA_HOME=$XDG_DATA_HOME"
echo "Real userdata (must stay unchanged): $REAL_USER"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >/tmp/continuation-inventory-import.out 2>&1
IMP=$?
set -e
if [[ "$IMP" -ne 0 ]]; then
  echo "Note: --import exited $IMP (continuing; see /tmp/continuation-inventory-import.out)"
fi

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/continuation_inventory_probe.gd
CODE=$?
set -e

if [[ -d "$REAL_USER" ]]; then
  sha256sum "$REAL_USER"/*.json 2>/dev/null | sort >"$HASH_AFTER" || true
  if ! cmp -s "$HASH_BEFORE" "$HASH_AFTER"; then
    echo "CONTINUATION_INVENTORY_PROBE_FAIL real userdata json changed during probe" >&2
    echo "BEFORE:" >&2
    cat "$HASH_BEFORE" >&2
    echo "AFTER:" >&2
    cat "$HASH_AFTER" >&2
    exit 1
  fi
  echo "REAL_USERDATA_UNCHANGED_OK"
fi

exit "$CODE"
