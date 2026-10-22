"""Install finished PixelLab run2/run3 teaser + intro frames at the paths the game already loads.

Source: the art kit on the box (/workspace/art-kit/pixellab), run2/run3 final/ (+ x4/ shipped copies)
and items/. No PixelLab calls. Shipped = integer nearest upscale of the native frame.
Usage: python install_pixellab_teaser.py <art-kit/pixellab dir> <repo root>
"""
import os
import sys
from PIL import Image

KIT, REPO = sys.argv[1], sys.argv[2]
TITLE = os.path.join(REPO, "assets/dungeon/title")
CUT = os.path.join(REPO, "assets/dungeon/home/cutscenes")

IMPORT = """[remap]

importer="texture"
type="CompressedTexture2D"

[deps]

source_file="res://{res}"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""

done = []


def put(src_native, dst, scale):
    im = Image.open(os.path.join(KIT, src_native)).convert("RGBA")
    if scale != 1:
        im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    im.save(dst)
    imp = dst + ".import"
    if not os.path.exists(imp):
        res = os.path.relpath(dst, REPO).replace(os.sep, "/")
        open(imp, "w", newline="\n").write(IMPORT.format(res=res))
    done.append((src_native, os.path.relpath(dst, REPO), im.size))


# Sprout teaser (48 native -> 192 shipped), Nib lantern (32 -> 128). Code blits these at texture size.
for anim in ("run", "grab", "throw"):
    for i in range(4):
        put(f"run2/final/sprout_{anim}_f{i}.png", f"{TITLE}/sprout_{anim}_f{i}.png", 4)
for i in range(2):
    put(f"run2/final/nib_lantern_f{i}.png", f"{TITLE}/nib_lantern_f{i}.png", 4)
# Helmet beat: 64px Sprout hurt (with the white hit flash on f1), 3x = 192 so he stays the run size.
for i, src in enumerate(["sprout64_hurt_f0", "sprout64_hurt_f1_flash", "sprout64_hurt_f2", "sprout64_hurt_f3"]):
    put(f"run3/final/{src}.png", f"{TITLE}/sprout_hurt_f{i}.png", 3)

# Chase monsters, facing right, 4-frame cycles. run3 redos win; ogre only exists in run2.
MONS = {
    "goblin": "run3/final/mon_goblin_run",
    "dire_wolf": "run3/final/mon_dire_wolf_gallop",
    "skeleton": "run3/final/mon_skeleton_run",
    "ogre": "run2/final/mon_ogre",
    "hornet_swarm": "run3/final/mon_hornet_swarm_fly",
    "spider_queen": "run3/final/mon_spider_queen_move",
    "dragon": "run3/final/mon_dragon_move",
}
for mid, stem in MONS.items():
    for i in range(4):
        put(f"{stem}_f{i}.png", f"{TITLE}/mon_{mid}_f{i}.png", 4)

# Loot floaters (24 native -> 96 shipped). f1 twinkle only where PixelLab made one.
for iid in ("pocketwatch", "lantern", "grimoire", "healing_potion", "lucky_nickel", "sledgehammer", "da_boot", "helmet"):
    put(f"items/item_{iid}.png", f"{TITLE}/item_{iid}_f0.png", 4)
for iid in ("pocketwatch", "grimoire"):
    put(f"run2/final/item_{iid}_f1.png", f"{TITLE}/item_{iid}_f1.png", 4)

# Intro cutscene panel loops (320x180 native -> 1280x720, same as the stills they animate).
for stem in ("intro_p1_candle", "intro_p3_seal"):
    for i in range(4):
        put(f"run2/final/intro/{stem}_f{i}.png", f"{CUT}/{stem}_f{i}.png", 4)

for s, d, sz in done:
    print(f"{s} -> {d} {sz[0]}x{sz[1]}")
