# Pass 6 Task 4: PixelLab wheel bases, breathe, facing idles, medallions, poison_lock.
# Token: env PIXELLAB_API_TOKEN only. Scratch: env PL_RUN_DIR (default ~/pl-runs/pass6-wheel).
# Usage: py -3 gen_wheel.py --batch lock|medallions|missing-bases|wheel|breathe|facing|install|all
#        py -3 gen_wheel.py --batch wheel --ids goblin,skeleton
from __future__ import annotations
import argparse, json, os, shutil, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
KIT = HERE.parent / "pixellab"
REPO = HERE.parents[3]
os.environ.setdefault("PL_RUN_DIR", str(Path.home() / "pl-runs" / "pass6-wheel"))
os.environ.setdefault("PL_ART_SOURCE", str(HERE.parent / "art-source"))
os.environ.setdefault("PL_PALETTE", str(HERE.parent / "palette" / "spinheritance.hex"))
os.environ.setdefault("PL_BUDGET", "40")
RUN = Path(os.environ["PL_RUN_DIR"])
for sub in ("raw", "base", "work", "final", "showcase"):
    (RUN / sub).mkdir(parents=True, exist_ok=True)

if not os.environ.get("PIXELLAB_API_TOKEN"):
    sys.exit("PIXELLAB_API_TOKEN is not set. Set the Windows user env var from pixellab.ai, then re-run.")

sys.path.insert(0, str(KIT))
from PIL import Image  # noqa: E402
from lib import J, anim, bal, par, pix, spent  # noqa: E402
from mons import M  # noqa: E402
from clean4 import clean, down, fit  # noqa: E402

BODY = ", full body standing facing right, three-quarter side view, high detail pixel art monster, clean readable silhouette, crisp 1px dark outline, 3-4 tone shading lit from upper left, dark fantasy dungeon game"
COIN = ", round bronze game-UI coin medallion, 1px dark rim, simple glyph in the centre, no background, no text"

EXTRA_DESC = {
    "wizard": "old human wizard in a pointed blue hat and starry robes, wooden staff, grey beard",
    "golem": "bulky grey stone golem, carved rock body with faint gold cracks, heavy fists",
}
MEDAL_SHEETS = [
    ("s1", "sparkles,link,users,swords", "four round bronze coins in a 2x2 grid: gold sparkles, a chain link, three people, crossed swords"),
    ("s2", "layers,heart,droplet,ban", "four round bronze coins in a 2x2 grid: stacked layers, a red heart, a green droplet, a ban circle-slash"),
    ("s3", "rotate,mountain,footprints,trending", "four round bronze coins in a 2x2 grid: rotate arrows, a mountain, footprints, a trending-up arrow"),
    ("s4", "shield,skull,copy,plus", "four round bronze coins in a 2x2 grid: a steel shield, a skull, two overlapping squares, a gold plus"),
    ("s5", "wand,hammer,sword,palm", "four round bronze coins in a 2x2 grid: a magic wand, a hammer, a single sword, an open palm"),
]


def live_ids() -> list[str]:
    cat = json.loads((REPO / "data" / "catalog.json").read_text(encoding="utf-8"))
    out = []
    for m in cat.get("monsters") or []:
        mid = str((m or {}).get("id") or "")
        if mid and mid != "three_seeker":
            out.append(mid)
    return out


def desc_of(mid: str) -> str:
    if mid in M:
        return M[mid][3]
    return EXTRA_DESC.get(mid, mid.replace("_", " "))


def tier_of(mid: str) -> float:
    cat = json.loads((REPO / "data" / "catalog.json").read_text(encoding="utf-8"))
    for m in cat.get("monsters") or []:
        if str((m or {}).get("id")) == mid:
            try:
                return float((m or {}).get("tier") or 1)
            except (TypeError, ValueError):
                return 1.0
    return 1.0


def facing_size(mid: str) -> int:
    if mid in M and M[mid][0] >= 64:
        return 64
    if tier_of(mid) >= 3:
        return 64
    return 48


def run4_base(mid: str) -> Path | None:
    p = Path(os.environ["PL_ART_SOURCE"]) / "run4" / "final" / "bases" / f"{mid}_base.png"
    return p if p.exists() else None


def extra_still(mid: str) -> Path | None:
    p = REPO / "assets" / "dungeon" / "extra" / f"{mid}.png"
    return p if p.exists() else None


def slash_base(mid: str) -> Path | None:
    p = REPO / "assets" / "dungeon" / "anim" / "slash" / f"{mid}_slash_base.png"
    return p if p.exists() else None


def bicubic(src: Path, size: int) -> Image.Image:
    im = Image.open(src).convert("RGBA")
    return im.resize((size, size), Image.BICUBIC)


def save_init(im: Image.Image, name: str) -> str:
    p = RUN / "base" / name
    im.save(p)
    return str(p)


def last_raw(prefix: str) -> Path | None:
    hits = sorted((RUN / "raw").glob(f"{prefix}_*.png"))
    return hits[-1] if hits else None


def wheel_from_raw(raw: Path, dest_w: int = 24, dest_h: int = 24) -> Image.Image:
    im = Image.open(raw).convert("RGBA")
    im = clean(im, bottom=True, outline=True, minblob=4)
    im = down(im, max(1, im.size[1] // dest_h)) if im.size[1] >= dest_h * 2 else im
    return fit(im, dest_w, dest_h, bottom=True)


def pick_breathe(frames: list[Path]) -> tuple[Image.Image, Image.Image]:
    ims = [Image.open(p).convert("RGBA") for p in frames]
    if len(ims) >= 3:
        a, b = ims[1], ims[-1]
    elif len(ims) == 2:
        a, b = ims[0], ims[1]
    else:
        a = b = ims[0]
    return a, b


def batch_lock() -> None:
    pix("tiny closed padlock, brass shackle, dark iron body, simple game UI icon, 1px dark outline, no background", 32, 32, "lock", 11)
    raw = last_raw("lock")
    if not raw:
        print("lock: no output")
        return
    im = clean(Image.open(raw).convert("RGBA"), bottom=False, outline=True, minblob=2)
    im = down(im, 4)
    im = fit(im, 6, 6, bottom=False)
    out = RUN / "final" / "poison_lock.png"
    im.save(out)
    print("wrote", out, im.size)


def batch_medallions() -> None:
    jobs = []
    for sid, _keys, line in MEDAL_SHEETS:
        jobs.append(J(pix, line + COIN, 64, 64, f"med_{sid}", 13 + len(sid)))
    par(jobs, 2)
    keys_all = []
    for sid, keys, _line in MEDAL_SHEETS:
        keys_all.append((sid, keys.split(",")))
        raw = last_raw(f"med_{sid}")
        if not raw:
            print("missing sheet", sid)
            continue
        im = Image.open(raw).convert("RGBA")
        im = clean(im, bottom=False, outline=True, minblob=3)
        w, h = im.size
        cells = [
            (0, 0, w // 2, h // 2),
            (w // 2, 0, w, h // 2),
            (0, h // 2, w // 2, h),
            (w // 2, h // 2, w, h),
        ]
        for key, box in zip(keys.split(","), cells):
            cell = im.crop(box)
            cell = clean(cell, bottom=False, outline=True, minblob=2)
            cell = fit(cell, 20, 20, bottom=False)
            dest = RUN / "final" / "medallions" / f"medallion_{key}.png"
            dest.parent.mkdir(parents=True, exist_ok=True)
            cell.save(dest)
            print("wrote", dest)


def batch_missing_bases() -> None:
    jobs = []
    for mid in ("golem", "wizard"):
        still = extra_still(mid)
        init = save_init(bicubic(still, 80), f"pinit_{mid}.png") if still else None
        d = f"full body {desc_of(mid)}" + BODY
        if init:
            jobs.append(J(pix, d, 80, 80, f"pb_{mid}", 17, init, 80))
        else:
            jobs.append(J(pix, d, 80, 80, f"pb_{mid}", 17))
    par(jobs, 2)
    for mid in ("golem", "wizard"):
        raw = last_raw(f"pb_{mid}")
        if not raw:
            print("missing base", mid)
            continue
        dest = RUN / "final" / "bases" / f"{mid}_base.png"
        dest.parent.mkdir(parents=True, exist_ok=True)
        im = clean(Image.open(raw).convert("RGBA"), bottom=True)
        im.save(dest)
        print("wrote", dest, im.size)


def _wheel_init(mid: str) -> str | None:
    local = RUN / "final" / "bases" / f"{mid}_base.png"
    src = local if local.exists() else run4_base(mid)
    if src is None:
        still = extra_still(mid)
        if still is None:
            return None
        src = still
    return save_init(bicubic(src, 48), f"wheel_init_{mid}.png")


def batch_wheel(ids: list[str]) -> None:
    jobs = []
    for mid in ids:
        init = _wheel_init(mid)
        d = f"full body {desc_of(mid)}, small wheel token, feet on the bottom row" + BODY
        if init:
            jobs.append(J(pix, d, 48, 48, f"wh_{mid}", 21, init, 200))
        else:
            jobs.append(J(pix, d, 48, 48, f"wh_{mid}", 21))
    par(jobs, 2)
    outdir = RUN / "final" / "wheel"
    outdir.mkdir(parents=True, exist_ok=True)
    for mid in ids:
        raw = last_raw(f"wh_{mid}")
        if not raw:
            print("missing wheel", mid)
            continue
        im = wheel_from_raw(raw, 24, 24)
        im.save(outdir / f"{mid}_wheel_base.png")
        print("wrote", mid, "wheel", im.size)


def batch_breathe(ids: list[str]) -> None:
    jobs = []
    for mid in ids:
        base = RUN / "final" / "wheel" / f"{mid}_wheel_base.png"
        if not base.exists():
            print("skip breathe, no wheel", mid)
            continue
        big = Image.open(base).convert("RGBA").resize((48, 48), Image.NEAREST)
        init = save_init(big, f"br_init_{mid}.png")
        jobs.append(J(anim, init, "idle breathe: chest rises and falls, feet planted, loop", f"br_{mid}", 23, True, 4))
    par(jobs, 2)
    outdir = RUN / "final" / "wheel"
    for mid in ids:
        frames = sorted((RUN / "raw").glob(f"br_{mid}_*.png"))
        if not frames:
            print("missing breathe", mid)
            continue
        a, b = pick_breathe(frames)
        fa = fit(clean(a, bottom=True), 24, 24, bottom=True)
        fb = fit(clean(b, bottom=True), 24, 24, bottom=True)
        fa.save(outdir / f"{mid}_wheel_breathe_f0.png")
        fb.save(outdir / f"{mid}_wheel_breathe_f1.png")
        print("wrote", mid, "breathe")


def batch_facing(ids: list[str]) -> None:
    jobs = []
    sizes = {}
    for mid in ids:
        size = facing_size(mid)
        sizes[mid] = size
        src = slash_base(mid)
        if src is None:
            local_base = RUN / "final" / "bases" / f"{mid}_base.png"
            src = local_base if local_base.exists() else run4_base(mid) or extra_still(mid)
        if src is None or not Path(src).exists():
            print("skip facing, no source", mid)
            continue
        init = save_init(bicubic(Path(src), size), f"face_init_{mid}.png")
        jobs.append(J(anim, init, "facing idle: subtle shift, blink or breath, loop, keep pose", f"fa_{mid}", 29, True, 4))
    par(jobs, 2)
    outdir = RUN / "final" / "facing"
    outdir.mkdir(parents=True, exist_ok=True)
    for mid in ids:
        frames = sorted((RUN / "raw").glob(f"fa_{mid}_*.png"))
        if not frames:
            print("missing facing", mid)
            continue
        size = sizes.get(mid, 48)
        # skip input frame 0 when PixelLab echoes it
        use = frames[1:5] if len(frames) > 4 else frames[:4]
        if len(use) < 4:
            use = (use + [use[-1]] * 4)[:4]
        for i, fp in enumerate(use):
            im = fit(clean(Image.open(fp).convert("RGBA"), bottom=True), size, size, bottom=True)
            im.save(outdir / f"{mid}_facing_idle_f{i}.png")
        print("wrote", mid, "facing", size, "x4")


def install() -> None:
    mapping = [
        (RUN / "final" / "poison_lock.png", REPO / "assets" / "ui" / "anim" / "poison_lock.png"),
    ]
    med_dir = RUN / "final" / "medallions"
    if med_dir.exists():
        for p in med_dir.glob("medallion_*.png"):
            mapping.append((p, REPO / "assets" / "ui" / "wheel" / p.name))
    wheel_dir = RUN / "final" / "wheel"
    if wheel_dir.exists():
        for p in wheel_dir.glob("*.png"):
            mapping.append((p, REPO / "assets" / "dungeon" / "anim" / "wheel" / p.name))
    face_dir = RUN / "final" / "facing"
    if face_dir.exists():
        for p in face_dir.glob("*.png"):
            mapping.append((p, REPO / "assets" / "dungeon" / "anim" / "facing" / p.name))
    n = 0
    for src, dst in mapping:
        if not src.exists():
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        n += 1
    print("installed", n, "pngs")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--batch", required=True)
    ap.add_argument("--ids", default="")
    args = ap.parse_args()
    b0 = bal()
    print("balance", b0, "spent", spent(), "budget", os.environ.get("PL_BUDGET"))
    ids = [s.strip() for s in args.ids.split(",") if s.strip()] or live_ids()
    batch = args.batch
    if batch == "lock":
        batch_lock()
    elif batch == "medallions":
        batch_medallions()
    elif batch == "missing-bases":
        batch_missing_bases()
    elif batch == "wheel":
        batch_wheel(ids)
    elif batch == "breathe":
        batch_breathe(ids)
    elif batch == "facing":
        batch_facing(ids)
    elif batch == "install":
        install()
    elif batch == "all":
        batch_lock()
        batch_medallions()
        batch_missing_bases()
        batch_wheel(ids)
        batch_breathe(ids)
        batch_facing(ids)
        install()
    else:
        sys.exit(f"unknown batch {batch}")
    print("done", args.batch, "balance now", bal(), "spent", spent())


if __name__ == "__main__":
    main()
