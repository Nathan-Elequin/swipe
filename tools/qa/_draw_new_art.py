"""16x16 nearest-neighbor item art. CC0-style, unique pixels."""
from pathlib import Path
from PIL import Image

ROOT = Path("assets/dungeon/items")

# Transparent, then set pixels. Colors are dungeon-warm.


def canvas():
	return Image.new("RGBA", (16, 16), (0, 0, 0, 0))


def put(im, x, y, rgb, a=255):
	if 0 <= x < 16 and 0 <= y < 16:
		r, g, b = rgb
		im.putpixel((x, y), (r, g, b, a))


def scale2(im):
	return im.resize((32, 32), Image.NEAREST)


def wraps():
	im = canvas()
	ink = (40, 28, 18)
	cloth = (214, 190, 140)
	cloth2 = (196, 164, 112)
	shadow = (148, 110, 70)
	blood = (168, 36, 36)
	blood2 = (112, 18, 18)
	# wrapped fist, left-facing bundle
	for x, y in [
		(5, 3), (6, 3), (7, 3), (8, 3), (9, 3),
		(4, 4), (5, 4), (6, 4), (7, 4), (8, 4), (9, 4), (10, 4),
		(4, 5), (5, 5), (6, 5), (7, 5), (8, 5), (9, 5), (10, 5),
		(4, 6), (5, 6), (6, 6), (7, 6), (8, 6), (9, 6), (10, 6),
		(5, 7), (6, 7), (7, 7), (8, 7), (9, 7),
		(5, 8), (6, 8), (7, 8), (8, 8), (9, 8),
		(6, 9), (7, 9), (8, 9),
		(6, 10), (7, 10), (8, 10),
		(6, 11), (7, 11), (8, 11),
		(6, 12), (7, 12),
	]:
		put(im, x, y, cloth)
	# wrap stripes
	for x, y in [(4, 5), (5, 5), (6, 5), (7, 5), (8, 5), (9, 5), (10, 5), (5, 8), (6, 8), (7, 8), (8, 8), (9, 8), (6, 11), (7, 11), (8, 11)]:
		put(im, x, y, cloth2)
	for x, y in [(10, 4), (10, 6), (9, 9), (8, 12), (5, 12)]:
		put(im, x, y, shadow)
	# blood on knuckle
	for x, y in [(6, 4), (7, 4), (8, 4), (7, 5)]:
		put(im, x, y, blood)
	put(im, 7, 3, blood2)
	# outline
	for x, y in [(5, 2), (6, 2), (7, 2), (8, 2), (9, 2), (3, 4), (3, 5), (3, 6), (4, 3), (4, 7), (4, 8), (5, 9), (5, 10), (5, 11), (5, 13), (6, 13), (7, 13), (8, 12), (9, 11), (9, 10), (10, 9), (11, 4), (11, 5), (11, 6), (10, 3), (10, 7)]:
		put(im, x, y, ink)
	return scale2(im)


def scythe():
	im = canvas()
	ink = (32, 24, 16)
	haft = (122, 74, 36)
	haft2 = (88, 52, 24)
	blade = (198, 204, 214)
	blade2 = (150, 158, 172)
	edge = (236, 238, 242)
	# pole
	pts = [(4, 14), (4, 13), (5, 12), (5, 11), (6, 10), (6, 9), (7, 8), (7, 7), (8, 6), (8, 5), (9, 4)]
	for x, y in pts:
		put(im, x, y, haft)
		put(im, x + 1, y, haft2)
	# blade crescent opening left of tip
	for x, y in [
		(9, 3), (10, 3), (11, 3), (12, 3),
		(10, 2), (11, 2), (12, 2), (13, 2),
		(11, 1), (12, 1), (13, 1),
		(12, 4), (13, 3), (13, 4),
		(8, 4), (9, 5),
	]:
		put(im, x, y, blade)
	for x, y in [(11, 2), (12, 2), (13, 1), (10, 3)]:
		put(im, x, y, edge)
	for x, y in [(12, 4), (9, 5), (8, 5)]:
		put(im, x, y, blade2)
	# outline
	for x, y in [(3, 14), (3, 13), (4, 12), (4, 11), (5, 10), (5, 9), (6, 8), (6, 7), (7, 6), (7, 5), (8, 3), (9, 2), (10, 1), (11, 0), (12, 0), (13, 0), (14, 1), (14, 2), (14, 3), (13, 5), (12, 5), (11, 5), (10, 5), (8, 4), (5, 14), (6, 13)]:
		put(im, x, y, ink)
	return scale2(im)


def bracer(left: bool):
	im = canvas()
	ink = (36, 24, 14)
	leather = (156, 92, 42)
	leather2 = (124, 70, 32)
	metal = (196, 174, 118)
	metal2 = (148, 128, 78)
	# cuff body occupying left or right half, angling outward
	if left:
		body = [(3, 4), (4, 4), (5, 4), (6, 4), (7, 4),
			(2, 5), (3, 5), (4, 5), (5, 5), (6, 5), (7, 5), (8, 5),
			(2, 6), (3, 6), (4, 6), (5, 6), (6, 6), (7, 6), (8, 6),
			(2, 7), (3, 7), (4, 7), (5, 7), (6, 7), (7, 7), (8, 7),
			(3, 8), (4, 8), (5, 8), (6, 8), (7, 8),
			(3, 9), (4, 9), (5, 9), (6, 9), (7, 9),
			(4, 10), (5, 10), (6, 10)]
		chev = [(2, 6), (3, 6), (4, 7), (3, 8), (2, 8)]
		rivets = [(6, 5), (6, 8)]
	else:
		body = [(8, 4), (9, 4), (10, 4), (11, 4), (12, 4),
			(7, 5), (8, 5), (9, 5), (10, 5), (11, 5), (12, 5), (13, 5),
			(7, 6), (8, 6), (9, 6), (10, 6), (11, 6), (12, 6), (13, 6),
			(7, 7), (8, 7), (9, 7), (10, 7), (11, 7), (12, 7), (13, 7),
			(8, 8), (9, 8), (10, 8), (11, 8), (12, 8),
			(8, 9), (9, 9), (10, 9), (11, 9), (12, 9),
			(9, 10), (10, 10), (11, 10)]
		chev = [(13, 6), (12, 6), (11, 7), (12, 8), (13, 8)]
		rivets = [(9, 5), (9, 8)]
	for x, y in body:
		put(im, x, y, leather)
	for x, y in chev:
		put(im, x, y, metal)
	for x, y in rivets:
		put(im, x, y, metal2)
	# shading
	if left:
		for x, y in [(8, 5), (8, 6), (8, 7), (7, 9), (6, 10)]:
			put(im, x, y, leather2)
	else:
		for x, y in [(7, 5), (7, 6), (7, 7), (8, 9), (9, 10)]:
			put(im, x, y, leather2)
	# outline
	if left:
		ol = [(3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (1, 5), (1, 6), (1, 7), (2, 4), (2, 8), (2, 9), (3, 10), (4, 11), (5, 11), (6, 11), (7, 10), (8, 9), (9, 5), (9, 6), (9, 7), (8, 4), (8, 8)]
	else:
		ol = [(8, 3), (9, 3), (10, 3), (11, 3), (12, 3), (14, 5), (14, 6), (14, 7), (13, 4), (13, 8), (13, 9), (12, 10), (11, 11), (10, 11), (9, 11), (8, 10), (7, 9), (6, 5), (6, 6), (6, 7), (7, 4), (7, 8)]
	for x, y in ol:
		put(im, x, y, ink)
	return scale2(im)


def main():
	files = {
		"gauntlets.png": wraps(),
		"measuring_tape.png": scythe(),
		"left_bracer.png": bracer(True),
		"bracers.png": bracer(False),
	}
	for name, im in files.items():
		path = ROOT / name
		im.save(path)
		print("wrote", path, im.size)


if __name__ == "__main__":
	main()
