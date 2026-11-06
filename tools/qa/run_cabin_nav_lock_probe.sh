#!/usr/bin/env bash
# ARC1 cabin nav lock probe — always runs in an isolated Godot user-data sandbox.
# Does not read/write ~/.local/share/godot/app_userdata/Spinheritance.
#
# Usage (repo root):
#   ./tools/qa/run_cabin_nav_lock_probe.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_cabin_nav_lock_probe.sh
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
  # Fail closed: refuse to run if we cannot snapshot real saves for proof.
  if ! sha256sum "$REAL_USER"/home_cabin.json "$REAL_USER"/campaign_save.json \
      "$REAL_USER"/playtest_meta.json "$REAL_USER"/bucket_progress.json \
      2>/dev/null | sort >"$HASH_BEFORE"; then
    # Some files may be absent; hash whatever exists.
    sha256sum "$REAL_USER"/*.json 2>/dev/null | sort >"$HASH_BEFORE" || {
      echo "CABIN_NAV_LOCK_PROBE_FAIL cannot snapshot real userdata json" >&2
      exit 1
    }
  fi
else
  : >"$HASH_BEFORE"
fi

SANDBOX="$(mktemp -d /tmp/arc1-cabin-nav-sandbox-XXXXXX)"
export XDG_DATA_HOME="$SANDBOX"
echo "Using Godot: $GODOT_BIN"
echo "Sandbox XDG_DATA_HOME=$XDG_DATA_HOME"
echo "Real userdata (must stay unchanged): $REAL_USER"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/cabin_nav_lock_probe.gd
CODE=$?
set -e

if [[ -d "$REAL_USER" ]]; then
  sha256sum "$REAL_USER"/*.json 2>/dev/null | sort >"$HASH_AFTER" || true
  if ! cmp -s "$HASH_BEFORE" "$HASH_AFTER"; then
    echo "CABIN_NAV_LOCK_PROBE_FAIL real userdata json changed during probe" >&2
    echo "BEFORE:" >&2
    cat "$HASH_BEFORE" >&2
    echo "AFTER:" >&2
    cat "$HASH_AFTER" >&2
    exit 1
  fi
  echo "REAL_USERDATA_UNCHANGED_OK"
fi

exit "$CODE"
