#!/usr/bin/env bash
# Re-download every source used by audio pass 1 into ${1:-/tmp/swipe-audio-src}. All CC0 1.0 (verified 2026-10-17).
set -euo pipefail; D=${1:-/tmp/swipe-audio-src}; mkdir -p "$D/oga"; cd "$D"
K=https://kenney.nl/media/pages/assets
for u in \
 $K/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip \
 $K/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip \
 $K/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip \
 $K/casino-audio/2472606a04-1721639069/kenney_casino-audio.zip \
 $K/music-jingles/f37e530b9e-1677590399/kenney_music-jingles.zip \
 $K/ui-audio/490d233f68-1677590494/kenney_ui-audio.zip ; do
  f=$(basename "$u"); curl -fsSL -o "$f" "$u"; python3 -c "import zipfile,sys;zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$f" "${f%.zip}"
done
O=https://opengameart.org/sites/default/files
for f in rbl_0.mp3 dungeon_deep.mp3 a_small_fire_will_do.wav fire.wav cat_softmew.wav cat_mewpurr.wav cat_purrsleepy_loop.wav; do
  curl -fsSL -o "oga/$f" "$O/$f"; done
echo "sources in $D"
