# Facing idle regen. Token comes from the process env only. Never written here.
import os, sys, json, time, base64, io
import numpy as np
import requests
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
PIX = os.path.join(ROOT, "design", "handoff", "CURSOR-AGENT", "pixellab")
sys.path.insert(0, PIX)
from common import to_lab, PAL_HEX, hex2rgb
from pl import b64

API = "https://api.pixellab.ai/v2"
TOK = os.environ.get("PIXELLAB_API_TOKEN", "")
if not TOK:
    sys.exit("PIXELLAB_API_TOKEN is not set")
H = {"Authorization": "Bearer " + TOK}
LOG = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "facing_calls.log")
BASES = os.path.join(ROOT, "design", "handoff", "CURSOR-AGENT", "art-source", "run4", "final", "bases")
FACING = os.path.join(ROOT, "assets", "dungeon", "anim", "facing")
INK = np.array([0x10, 0x0E, 0x0C], np.uint8)
FLOOR = 200

STY = dict(
    outline="single color black outline",
    shading="medium shading",
    detail="medium detail",
    view="side",
    direction="east",
)


def balance():
    r = requests.get(API + "/balance", headers=H, timeout=30)
    r.raise_for_status()
    return float(r.json()["subscription"]["generations"])


def log(rec):
    rec = dict(rec)
    rec["t"] = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec) + "\n")
    print(json.dumps({k: rec[k] for k in rec if k != "resp"}))


def save_images(obj, dest_dir, stem):
    os.makedirs(dest_dir, exist_ok=True)
    out = []
    n = 0

    def walk(o):
        nonlocal n
        if isinstance(o, dict):
            if o.get("type") == "base64" and "base64" in o:
                raw = base64.b64decode(o["base64"].split(",")[-1])
                fn = os.path.join(dest_dir, f"{stem}_{n}.png")
                open(fn, "wb").write(raw)
                out.append(fn)
                n += 1
                return
            for k, v in o.items():
                if k == "base64" and isinstance(v, str) and len(v) > 100:
                    raw = base64.b64decode(v.split(",")[-1])
                    fn = os.path.join(dest_dir, f"{stem}_{n}.png")
                    open(fn, "wb").write(raw)
                    out.append(fn)
                    n += 1
                else:
                    walk(v)
        elif isinstance(o, list):
            for v in o:
                walk(v)

    walk(obj)
    return out


def call(endpoint, payload, stem):
    b0 = balance()
    if b0 - 1 < FLOOR:
        log({"endpoint": endpoint, "stem": stem, "status": "STOP", "bal": b0, "usage_gens": 0})
        sys.exit(f"STOP balance {b0} would drop below {FLOOR}")
    r = None
    for i in range(6):
        try:
            r = requests.post(API + endpoint, headers=H, json=payload, timeout=300)
        except Exception as e:
            log({"endpoint": endpoint, "stem": stem, "status": "EXC", "err": str(e)[:200], "usage_gens": 0})
            time.sleep(15)
            continue
        if r.status_code in (429, 502, 503, 504):
            time.sleep(20 * (i + 1))
            continue
        break
    try:
        j = r.json()
    except Exception:
        j = {"raw": r.text[:300]}
    if r.ok and j.get("background_job_id"):
        jid = j["background_job_id"]
        while True:
            time.sleep(8)
            try:
                j = requests.get(f"{API}/background-jobs/{jid}", headers=H, timeout=60).json()
            except Exception:
                continue
            if j.get("status") not in ("processing", "pending", "queued"):
                break
    raw_dir = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "_raw")
    files = save_images(j, raw_dir, stem) if r.ok else []
    usage = j.get("usage") or {}
    gens = usage.get("generations")
    if gens is None:
        gens = 1 if files and r.ok else 0
    if not r.ok:
        gens = 0

    def strip(o):
        if isinstance(o, dict):
            return {k: ("<b64>" if k == "base64" else strip(v)) for k, v in o.items()}
        if isinstance(o, list):
            return [strip(v) for v in o]
        return o

    b1 = balance()
    log({
        "endpoint": endpoint,
        "stem": stem,
        "status": r.status_code,
        "bal_before": b0,
        "bal_after": b1,
        "usage_gens": gens,
        "files": [os.path.relpath(p, ROOT).replace("\\", "/") for p in files],
        "resp_keys": list(j.keys()) if isinstance(j, dict) else type(j).__name__,
        "resp": json.dumps(strip(j))[:800],
    })
    if not r.ok:
        sys.exit(f"API {r.status_code} {json.dumps(strip(j))[:400]}")
    return files


def palette_img(extra_cols):
    cols = [hex2rgb(h) for h in PAL_HEX] + list(extra_cols)
    im = Image.new("RGB", (16, max(1, (len(cols) + 15) // 16)))
    for i, c in enumerate(cols):
        im.putpixel((i % 16, i // 16), tuple(int(x) for x in c))
    return im


def base_colors(im):
    a = np.array(im.convert("RGBA"))
    op = a[..., 3] == 255
    cols = a[op][:, :3]
    if cols.size == 0:
        op = a[..., 3] >= 128
        cols = a[op][:, :3]
    uniq = np.unique(cols.reshape(-1, 3), axis=0)
    return [tuple(int(x) for x in c) for c in uniq]


def snap(im, pal):
    a = np.array(im.convert("RGBA"))
    rgb = a[..., :3].astype(float)
    alpha = a[..., 3]
    op = alpha >= 128
    pal_a = np.array(pal, dtype=float)
    lab = to_lab(rgb.reshape(-1, 3))
    pl = to_lab(pal_a)
    idx = np.empty(lab.shape[0], np.int32)
    for s in range(0, len(lab), 200000):
        d = ((lab[s:s + 200000, None, :] - pl[None]) ** 2).sum(-1)
        idx[s:s + 200000] = d.argmin(1)
    idx = idx.reshape(rgb.shape[:2])
    out = np.zeros_like(a)
    out[op, :3] = pal_a[idx[op]].astype(np.uint8)
    out[op, 3] = 255
    return Image.fromarray(out, "RGBA")


def opaque_bbox(im):
    a = np.array(im.convert("RGBA"))
    op = a[..., 3] == 255
    ys, xs = np.nonzero(op)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def drop_islands(im, min_px=4):
    a = np.array(im.convert("RGBA"))
    op = a[..., 3] == 255
    H, W = op.shape
    seen = np.zeros_like(op)
    kill = np.zeros_like(op)
    for y in range(H):
        for x in range(W):
            if not op[y, x] or seen[y, x]:
                continue
            stack = [(y, x)]
            seen[y, x] = True
            cells = []
            while stack:
                cy, cx = stack.pop()
                cells.append((cy, cx))
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < H and 0 <= nx < W and op[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
            if len(cells) < min_px:
                for cy, cx in cells:
                    kill[cy, cx] = True
    a[kill, 3] = 0
    a[kill, :3] = 0
    return Image.fromarray(a, "RGBA")


def ink_outline(im):
    """Recolor dark edge pixels to #100e0c and add a 1px ink ring where the edge is not already ink."""
    a = np.array(im.convert("RGBA"))
    op = a[..., 3] == 255
    H, W = op.shape
    padded = np.pad(op, 1, constant_values=False)
    n4 = (
        padded[:-2, 1:-1].astype(int)
        + padded[2:, 1:-1]
        + padded[1:-1, :-2]
        + padded[1:-1, 2:]
    )
    edge = op & (n4 < 4)
    dark = np.linalg.norm(a[..., :3].astype(int) - INK.astype(int), axis=-1) < 40
    a[edge & dark, :3] = INK
    # ring only beside non-ink body pixels, and only inside the image
    body = op & ~((a[..., 0] == INK[0]) & (a[..., 1] == INK[1]) & (a[..., 2] == INK[2]))
    bp = np.pad(body, 1, constant_values=False)
    touch = (
        bp[:-2, 1:-1]
        | bp[2:, 1:-1]
        | bp[1:-1, :-2]
        | bp[1:-1, 2:]
    )
    ring = (~op) & touch
    a[ring, :3] = INK
    a[ring, 3] = 255
    return Image.fromarray(a, "RGBA")


def fit_sprite(im, canvas):
    """Crop to opaque, scale to (canvas-4) x (canvas-2), center x, feet on the bottom row."""
    box = opaque_bbox(im)
    if box is None:
        return Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    crop = im.crop(box)
    cw, ch = crop.size
    max_w, max_h = canvas - 4, canvas - 2
    scale = min(max_w / cw, max_h / ch)
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    nw = min(nw, max_w)
    nh = min(nh, max_h)
    if (nw, nh) != (cw, ch):
        crop = crop.resize((nw, nh), Image.Resampling.BOX if scale < 1 else Image.Resampling.NEAREST)
        crop = hard_alpha(crop)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    x0 = (canvas - nw) // 2
    y0 = canvas - nh
    out.paste(crop, (x0, y0), crop)
    return out


def hard_alpha(im):
    a = np.array(im.convert("RGBA"))
    op = a[..., 3] >= 128
    a[..., 3] = np.where(op, 255, 0).astype(np.uint8)
    a[~op, :3] = 0
    return Image.fromarray(a, "RGBA")


def margin_ok(im, canvas):
    box = opaque_bbox(im)
    if box is None:
        return False
    x0, y0, x1, y1 = box
    w, h = im.size
    if (w, h) != (canvas, canvas):
        return False
    left, right, top = x0, w - x1, y0
    feet = y1 == h
    return left >= 2 and right >= 2 and top >= 2 and feet


def prep_frame(im, canvas, pal):
    im = snap(hard_alpha(im), pal)
    im = drop_islands(im, 4)
    im = ink_outline(im)
    im = fit_sprite(im, canvas)
    im = snap(im, pal)
    # fitting can leave a soft edge; lock alpha and put feet back if outline grew
    if not margin_ok(im, canvas):
        im = fit_sprite(hard_alpha(im), canvas)
        im = snap(im, pal)
    return im


def make_init(base_path, canvas):
    base = Image.open(base_path).convert("RGBA")
    cols = base_colors(base)
    pal = [hex2rgb(h) for h in PAL_HEX] + cols
    fitted = fit_sprite(hard_alpha(base), canvas)
    fitted = snap(fitted, pal)
    fitted = ink_outline(fitted)
    if not margin_ok(fitted, canvas):
        fitted = fit_sprite(fitted, canvas)
        fitted = snap(fitted, pal)
    return fitted, pal, cols


def pixflux(init, desc, canvas, pal_png, seed, strength, stem):
    payload = {
        "description": desc,
        "image_size": {"width": canvas, "height": canvas},
        "no_background": True,
        "color_image": b64(pal_png),
        "text_guidance_scale": 8,
        "seed": seed,
        "init_image": b64(init),
        "init_image_strength": strength,
        **STY,
    }
    files = call("/create-image-pixflux", payload, stem)
    return Image.open(files[0]).convert("RGBA")


def animate(first, stem, seed):
    payload = {
        "first_frame": b64(first),
        "action": "idle breathing, subtle bob, stays in place",
        "frame_count": 4,
        "no_background": True,
        "seed": seed,
    }
    return call("/animate-with-text-v3", payload, stem)


if __name__ == "__main__":
    mid = sys.argv[1]
    canvas = int(sys.argv[2])
    strength = int(sys.argv[3]) if len(sys.argv) > 3 else 150
    seed = int(sys.argv[4]) if len(sys.argv) > 4 else 44101
    desc = sys.argv[5] if len(sys.argv) > 5 else "full body, facing right, same character design, idle stance"
    base_path = os.path.join(BASES, f"{mid}_base.png")
    init, pal, cols = make_init(base_path, canvas)
    init_path = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "_raw", f"{mid}_init.png")
    os.makedirs(os.path.dirname(init_path), exist_ok=True)
    init.save(init_path)
    print("init", init_path, "colors", len(cols), "margin", margin_ok(init, canvas), "bbox", opaque_bbox(init))
    pal_png = palette_img(cols)
    result = pixflux(init, desc, canvas, pal_png, seed, strength, f"{mid}_pix")
    cleaned = prep_frame(result, canvas, pal)
    clean_path = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "_raw", f"{mid}_clean.png")
    cleaned.save(clean_path)
    print("clean", clean_path, "margin", margin_ok(cleaned, canvas), "bbox", opaque_bbox(cleaned))
