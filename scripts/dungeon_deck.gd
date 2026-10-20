extends Control
## Dungeon Deck: the Challenge monster deck beside the wheel.
## A short stack of card backs with the next monster face up on top (face down when the next
## monster is hidden). Pixel's card art is 32x44 native, shipped 4x; drawn at exactly 3x here.

signal draw_finished
signal hovered
signal unhovered
signal edit_wanted

const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const BACK := Color("1a1410")
const RIM := Color("c4a574")
const GOLD := Color("e8c36a")
const INK := Color("f0e6d8")
const WARN := Color("e07040")
const EMPTY := Color("8b1e1e")
const OUTLINE := Color("100e0c")

const NATIVE := Vector2i(32, 44)
const PX := 3                                   # screen px per native px
const CARD := Vector2(96, 132)                  # NATIVE * PX
const CARD_POS := Vector2(4, 8)                 # top card, top-left (local)
const STACK_STEP := Vector2(3, 3)               # 1 native px down-right per card underneath
# Native-pixel rects on card_front.png (see design/visual/sizes/new-content-batch12-deck.sizes.json).
const WINDOW_N := Rect2i(7, 7, 18, 17)          # monster window interior
const LOWER_N := Rect2i(5, 28, 22, 11)          # plain lower third: name + Weak/Tough/Deadly plate
const PLATE_FILL := [Color("3a2a1a"), Color("172636"), Color("3a1014")]
const PLATE_RIM := [Color("a8784a"), Color("5a8ac4"), Color("c43a3a")]

const SLIDE_S := 0.25
const FLIP_HALF_S := 0.08
const RIFFLE_S := 0.4

var count: int = 0
var art_tex: Texture2D
var peek_tex: Texture2D
var peek_name: String = ""
var peek_tier: int = 0
## Global point the drawn card slides toward (e.g. the wheel slot it lands in). INF = slide left.
var entry_global: Vector2 = Vector2.INF

var _busy: bool = false
var _back: Texture2D
var _front: Texture2D
var _slot: Texture2D
var _sack: Texture2D
var _warn_t: float = 0.0

var _face_up: bool = false
var _awaiting_face: bool = false
var _flip_sx: float = 1.0
var _flip_sy: float = 1.0
var _flipping: bool = false
var _depth_hold: int = -1
var _slide_t: float = 0.0
var _out: Dictionary = {}
var _riffle_t: float = -1.0


func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(148, 168)
	z_index = 8
	mouse_entered.connect(_on_in)
	mouse_exited.connect(_on_out)
	gui_input.connect(_on_gui)
	if ResourceLoader.exists("res://assets/dungeon/home/loot_sack_dropped.png"):
		_sack = load("res://assets/dungeon/home/loot_sack_dropped.png")
	_back = _at_3x("res://assets/ui/deck/playing_card.png")
	_front = _at_3x("res://assets/ui/deck/card_front.png")
	_slot = _at_3x("res://assets/ui/deck/card_slot_empty.png")
	texture_filter = TEXTURE_FILTER_NEAREST


## Shipped PNGs are 4x. Nearest-sample down to native, then up to exactly 3x, so every
## native pixel is a clean 3x3 block instead of the 4x->3x drop-a-column look.
func _at_3x(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path)
	if tex == null:
		return null
	var img: Image = tex.get_image()
	if img == null:
		return tex
	if img.is_compressed():
		img.decompress()
	img = img.duplicate()
	img.resize(NATIVE.x, NATIVE.y, Image.INTERPOLATE_NEAREST)
	img.resize(NATIVE.x * PX, NATIVE.y * PX, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)


func set_count(n: int) -> void:
	count = maxi(0, n)
	if count <= 0:
		_face_up = false
		_awaiting_face = false
	_sync_mouse()
	set_process(true)
	queue_redraw()


## who == "" means no next monster to show (deck empty, or the mode hides it): top stays face down.
func set_peek(tex: Texture2D, who: String, tier: int = -1) -> void:
	peek_tex = tex
	peek_name = who.strip_edges()
	if tier >= 0:
		peek_tier = tier
	_sync_mouse()
	if not _busy and not _flipping:
		if peek_name == "" or count <= 0:
			_face_up = false
			_awaiting_face = false
			_depth_hold = -1
		elif _awaiting_face:
			_awaiting_face = false
			_flip_up()
		elif not _face_up:
			_face_up = true
	queue_redraw()


func set_peek_tier(tier: int) -> void:
	peek_tier = tier
	queue_redraw()


func _sync_mouse() -> void:
	var on: bool = count > 0 and peek_name != ""
	mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if on else Control.CURSOR_ARROW


func _on_in() -> void:
	if count <= 0 or peek_name == "":
		return
	hovered.emit()


func _on_out() -> void:
	unhovered.emit()


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if (OS.has_feature("editor") or PLAYTEST_FLAG.on()) and peek_name != "":
			edit_wanted.emit()
		accept_event()


func is_busy() -> bool:
	return _busy


static func depth_for(under: int) -> int:
	if under > 6:
		return 3
	if under >= 3:
		return 2
	if under >= 1:
		return 1
	return 0


## Run start: ~0.4s riffle of backs, then the top card flips face up (if the next monster is shown).
func play_shuffle() -> void:
	_busy = true
	_face_up = false
	_riffle_t = 0.0
	set_process(true)
	var tw := create_tween()
	tw.tween_property(self, "_riffle_t", 1.0, RIFFLE_S).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	_riffle_t = -1.0
	_busy = false
	if count > 0 and peek_name != "":
		await _flip_up()
	elif count > 0:
		_awaiting_face = true
	queue_redraw()


## A monster leaves the deck: the top card slides toward the entry point and fades (0.25s, ease out).
## The next card flips face up once main hands over its peek (set_peek), and depth updates after.
func play_draw() -> void:
	if count <= 0:
		return
	_busy = true
	_out = {"face": _face_up and peek_name != "", "tex": peek_tex, "name": peek_name, "tier": peek_tier}
	_depth_hold = depth_for(count - 1)
	count = maxi(0, count - 1)
	_face_up = false
	_slide_t = 0.0
	set_process(true)
	var tw := create_tween()
	tw.tween_property(self, "_slide_t", 1.0, SLIDE_S).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	_out = {}
	_slide_t = 0.0
	_busy = false
	if count > 0:
		_awaiting_face = true
	else:
		_depth_hold = -1
	queue_redraw()
	draw_finished.emit()


func _flip_up() -> void:
	_flipping = true
	_flip_sx = 1.0
	_flip_sy = 1.0
	set_process(true)
	var tw := create_tween()
	tw.tween_property(self, "_flip_sx", 0.0, FLIP_HALF_S).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(_flip_swap)
	tw.tween_property(self, "_flip_sx", 1.0, FLIP_HALF_S).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "_flip_sy", 1.0, FLIP_HALF_S).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tw.finished
	_flip_sx = 1.0
	_flip_sy = 1.0
	_flipping = false
	_depth_hold = -1
	queue_redraw()


func _flip_swap() -> void:
	_face_up = peek_name != "" and count > 0
	_flip_sy = 1.05


func _animating() -> bool:
	return _busy or _flipping or _riffle_t >= 0.0 or not _out.is_empty()


func _process(delta: float) -> void:
	var warn: bool = count <= 2
	if _animating() or warn:
		queue_redraw()
	if warn:
		_warn_t += delta * 5.0
	else:
		_warn_t = 0.0
		if not _animating():
			set_process(false)


func _draw() -> void:
	if _riffle_t >= 0.0:
		_draw_riffle(_riffle_t)
	elif count <= 0:
		if _slot != null:
			draw_texture_rect(_slot, Rect2(CARD_POS, CARD), false, Color(1, 1, 1, 0.38))
	else:
		var depth: int = _depth_hold if _depth_hold >= 0 else depth_for(count - 1)
		for k in range(depth, 0, -1):
			_draw_card(CARD_POS + STACK_STEP * float(k), false)
		var c := CARD_POS + CARD * 0.5
		draw_set_transform(c, 0.0, Vector2(_flip_sx, _flip_sy))
		var show_face: bool = _face_up and peek_name != ""
		_draw_card(-CARD * 0.5, show_face, peek_tex, peek_name, peek_tier)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not _out.is_empty():
		var a: float = 1.0 - _slide_t
		var off: Vector2 = (_slide_target() * _slide_t).round()
		_draw_card(CARD_POS + off, bool(_out.get("face", false)), _out.get("tex"), str(_out.get("name", "")), int(_out.get("tier", 0)), Color(1, 1, 1, a))
	_draw_loot_bags()
	var font: Font = ThemeDB.fallback_font
	var lab := str(count)
	var fs := 22
	var tsz: Vector2 = font.get_string_size(lab, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	var ink: Color = GOLD
	if count <= 0:
		ink = EMPTY
	elif count <= 2:
		ink = WARN
	var p := Vector2((110.0 - tsz.x) * 0.5, size.y - 2.0)
	draw_string(font, p + Vector2(1, 1), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, OUTLINE)
	draw_string(font, p, lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)


func _slide_target() -> Vector2:
	var dir := Vector2(-150.0, 12.0)
	if entry_global.is_finite():
		var to: Vector2 = get_global_transform().affine_inverse() * entry_global - (CARD_POS + CARD * 0.5)
		dir = to * 0.7
		if dir.length() > 180.0:
			dir = dir.normalized() * 180.0
	return dir


func _draw_riffle(t: float) -> void:
	# Two half-stacks split apart, interleave, and square back up into one pile.
	var spread: float = sin(t * PI) * 20.0
	var lift: float = sin(t * PI) * 6.0
	var cards: int = clampi(count, 2, 6)
	for i in cards:
		var left: bool = i % 2 == 0
		var drop: float = clampf((t - float(i) / float(cards) * 0.5) * 2.0, 0.0, 1.0)
		var dx: float = (-spread if left else spread) * (1.0 - drop * 0.35)
		var dy: float = -lift * (1.0 - drop) - float(i) * 1.0
		var c := (CARD_POS + CARD * 0.5 + Vector2(dx, dy)).round()
		var rot: float = (-0.08 if left else 0.08) * sin(t * PI)
		draw_set_transform(c, rot, Vector2.ONE)
		_draw_card(-CARD * 0.5, false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_card(pos: Vector2, face: bool, tex: Texture2D = null, who: String = "", tier: int = 0, tint: Color = Color.WHITE) -> void:
	var r := Rect2(pos, CARD)
	if not face:
		if _back != null:
			draw_texture_rect(_back, r, false, tint)
		else:
			draw_rect(r, BACK * tint, true)
			draw_rect(r, RIM * tint, false, 2.0)
			if art_tex != null:
				draw_texture_rect(art_tex, Rect2(r.position + (r.size - Vector2(32, 32)) * 0.5, Vector2(32, 32)), false, tint)
		return
	if _front != null:
		draw_texture_rect(_front, r, false, tint)
	else:
		draw_rect(r, Color("3a2e22") * tint, true)
		draw_rect(r, RIM * tint, false, 2.0)
	if tex != null:
		var win := Rect2(pos + Vector2(WINDOW_N.position * PX), Vector2(WINDOW_N.size * PX))
		var ts: Vector2 = tex.get_size()
		var k: float = minf(win.size.x / maxf(ts.x, 1.0), win.size.y / maxf(ts.y, 1.0))
		var ds: Vector2 = (ts * k).floor()
		draw_texture_rect(tex, Rect2((win.position + (win.size - ds) * 0.5).round(), ds), false, tint)
	_draw_lower(Rect2(pos + Vector2(LOWER_N.position * PX), Vector2(LOWER_N.size * PX)), who, tier, tint)


func _draw_lower(box: Rect2, who: String, tier: int, tint: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	if who != "":
		var wfs := 13
		var wsz: Vector2 = font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs)
		while wsz.x > box.size.x - 2.0 and wfs > 9:
			wfs -= 1
			wsz = font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs)
		var top_h: float = box.size.y if tier <= 0 else box.size.y * 0.5
		var wp := Vector2(box.position.x + (box.size.x - wsz.x) * 0.5, box.position.y + (top_h + font.get_ascent(wfs) - font.get_descent(wfs)) * 0.5).round()
		draw_string(font, wp + Vector2(1, 1), who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, OUTLINE * tint)
		draw_string(font, wp, who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, INK * tint)
	if tier <= 0:
		return
	var ti: int = clampi(tier, 1, 3) - 1
	var word: String = PLAYER_COPY.tier_name(tier)
	var pfs := 10
	var psz: Vector2 = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, pfs)
	var pw: float = minf(box.size.x, float(ceili((psz.x + 10.0) / PX)) * PX)
	var ph: float = 15.0
	var plate := Rect2((Vector2(box.position.x + (box.size.x - pw) * 0.5, box.end.y - ph - 1.0)).round(), Vector2(pw, ph))
	draw_rect(plate, OUTLINE * tint, true)
	draw_rect(plate.grow(-1.0), PLATE_RIM[ti] * tint, true)
	draw_rect(plate.grow(-2.0), PLATE_FILL[ti] * tint, true)
	var tp := Vector2(plate.position.x + (pw - psz.x) * 0.5, plate.position.y + (ph + font.get_ascent(pfs) - font.get_descent(pfs)) * 0.5).round()
	draw_string(font, tp, word, HORIZONTAL_ALIGNMENT_LEFT, -1, pfs, INK * tint)


func _draw_loot_bags() -> void:
	var bags: int = mini(count, 12)
	if bags <= 0:
		return
	var pulse: float = 1.0
	var tint := Color.WHITE
	if count <= 2:
		tint = WARN if count > 0 else EMPTY
		pulse = 0.78 + 0.22 * (0.5 + 0.5 * sin(_warn_t))
	tint.a = pulse
	var x := 112.0
	var step := 22.0
	var top := 18.0
	for i in bags:
		var r := Rect2(x, top + float(i) * step, 32, 32)
		if _sack != null:
			draw_texture_rect(_sack, r, false, tint)
		else:
			draw_rect(r.grow(-4.0), tint, true)
			draw_rect(r.grow(-4.0), GOLD, false, 1.2)
