#!/usr/bin/env python3
"""Regression for approved framed title B (hub + cabin vignette + OFL fonts).

Stdlib only. Does not claim Godot runtime screenshots.
Exit 0 on pass, 1 on failure.
"""

from __future__ import annotations

import re
import struct
import sys
from pathlib import Path

PNG_SIG = b"\x89PNG\r\n\x1a\n"
CABIN = "assets/ui/title/cabin-vignette-native.png"
CABIN_NATIVE = (340, 220)
FONTS = [
    "assets/ui/fonts/eb_garamond/EBGaramond-SemiBold.ttf",
    "assets/ui/fonts/eb_garamond/EBGaramond-Regular.ttf",
    "assets/ui/fonts/eb_garamond/OFL.txt",
    "assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf",
    "assets/ui/fonts/open_sans/OpenSans-Regular.ttf",
    "assets/ui/fonts/open_sans/OFL.txt",
]
HUB = "scripts/playtest_hub.gd"
SCREEN = "design/visual/SCREEN-title-framed.md"
THEME = "themes/title_framed.tres"
REF = "design/visual/mockups/study-B-1680x1040.png"
REQ = "playtest/repot/inbox/REQ-20261106-title-framed-B.md"
COPY_KEYS = [
    "playtest.brand_new",
    "playtest.brand_new_blurb",
    "playtest.middle",
    "playtest.middle_blurb",
    "playtest.continue",
    "playtest.continue_blurb",
    "playtest.feedback",
]
SIGNALS = ["brand_new", "middle_progress", "continue_save", "feedback_wanted"]
FALLBACKS = [
    "Start from scratch.",
    "A few dungeons in.",
    "Last save.",
]


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for cand in (here.parents[2], Path.cwd()):
        if (cand / "project.godot").is_file():
            return cand
    return here.parents[2]


def ihdr(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != PNG_SIG:
        raise ValueError(f"{path}: missing PNG signature")
    w, h = struct.unpack(">II", data[16:24])
    return w, h


def fail(msg: str) -> None:
    print(f"FAIL: {msg}")
    failures.append(msg)


failures: list[str] = []


def main() -> int:
    root = repo_root()
    cabin = root / CABIN
    if not cabin.is_file():
        fail(f"missing {CABIN}")
    else:
        try:
            wh = ihdr(cabin)
            if wh != CABIN_NATIVE:
                fail(f"{CABIN} IHDR {wh} != {CABIN_NATIVE}")
            else:
                print(f"OK cabin IHDR {wh}")
        except ValueError as e:
            fail(str(e))
        imp = Path(str(cabin) + ".import")
        if not imp.is_file():
            fail(f"missing {CABIN}.import")
        else:
            text = imp.read_text(encoding="utf-8")
            if "mipmaps/generate=false" not in text and "mipmaps/generate=false" not in text.replace(" ", ""):
                if "mipmaps/generate=false" not in text:
                    fail(f"{CABIN}.import must disable mipmaps")
            if "compress/mode=0" not in text:
                fail(f"{CABIN}.import must be lossless compress/mode=0")
            print("OK cabin import lossless + no mips")

    for rel in FONTS:
        p = root / rel
        if not p.is_file():
            fail(f"missing {rel}")
        elif p.stat().st_size < 32:
            fail(f"too small {rel}")
        else:
            print(f"OK font/licence {rel} ({p.stat().st_size} bytes)")

    for rel in (HUB, SCREEN, THEME, REF, REQ):
        if not (root / rel).is_file():
            fail(f"missing {rel}")
        else:
            print(f"OK present {rel}")

    hub = (root / HUB).read_text(encoding="utf-8")
    for sig in SIGNALS:
        if f"signal {sig}" not in hub:
            fail(f"{HUB} missing signal {sig}")
    for key in COPY_KEYS:
        if key not in hub:
            fail(f"{HUB} missing copy key {key}")
    for fb in FALLBACKS:
        if fb not in hub:
            fail(f"{HUB} missing fallback {fb!r}")
    for token in ("15120f", "cabin-vignette-native.png", "EBGaramond-SemiBold", "OpenSans-SemiBold", "Spinheritance"):
        if token not in hub:
            fail(f"{HUB} missing token {token}")
    if "dress_title_button" in hub:
        fail(f"{HUB} must not use giant gold-border dress_title_button for framed B")
    if re.search(r"LOGO_PATH|title_tagline|hub_title", hub):
        fail(f"{HUB} must not revive floating logo/tagline/hub_title chrome")
    print("OK hub signals/copy/palette tokens")

    main_gd = (root / "scripts/main.gd").read_text(encoding="utf-8")
    if "music_title" not in main_gd:
        fail("scripts/main.gd lost music_title routing")
    if "open_archived_still" in main_gd and "_maybe_open_teaser" in main_gd:
        ## archived path should close teaser / show opaque hub, not require H3p under menu
        block = main_gd.split("func _maybe_open_teaser")[1].split("func ")[0]
        if "open_archived_still" in block:
            fail("archived teaser path still opens full-bleed still under framed hub")
        if "music_title" not in block:
            fail("archived teaser path must still call music_title")
    print("OK main teaser/hub integration")

    screen = (root / SCREEN).read_text(encoding="utf-8")
    for needle in ("approved", "cabin-vignette-native", "OFL", "1680", "1920", "1280"):
        if needle.lower() not in screen.lower() and needle not in screen:
            fail(f"{SCREEN} missing {needle}")
    print("OK screen doc markers")

    if failures:
        print(f"TITLE_FRAMED_FAIL ({len(failures)})")
        return 1
    print("TITLE_FRAMED_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
