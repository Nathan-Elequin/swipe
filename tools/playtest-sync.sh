#!/usr/bin/env bash
# Sync this checkout to the canonical playtest tip (origin/playtest/latest).
# Does not launch Godot. Does not delete stashes. Does not force-push.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

if [[ ! -d .git ]] || [[ ! -f project.godot ]]; then
  echo "error: run from the swipe repo root (need .git and project.godot)." >&2
  exit 1
fi

STASH_CREATED=0
STASH_REF=""
STASH_MSG=""

if ! git fetch origin playtest/latest; then
  echo "error: git fetch origin playtest/latest failed." >&2
  exit 1
fi

# Dirty tracked changes or untracked files that could block a hard reset/checkout.
if [[ -n "$(git status --porcelain)" ]]; then
  STASH_MSG="playtest-sync $(date '+%Y-%m-%d %H:%M')"
  if ! git stash push -u -m "${STASH_MSG}"; then
    echo "error: git stash push failed." >&2
    exit 1
  fi
  STASH_CREATED=1
  STASH_REF="$(git rev-parse -q --verify refs/stash || true)"
  # Newest stash is always stash@{0} after a successful push.
  if [[ -z "${STASH_REF}" ]]; then
    STASH_REF="stash@{0}"
  fi
fi

if ! git checkout -B playtest/latest origin/playtest/latest; then
  echo "error: git checkout -B playtest/latest origin/playtest/latest failed." >&2
  exit 1
fi

if ! git reset --hard origin/playtest/latest; then
  echo "error: git reset --hard origin/playtest/latest failed." >&2
  exit 1
fi

BRANCH="$(git branch --show-current)"
SHORT_SHA="$(git rev-parse --short HEAD)"

echo "branch: ${BRANCH}"
echo "sha:    ${SHORT_SHA}"
if [[ "${STASH_CREATED}" -eq 1 ]]; then
  echo "stash:  created ${STASH_REF} — ${STASH_MSG}"
else
  echo "stash:  none (working tree was clean)"
fi
echo "F5 in Godot now. Corner stamp should match this SHA (no * if clean)."
