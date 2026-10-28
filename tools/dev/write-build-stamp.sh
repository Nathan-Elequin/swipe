#!/bin/sh
# Writes data/build_stamp.txt from the real git commit.
# F5 does not need this. Editor play reads git at startup.
# Run it only for a build that cannot see .git and is not going through
# the editor export plugin (addons/build_stamp), which bakes the same string.
# Prints the stamp. A trailing * means the worktree had changes.
set -e
root=$(git rev-parse --show-toplevel)
sha=$(git -C "$root" rev-parse --short HEAD)
text=$sha
if git -C "$root" status --porcelain --untracked-files=normal | grep -v 'data/build_stamp.txt$' | grep -q .; then
	text="${sha}*"
fi
printf '%s\n' "$text" > "$root/data/build_stamp.txt"
printf '%s\n' "$text"
