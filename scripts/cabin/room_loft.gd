extends "res://scripts/cabin/cabin_room.gd"
## Loft: bed (quit), trunk, cat, telescope.

var cat_sleep: AnimatedSprite2D
var new_tag: TextureRect

const CAT_SLEEP := Vector2(176, 196)
const CAT_RUB := Vector2(180, 196)

var _cat_bob: float = 0.0


func _build_special() -> void:
	var flames: Array = extra.get("anchors", {}).get("loft", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))
	cat_sleep = KIT.anim_sprite(
		["props/cat_sleep_f0.png", "props/cat_sleep_f1.png"],
		"z", 1000.0 / 900.0, true, CAT_SLEEP
	)
	cat_sleep.z_index = 3
	add_child(cat_sleep)
	if cat_sleep.sprite_frames:
		cat_sleep.play("z")
		var sf: SpriteFrames = cat_sleep.sprite_frames
		if not sf.has_animation("rub"):
			sf.add_animation("rub")
			sf.set_animation_loop("rub", false)
			sf.set_animation_speed("rub", 1000.0 / 180.0)
			for i in 4:
				var tex: Texture2D = KIT.load_tex("props/cat_rub_f%d.png" % i)
				if tex:
					sf.add_frame("rub", tex)
		if not cat_sleep.animation_finished.is_connected(_on_cat_anim_finished):
			cat_sleep.animation_finished.connect(_on_cat_anim_finished)
	new_tag = KIT.tex_rect("fx/new_tag.png", Vector2(126, 182), Vector2(16, 10), 5)
	new_tag.visible = false
	add_child(new_tag)


func _process(delta: float) -> void:
	if cat_sleep == null or cat_sleep.animation != "z":
		return
	_cat_bob += delta
	var bob: float = sin(_cat_bob * 1.7) * 4.0
	cat_sleep.position = CAT_SLEEP * KIT.PX + Vector2(bob * 0.35, bob)


func play_rub() -> bool:
	if not _rub_ready():
		return false
	cat_sleep.position = CAT_RUB * KIT.PX
	cat_sleep.play("rub")
	return true


func pose_rub_frame(frame_i: int) -> void:
	if not _rub_ready():
		return
	var count := cat_sleep.sprite_frames.get_frame_count("rub")
	cat_sleep.position = CAT_RUB * KIT.PX
	cat_sleep.play("rub")
	cat_sleep.pause()
	cat_sleep.frame = clampi(frame_i, 0, count - 1)


func _rub_ready() -> bool:
	if cat_sleep == null or cat_sleep.sprite_frames == null:
		return false
	if not cat_sleep.sprite_frames.has_animation("rub"):
		return false
	return cat_sleep.sprite_frames.get_frame_count("rub") > 0


func _on_cat_anim_finished() -> void:
	if cat_sleep == null or cat_sleep.animation != "rub":
		return
	cat_sleep.position = CAT_SLEEP * KIT.PX
	if cat_sleep.sprite_frames and cat_sleep.sprite_frames.has_animation("z"):
		cat_sleep.play("z")


func _refresh_doors() -> void:
	if cabin and cabin.has_method("trunk_has_unread"):
		new_tag.visible = cabin.trunk_has_unread()
	var tr = spots.get("Trunk", null)
	if tr is CabinHotspot and cabin and bool(cabin.get("trunk_open")):
		tr.set_idle_tex(KIT.load_tex("props/trunk_open.png"))
		var toh: Texture2D = KIT.load_tex("props/trunk_open_hover.png")
		tr.set_hover_tex(toh if toh else KIT.load_tex("props/trunk_hover.png"))
	elif tr is CabinHotspot:
		tr.set_idle_tex(KIT.load_tex("props/trunk.png"))
		tr.set_hover_tex(KIT.load_tex("props/trunk_hover.png"))
