extends CanvasLayer
## Top-right Endless dungeon counter. Current floor is large; best is faint.

const COPY := preload("res://scripts/player_copy.gd")
const GOLD := Color("e8c36a")
const MUTED := Color("a8946c")

var _n: Label
var _best: Label
var _sfx
var _shown_n: int = 0


func _ready() -> void:
	layer = 72
	name = "EndlessHud"
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
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
	root.add_child(_n)
	_best = Label.new()
	_best.name = "Best"
	_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_best.add_theme_font_override("font", ThemeDB.fallback_font)
	_best.add_theme_font_size_override("font_size", 20)
	_best.add_theme_color_override("font_color", Color(MUTED.r, MUTED.g, MUTED.b, 0.72))
	_best.position = Vector2(1380, 100)
	_best.size = Vector2(260, 28)
	_best.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_best)
	visible = false


func bind_sfx(sfx) -> void:
	_sfx = sfx


func hide_hud() -> void:
	visible = false
	_shown_n = 0


func show_floor(n: int, best: int, fly: bool) -> void:
	visible = true
	_n.text = COPY.fill("endless.hud.n", {"n": n}, str(n))
	var best_n: int = maxi(best, n)
	_best.text = COPY.fill("endless.hud.best", {"n": best_n}, "best %s" % best_n)
	if fly and n != _shown_n:
		_fly_in()
	_shown_n = n


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
