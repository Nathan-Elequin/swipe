extends SceneTree
## Headless 1680×1040 composite of the wired trophy board art for the PR body.
## Writes design/audit-shots/cursor/trophy-art/board-composite.png


const OUT_DIR := "res://design/audit-shots/cursor/trophy-art"
const OUT := OUT_DIR + "/board-composite.png"
const W := 1680
const H := 1040
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a100c"))
	_blit_scaled(img, "res://assets/dungeon/home/rooms/room_trophy.png", 0, 0, W, H)
	if img.get_pixel(10, 10).a < 0.1:
		_blit_scaled(img, "res://assets/dungeon/home/rooms/room_hall.png", 0, 0, W, H)
	## Dais under the board.
	_blit(img, "res://assets/ui/trophy/board_dais.png", 152, 812)
	## Board frame + verdant face.
	var outer: Rect2 = MODEL.BOARD_OUTER
	_blit_scaled(img, "res://assets/ui/trophy_board/board_frame.png", int(outer.position.x), int(outer.position.y), int(outer.size.x), int(outer.size.y))
	var face: Rect2 = MODEL.FACE_VIEWPORT
	_blit_scaled(img, "res://assets/ui/trophy_board/face_bg_verdant.png", int(face.position.x), int(face.position.y), int(face.size.x), int(face.size.y))
	## Placard b1 centred at x 840.
	var placard := "res://assets/ui/trophy_board/placard_b1.png"
	var pw := 400
	_blit(img, placard, int(floor(840.0 - pw * 0.5)), int(outer.position.y))
	## Five demo cells: claimed / empty / claimed / empty / claimed on row 1.
	var ids := ["boot", "net", "smoke_bomb", "longbow", "shield"]
	var claimed := [true, false, true, false, true]
	var slot := 128
	var gap := 24
	var n := ids.size()
	var row_w := n * slot + (n - 1) * gap
	var x0 := int(840.0 - row_w * 0.5)
	var y0 := int(MODEL.PYRAMID_AREA.position.y + slot + MODEL.VGAP_NORMAL)
	for i in n:
		var cx := x0 + i * (slot + gap)
		var plinth := "res://assets/ui/trophy/plinth_claimed.png" if claimed[i] else "res://assets/ui/trophy/plinth_empty.png"
		_blit(img, plinth, cx, y0 + 116)
		_blit_item(img, ids[i], cx, y0, claimed[i])
		if claimed[i] and i == 0:
			_blit(img, "res://assets/ui/trophy/pulse_ring.png", cx + 64 - 80, y0 + 64 - 80)
	## Parchment tag sample.
	_blit_scaled(img, "res://assets/ui/trophy/parchment_tag.png", 1100, y0 + 20, 180, 72)
	## Nib feet on HALL_FLOOR_Y.
	var nib_h := 192
	var nib_y := int(MODEL.HALL_FLOOR_Y) - nib_h
	_blit_scaled(img, "res://assets/dungeon/home/nib/nib_idle_f0.png", 1544, nib_y, 144, 192)
	## Hotbar star sample (three slots).
	for s in 3:
		var sx := 80 + s * 80
		_fill(img, Rect2i(sx, 40, 64, 64), Color("2b1a12"))
		_blit(img, "res://assets/ui/hud/new_star.png", sx + 64 - 24, 40 - 4)
	var ok := _save(img, OUT)
	print("TROPHY_ART_WIRE_COMPOSITE_%s" % ("OK" if ok else "FAIL"))
	quit(0 if ok else 1)


func _blit_item(dst: Image, item_id: String, x: int, y: int, full_color: bool) -> void:
	var paths := [
		"res://assets/dungeon/items/%s.png" % item_id,
		"res://assets/icons/%s.png" % item_id,
	]
	for p in paths:
		if not FileAccess.file_exists(p):
			continue
		var src := Image.new()
		if src.load(p) != OK:
			continue
		src.resize(128, 128, Image.INTERPOLATE_NEAREST)
		if not full_color:
			for py in src.get_height():
				for px in src.get_width():
					var c := src.get_pixel(px, py)
					if c.a < 0.05:
						continue
					src.set_pixel(px, py, Color(0.04, 0.03, 0.025, 0.92 * c.a))
		dst.blit_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, y))
		return
	_fill(dst, Rect2i(x + 24, y + 24, 80, 80), Color(0.04, 0.03, 0.025, 0.92) if not full_color else Color("c4a574"))


func _blit(dst: Image, path: String, x: int, y: int) -> void:
	if not FileAccess.file_exists(path):
		return
	var src := Image.new()
	if src.load(path) != OK:
		return
	dst.blit_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, y))


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> void:
	if not FileAccess.file_exists(path):
		return
	var src := Image.new()
	if src.load(path) != OK:
		return
	src.resize(w, h, Image.INTERPOLATE_NEAREST)
	dst.blit_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, y))


func _fill(dst: Image, r: Rect2i, c: Color) -> void:
	for py in range(r.position.y, r.position.y + r.size.y):
		for px in range(r.position.x, r.position.x + r.size.x):
			if px >= 0 and py >= 0 and px < dst.get_width() and py < dst.get_height():
				dst.set_pixel(px, py, c)


func _save(img: Image, path: String) -> bool:
	var abs_path := ProjectSettings.globalize_path(path)
	var err := img.save_png(abs_path)
	if err != OK:
		push_error("save failed %s err=%s" % [path, err])
		return false
	print("wrote %s" % path)
	return true
