extends CanvasLayer
## Top-right Endless dungeon counter. Current floor is large; best is faint.

const COPY := preload("res://scripts/player_copy.gd")
const GOLD := Color("e8c36a")
const MUTED := Color("a8946c")

var _n: Label
var _best: Label
var _sfx
var _shown_n: int = 0
var _tick_count: int = 0
var _glint_tw: Tween
var _bump_tw: Tween


func _ready() -> void:
	layer = 72
	name = "EndlessHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	if ResourceLoader.exists("res://assets/ui/endless/endless_plaque.png"):
		var plaque := TextureRect.new()
		plaque.name = "EndlessPlaque"
		plaque.texture = load("res://assets/ui/endless/endless_plaque.png") as Texture2D
		plaque.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		plaque.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plaque.stretch_mode = TextureRect.STRETCH_SCALE
		plaque.position = Vector2(1320, 16)
		plaque.size = Vector2(320, 96)
		plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plaque.z_index = 0
		root.add_child(plaque)
	_n = Label.new()
	_n.name = "DungeonN"
	_n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_n.add_theme_font_override("font", ThemeDB.fallback_font)
	_n.add_theme_font_size_override("font_size", 64)
	_n.add_theme_color_override("font_color", GOLD)
	_n.add_theme_color_override("font_outline_color", Color("100e0c"))
	_n.add_theme_constant_override("outline_size", 8)
	_n.position = Vector2(1380, 28)
	_n.size = Vector2(260, 80)
	_n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_n.pivot_offset = Vector2(260, 40)
	_n.z_index = 1
	root.add_child(_n)
	var skull_sf := SpriteFrames.new()
	skull_sf.add_animation("flip")
	skull_sf.set_animation_speed("flip", 10.0)
	skull_sf.set_animation_loop("flip", true)
	var skull_ok := false
	for i in 5:
		var path := "res://assets/ui/endless/skull_coin_flip_f%d.png" % i
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			skull_sf.add_frame("flip", tex)
			skull_ok = true
	if skull_ok:
		var skull := AnimatedSprite2D.new()
		skull.name = "SkullCoin"
		skull.sprite_frames = skull_sf
		skull.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		skull.centered = true
		skull.scale = Vector2(2.0, 2.0)
		skull.position = Vector2(1360, 114)
		skull.z_index = 1
		root.add_child(skull)
		skull.play("flip")
	_best = Label.new()
	_best.name = "Best"
	_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_best.add_theme_font_override("font", ThemeDB.fallback_font)
	_best.add_theme_font_size_override("font_size", 20)
	_best.add_theme_color_override("font_color", Color(MUTED.r, MUTED.g, MUTED.b, 0.72))
	_best.position = Vector2(1380, 100)
	_best.size = Vector2(260, 28)
	_best.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_best.z_index = 1
	root.add_child(_best)
	visible = false


func bind_sfx(sfx) -> void:
	_sfx = sfx


func hide_hud() -> void:
	visible = false
	_shown_n = 0
	_tick_count = 0


func shown_n() -> int:
	return _shown_n


func tick_count() -> int:
	return _tick_count


func counter_global_center() -> Vector2:
	if _n == null:
		return Vector2(1510, 68)
	return _n.get_global_rect().get_center()


## Keep the old floor on screen before the +1 lands (no fly, no tick).
func hold_floor(n: int, best: int) -> void:
	visible = true
	_n.text = COPY.fill("endless.hud.n", {"n": n}, str(n))
	var best_n: int = maxi(best, 0)
	_best.text = COPY.fill("endless.hud.best", {"n": maxi(best_n, n)}, "best %s" % maxi(best_n, n))
	_n.scale = Vector2.ONE
	_n.modulate = Color(GOLD.r, GOLD.g, GOLD.b, 1.0)
	_shown_n = n


func show_floor(n: int, best: int, fly: bool) -> void:
	visible = true
	## If the tally already applied this value, do not re-fly or re-tick.
	if n == _shown_n and _n.text == COPY.fill("endless.hud.n", {"n": n}, str(n)):
		var best_n: int = maxi(best, n)
		_best.text = COPY.fill("endless.hud.best", {"n": best_n}, "best %s" % best_n)
		return
	_n.text = COPY.fill("endless.hud.n", {"n": n}, str(n))
	var best_n2: int = maxi(best, n)
	_best.text = COPY.fill("endless.hud.best", {"n": best_n2}, "best %s" % best_n2)
	if fly and n != _shown_n:
		_fly_in()
	_shown_n = n


## Called when the flying +1 arrives. Increments exactly once per clear.
func receive_tally(n: int, best: int, new_best: bool, reduce_motion: bool = false) -> void:
	visible = true
	if n == _shown_n and _tick_count > 0 and _n.text == COPY.fill("endless.hud.n", {"n": n}, str(n)):
		return
	_n.text = COPY.fill("endless.hud.n", {"n": n}, str(n))
	_best.text = COPY.fill("endless.hud.best", {"n": best}, "best %s" % best)
	_shown_n = n
	_tick_count += 1
	_bump_counter(reduce_motion)
	if new_best:
		_glint_best(reduce_motion)


func _bump_counter(reduce_motion: bool) -> void:
	if _n == null:
		return
	if _bump_tw:
		_bump_tw.kill()
	_n.pivot_offset = Vector2(_n.size.x, _n.size.y * 0.5)
	_n.scale = Vector2.ONE
	_n.modulate = Color(1.15, 1.05, 0.75, 1.0)
	_bump_tw = create_tween()
	_bump_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if reduce_motion:
		_bump_tw.tween_property(_n, "modulate", GOLD, 0.12)
		return
	_bump_tw.tween_property(_n, "scale", Vector2(1.3, 1.3), 0.1)
	_bump_tw.tween_property(_n, "scale", Vector2.ONE, 0.14)
	_bump_tw.parallel().tween_property(_n, "modulate", GOLD, 0.2)


func _glint_best(reduce_motion: bool) -> void:
	if _best == null:
		return
	if _glint_tw:
		_glint_tw.kill()
	_glint_tw = create_tween()
	_glint_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var bright := Color(1.0, 1.0, 1.0, 1.0)
	var rest := Color(MUTED.r, MUTED.g, MUTED.b, 0.72)
	_best.modulate = bright
	if reduce_motion:
		_glint_tw.tween_property(_best, "modulate", rest, 0.2)
		return
	_glint_tw.tween_property(_best, "modulate", bright, 0.08)
	_glint_tw.tween_property(_best, "modulate", Color(1.0, 0.95, 0.7, 1.0), 0.12)
	_glint_tw.tween_property(_best, "modulate", rest, 0.22)


func _fly_in() -> void:
	if _n == null:
		return
	_n.scale = Vector2(2.4, 2.4)
	_n.modulate.a = 0.0
	_n.pivot_offset = Vector2(260, 40)
	## Confirm tick only. Do not fire sting.clear — that cue ducks the Music bus
	## −12 dB, and campaign never stings on dungeon enter.
	if _sfx != null and _sfx.has_method("play"):
		_sfx.play("confirm_big", -4.0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_n, "scale", Vector2.ONE, 0.42)
	tw.parallel().tween_property(_n, "modulate:a", 1.0, 0.18)
