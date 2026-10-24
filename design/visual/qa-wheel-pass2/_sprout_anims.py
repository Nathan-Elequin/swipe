# Four Sprout action loops. Token is read from the environment only.
import os, sys, json, time, threading
import importlib.util
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
spec = importlib.util.spec_from_file_location(
    "regen", os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "_regen_facing.py")
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

BASE = os.path.join(
    ROOT, "design", "handoff", "CURSOR-AGENT", "art-source", "run3", "base", "sprout64.png"
)
LOG = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "sprout_calls.log")
RAW = os.path.join(ROOT, "design", "visual", "qa-wheel-pass2", "_raw")
os.makedirs(RAW, exist_ok=True)

JOBS = [
    ("block", "raises a small round shield, braces, impact, lowers. same sprout, facing right, feet planted", 55101),
    ("use", "lifts a held item up with both hands and it glows, then lowers. same sprout, facing right, feet planted", 55102),
    ("heal", "drinks a small red potion, satisfied. same sprout, facing right, feet planted", 55103),
    ("lowhp", "hunched, panting, wobbly idle, looping. same sprout, facing right, feet planted", 55104),
]
LOCK = threading.Lock()


def one(name, action, seed):
    first = Image.open(BASE).convert("RGBA")
    b0 = m.balance()
    if b0 - 1 < 200:
        with LOCK:
            open(LOG, "a", encoding="utf-8").write(json.dumps({
                "t": time.strftime("%Y-%m-%d %H:%M:%S"),
                "endpoint": "/animate-with-text-v3",
                "stem": "sprout_" + name,
                "status": "STOP",
                "bal": b0,
                "usage_gens": 0,
            }) + "\n")
        raise SystemExit(f"STOP balance {b0}")
    payload = {
        "first_frame": m.b64(first),
        "action": action,
        "frame_count": 4,
        "no_background": True,
        "seed": seed,
    }
    # m.call logs to facing_calls.log and also checks the floor.
    files = m.call("/animate-with-text-v3", payload, "sprout_" + name)
    rec = {
        "t": time.strftime("%Y-%m-%d %H:%M:%S"),
        "endpoint": "/animate-with-text-v3",
        "stem": "sprout_" + name,
        "seed": seed,
        "n": len(files),
        "files": [os.path.relpath(p, ROOT).replace("\\", "/") for p in files],
    }
    with LOCK:
        open(LOG, "a", encoding="utf-8").write(json.dumps(rec) + "\n")
    print(name, len(files))
    return name, files


if __name__ == "__main__":
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(2) as ex:
        futs = [ex.submit(one, *job) for job in JOBS]
        for f in futs:
            f.result()
