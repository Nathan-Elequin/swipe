#!/usr/bin/env python3
"""Verify a Spinheritance playtest victory code.

Usage:
  python3 tools/playtest/verify_victory_code.py <anon_id> <code> [milestone]

Prints VALID or INVALID (exit 0 / 1). Matches scripts/playtest_victory_code.gd.
"""

from __future__ import annotations

import hashlib
import sys

SALT = "spinheritance-playtest-victory-v1"
PREFIX = "ABYSS"
CROCKFORD = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
CODE_CHARS = 8


def generate(anon_id: str, milestone: str = "big") -> str:
    aid = (anon_id or "").strip() or "anon"
    mid = (milestone or "big").strip().lower() or "big"
    material = f"{aid}|{mid}|{SALT}".encode("utf-8")
    digest = hashlib.sha256(material).digest()
    chars = _encode_crockford(digest, CODE_CHARS)
    return f"{PREFIX}-{chars[:4]}-{chars[4:8]}"


def normalize(code: str) -> str:
    raw = (code or "").strip().upper().replace(" ", "")
    raw = (
        raw.replace("I", "1")
        .replace("L", "1")
        .replace("O", "0")
        .replace("U", "V")
        .replace("-", "")
    )
    if raw.startswith(PREFIX):
        raw = raw[len(PREFIX) :]
    if len(raw) != CODE_CHARS:
        return ""
    if any(ch not in CROCKFORD for ch in raw):
        return ""
    return f"{PREFIX}-{raw[:4]}-{raw[4:8]}"


def verify(anon_id: str, code: str, milestone: str = "big") -> bool:
    got = normalize(code)
    return bool(got) and got == generate(anon_id, milestone)


def _encode_crockford(data: bytes, count: int) -> str:
    out = []
    bit_buf = 0
    bit_len = 0
    bi = 0
    while len(out) < count:
        if bit_len < 5:
            b = data[bi % len(data)]
            bi += 1
            bit_buf = (bit_buf << 8) | b
            bit_len += 8
        shift = bit_len - 5
        idx = (bit_buf >> shift) & 0x1F
        bit_buf &= (1 << shift) - 1 if shift > 0 else 0
        bit_len = shift
        out.append(CROCKFORD[idx])
    return "".join(out)


def main(argv: list[str]) -> int:
    if len(argv) < 3 or argv[1] in ("-h", "--help"):
        print(__doc__.strip(), file=sys.stderr)
        return 2
    anon_id = argv[1]
    code = argv[2]
    milestone = argv[3] if len(argv) > 3 else "big"
    expected = generate(anon_id, milestone)
    ok = verify(anon_id, code, milestone)
    print("VALID" if ok else "INVALID")
    print(f"expected={expected}")
    print(f"got={normalize(code) or code.strip()}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
