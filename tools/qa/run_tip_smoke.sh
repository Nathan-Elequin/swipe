#!/usr/bin/env bash
# Tip smoke — headless tutorial rail invariants (no F5 / no Autopilot play-agent).
# Usage (repo root):
#   ./tools/qa/run_tip_smoke.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_tip_smoke.sh
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

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true

# Godot 4.7.2 --import can flaky double-free near the end of a cold reimport
# ("double free or corruption" / exit 134 on player-copy.csv). Tip CI sometimes
# gets a clean import; a crashed import that we "continue" past leaves
# .import remaps pointing at missing .godot/imported dests. The next short
# --script run then starts a reimport and dies mid-way, so KEYWORD_TIPS_SMOKE
# fails opening OpenSans / keyword PNGs. Match tools/dev/godot-check.ps1:
# retry import, require exit 0 + a font canary before any selftest that loads art.
_font_canary() {
	local imp="assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf.import"
	local dest=""
	if [[ -f "$imp" ]]; then
		dest="$(awk -F= '/^path=/{gsub(/"/,"",$2); print $2; exit}' "$imp")"
	fi
	if [[ -n "$dest" ]]; then
		dest="${dest#res://}"
		[[ -f "$dest" ]]
		return $?
	fi
	compgen -G ".godot/imported/OpenSans-SemiBold*.fontdata" >/dev/null
}

IMPORT_OK=0
for attempt in 1 2 3; do
	if [[ "$attempt" -gt 1 ]]; then
		echo "Godot --import retry $attempt (wiping .godot for a clean pass)..."
		rm -rf .godot
	fi
	set +e
	"$GODOT_BIN" --headless --path "$ROOT" --import >/tmp/tip-smoke-import.out 2>&1
	IMP=$?
	set -e
	# Exit 134 after fonts are on disk is the known late double-free — keep the
	# cache. Only wipe/retry when the font canary is missing (early abort).
	if _font_canary; then
		IMPORT_OK=1
		if [[ "$IMP" -ne 0 ]]; then
			echo "Note: --import exited $IMP after canary ok (known late crash; continuing)"
		fi
		break
	fi
	echo "Note: --import attempt $attempt exited $IMP (font canary missing; see /tmp/tip-smoke-import.out)"
done
if [[ "$IMPORT_OK" -ne 1 ]]; then
	echo "Godot --import failed after retries — keyword tips need imported fonts/textures." >&2
	tail -20 /tmp/tip-smoke-import.out >&2 || true
	exit 2
fi

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/tip_smoke_selftest.gd
CODE=$?
set -e
if [[ "$CODE" -ne 0 ]]; then
	echo "TIP_SMOKE failed (exit $CODE)" >&2
	exit "$CODE"
fi

# Direction A keyword tips (defs round-trip + keep-out + parchment API).
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/keyword_tips_selftest.gd
KW=$?
set -e
if [[ "$KW" -ne 0 ]]; then
	echo "KEYWORD_TIPS_SMOKE failed (exit $KW)" >&2
	exit "$KW"
fi

# Phantom Shroud presentation (full-black curse veil) — headless card check.
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/phantom_shroud_selftest.gd
SHROUD=$?
set -e
if [[ "$SHROUD" -ne 0 ]]; then
  echo "PHANTOM_SHROUD_SMOKE failed (exit $SHROUD)" >&2
  exit "$SHROUD"
fi

# Lucky Nickel random coin restore (not choose picker) — chance slash icons + both RNG sides.
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/lucky_nickel_random_selftest.gd
NICKEL=$?
set -e
if [[ "$NICKEL" -ne 0 ]]; then
  echo "LUCKY_NICKEL_RANDOM_SMOKE failed (exit $NICKEL)" >&2
  exit "$NICKEL"
fi

# Ball & Chain Flee → Spin land → Draw once; cancel/invalid = no consume.
set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/ballchain_flee_spin_draw_selftest.gd
BALLCHAIN=$?
set -e
if [[ "$BALLCHAIN" -ne 0 ]]; then
  echo "BALLCHAIN_FLEE_SPIN_DRAW_SMOKE failed (exit $BALLCHAIN)" >&2
  exit "$BALLCHAIN"
fi

# House rooms unlock after first successful full dungeon return (cabin doors only).
chmod +x "$ROOT/tools/qa/run_house_unlock_first_return.sh"
set +e
GODOT="$GODOT_BIN" "$ROOT/tools/qa/run_house_unlock_first_return.sh"
HOUSE=$?
set -e
if [[ "$HOUSE" -ne 0 ]]; then
  echo "HOUSE_UNLOCK_FIRST_RETURN_SMOKE failed (exit $HOUSE)" >&2
  exit "$HOUSE"
fi

echo "TIP_SMOKE local run OK"
exit 0
