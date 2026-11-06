#!/usr/bin/env bash
# ARC2 banking-contract selftest — headless, isolated in-memory state.
# Usage (repo root):
#   ./tools/qa/run_banking_contract.sh
#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_banking_contract.sh
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/banking-contract.XXXXXX")"
cleanup() {
  # Only remove this run's workdir. Never touch sibling temp names.
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

IMPORT_OUT="$WORKDIR/import.out"
OUT="$WORKDIR/selftest.out"

echo "Using Godot: $GODOT_BIN"
"$GODOT_BIN" --version || true
echo "Repo tip: $(git rev-parse HEAD 2>/dev/null || echo unknown)"
echo "Workdir: $WORKDIR"

set +e
"$GODOT_BIN" --headless --path "$ROOT" --import >"$IMPORT_OUT" 2>&1
IMP=$?
set -e
if [[ "$IMP" -ne 0 ]]; then
  echo "Note: --import exited $IMP (continuing; see $IMPORT_OUT)"
fi

set +e
"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/banking_contract_selftest.gd >"$OUT" 2>&1
CODE=$?
set -e
echo "----- banking_contract_selftest.gd (exit $CODE) -----"
cat "$OUT"
echo "----- end -----"
# Persist a copy for the caller before trap removes the workdir.
if [[ -n "${BANKING_CONTRACT_LOG:-}" ]]; then
  cp "$OUT" "$BANKING_CONTRACT_LOG"
  echo "Log copied to $BANKING_CONTRACT_LOG"
fi
if [[ "$CODE" -ne 0 ]]; then
  echo "BANKING_CONTRACT failed (exit $CODE)" >&2
  exit "$CODE"
fi
if ! grep -q 'BANKING_CONTRACT_OK' "$OUT"; then
  echo "BANKING_CONTRACT missing OK mark" >&2
  exit 1
fi
echo "BANKING_CONTRACT local run OK"
exit 0
