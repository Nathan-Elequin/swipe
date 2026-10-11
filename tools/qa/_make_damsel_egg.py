import json
import struct
import zlib
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")


def chunk(tag: bytes, data: bytes) -> bytes:
	crc = zlib.crc32(tag + data) & 0xFFFFFFFF
	return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)


def write_png(path: Path, pixels: list, w: int = 16, h: int = 16) -> None:
	raw = b""
	for y in range(h):
		raw += b"\x00"
		for x in range(w):
			r, g, b, a = pixels[y * w + x]
			raw += bytes([r, g, b, a])
	ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
	png = (
		b"\x89PNG\r\n\x1a\n"
		+ chunk(b"IHDR", ihdr)
		+ chunk(b"IDAT", zlib.compress(raw, 9))
		+ chunk(b"IEND", b"")
	)
	path.parent.mkdir(parents=True, exist_ok=True)
	path.write_bytes(png)
	print("wrote", path, len(png))


def paint(text: str, table: dict) -> list:
	rows = [ln.rstrip("\n")[:16].ljust(16) for ln in text.strip("\n").split("\n")]
	pix = []
	for row in rows:
		for ch in row:
			pix.append(table.get(ch, (0, 0, 0, 0)))
	if len(pix) != 256:
		raise SystemExit("pixel count %s" % len(pix))
	return pix


D = {
	".": (0, 0, 0, 0),
	"k": (28, 18, 12, 255),
	"h": (92, 48, 28, 255),
	"s": (232, 176, 128, 255),
	"e": (40, 28, 24, 255),
	"g": (232, 180, 64, 255),
	"p": (196, 64, 96, 255),
	"d": (140, 32, 64, 255),
	"w": (244, 232, 216, 255),
}
damsel = """
................
......gggg......
.....ghhhhg.....
.....hssssh.....
.....hseesh.....
......ssss......
......wssw......
.....pppppp.....
....ppwwwwpp....
....pppppppp....
.....pppppp.....
.....dddddd.....
.....d....d.....
.....k....k.....
....kk....kk....
................
"""
write_png(ROOT / "assets/dungeon/extra/damsel.png", paint(damsel, D))

E = {
	".": (0, 0, 0, 0),
	"o": (48, 36, 28, 255),
	"c": (210, 196, 168, 255),
	"w": (244, 236, 214, 255),
	"s": (90, 48, 40, 255),
	"n": (28, 22, 20, 255),
}
egg = """
................
......oooo......
.....owwwwo.....
....owccccwo....
...owccscscwo...
...owccccccwo...
...owcscsccwo...
...owccccccwo...
....owcscswo....
....owccccwo....
.....owwwwo.....
......oooo......
......nnnn......
................
................
................
"""
write_png(ROOT / "assets/dungeon/items/spider_egg.png", paint(egg, E))

EGG_CARD = {
	"ability": "Take 2 Attack. If you still hold this when you Spin Spider Queen, discard it; she gains +2 HP and +2 Attack.",
	"author_lock": False,
	"card_color": "egg",
	"count": 0,
	"defined": "Created by Spider Queen on Spin of someone else. Click: take 2 Attack (Block works), used up. If in hand when you Spin Queen: discard every Egg; Queen gains +2 HP and +2 Attack per Egg. No Egg is created when you Spin Queen.",
	"exceptions": "",
	"explainer": "Take 2 Attack",
	"flags": {"art": True, "dev": True, "hide": True},
	"flow": "Click during a fight. Take 2 Attack; Block works. Used up. If this is in hand when the wheel lands on Spider Queen, discard it and she gains +2 HP and +2 Attack. Queen does not create an Egg on the Spin that lands on her. Always created on other Spins while Queen is alive, up to 50 cards in hand.",
	"id": "spider_egg",
	"name": "Spider Egg",
	"notes": "Not drafted. Queen creates it.",
	"ops": {"kind": "egg_hurt", "n": 2},
	"poc": False,
	"priority": 9,
	"rarity": "uncommon",
	"review": "polish",
	"review_note": "",
	"status": "todo",
	"tier": 1,
	"type": "I",
}

BOARD_EGG = {
	"ability": EGG_CARD["ability"],
	"atk_base": None,
	"atk_formula": "",
	"author_lock": False,
	"card_color": "egg",
	"contradiction_ids": [],
	"count": 0,
	"explainer": "Take 2 Attack",
	"flow": EGG_CARD["flow"],
	"hp_base": None,
	"hp_formula": "",
	"id": "spider_egg",
	"kind": "item",
	"locked_fields": [],
	"name": "Spider Egg",
	"notes": EGG_CARD["notes"],
	"ops": {"kind": "egg_hurt", "n": 2},
	"priority": 9,
	"rarity": "uncommon",
	"reminder": "",
	"review": "polish",
	"review_note": "",
	"status": "todo",
	"tier": 1,
}

cat_path = ROOT / "data/catalog.json"
board_path = ROOT / "data/content-board.json"
run_path = ROOT / "data/runtime.json"
cat = json.loads(cat_path.read_text(encoding="utf-8"))
board = json.loads(board_path.read_text(encoding="utf-8"))
runtime = json.loads(run_path.read_text(encoding="utf-8"))

items = cat.get("items", [])
if not any(str(x.get("id")) == "spider_egg" for x in items):
	# insert after cursed_scroll if present
	idx = next((i for i, x in enumerate(items) if str(x.get("id")) == "cursed_scroll"), len(items) - 1)
	items.insert(idx + 1, EGG_CARD)
	cat["items"] = items
	print("catalog +spider_egg")
else:
	print("catalog already has spider_egg")

bitems = board.get("items", [])
if not any(str(x.get("id")) == "spider_egg" for x in bitems):
	idx = next((i for i, x in enumerate(bitems) if str(x.get("id")) == "cursed_scroll"), len(bitems) - 1)
	bitems.insert(idx + 1, BOARD_EGG)
	board["items"] = bitems
	print("board +spider_egg")
else:
	print("board already has spider_egg")

# Do not mill eggs: leave them out of runtime items. Dev Test still lists runtime.
# Queen creates them. Add to runtime so Developer Test can seat them.
ritems = runtime.get("items", [])
if "spider_egg" not in ritems:
	ritems.append("spider_egg")
	runtime["items"] = ritems
	print("runtime +spider_egg")

cat_path.write_text(json.dumps(cat, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
board_path.write_text(json.dumps(board, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
run_path.write_text(json.dumps(runtime, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
print("json saved")
