extends Node
## Nib finds Grandpa's map scrap when a cabinet banks across 5/5.
## Only call from the extract bank sequence — never cheats, death, or Push interrupt.

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")

var cabin
var _busy: bool = false


func setup(p_cabin) -> void:
	cabin = p_cabin
	name = "MapPieceBeat"
	process_mode = Node.PROCESS_MODE_ALWAYS


func is_busy() -> bool:
	return _busy


## filled_pool is the cabinet that just crossed quota. Stamps the *next* biome.
func play(filled_pool: String) -> void:
	if _busy or cabin == null or filled_pool == "":
		return
	var shell = cabin._campaign_shell
	if shell == null:
		return
	_busy = true
	var nxt: Dictionary = SHELL.stamp_map_piece(shell.rules, shell.state, filled_pool)
	if shell.has_method("write"):
		shell.write()
	var next_name := str(nxt.get("name", ""))
	if next_name == "":
		_busy = false
		return
	await _ceremony(next_name)
	_busy = false


func _ceremony(next_name: String) -> void:
	var dialog = cabin._dialog
	var vars := {"next": next_name}
	_set_nib("gasp")
	KIT.cue(cabin.sfx if cabin else null, &"speech.nib_gasp")
	if dialog == null:
		await _thunk()
		return
	dialog.say(["nib.piece.squint"], [], vars)
	await dialog.finished
	_set_nib("point")
	# Sprout's soft confused beat.
	if dialog.has_method("say_bubble"):
		dialog.say_bubble("sprout.piece.huh", Vector2(216, 150), vars)
		await _pause(0.85)
	else:
		dialog.say(["sprout.piece.huh"], [], vars)
		await dialog.finished
	_set_nib("talk")
	dialog.say(["nib.piece.grandpa"], [], vars)
	await dialog.finished
	await _thunk()
	_set_nib("point")
	dialog.say(["nib.piece.stamped"], [], vars)
	await dialog.finished
	_set_nib("idle")


func _thunk() -> void:
	# THUNK: scrap flash + shake + stamp cue. nib_tape frames optional (art stubs OK).
	_flash_scrap()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.stamp_thunk")
	await _shake(0.28, 7.0)


func _flash_scrap() -> void:
	if cabin == null or not cabin is Control:
		return
	var scrap_tex: Texture2D = KIT.load_tex("overlays/map_scrap.png")
	if scrap_tex == null:
		# Fall back to wax seal if scrap art is missing — never block the beat.
		scrap_tex = KIT.load_tex("overlays/wax_seal.png")
	if scrap_tex == null:
		return
	var host := cabin as Control
	var scrap := TextureRect.new()
	scrap.texture = scrap_tex
	scrap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scrap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrap.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	scrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrap.z_index = 20
	scrap.size = Vector2(120, 90)
	scrap.position = Vector2(host.size.x * 0.5 - 60.0, host.size.y * 0.42)
	scrap.modulate.a = 0.0
	host.add_child(scrap)
	var tw := host.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(scrap, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.35)
	tw.tween_property(scrap, "modulate:a", 0.0, 0.18)
	tw.tween_callback(scrap.queue_free)


func _shake(sec: float, amp: float) -> void:
	if cabin == null or not cabin is Control:
		await _pause(sec)
		return
	var host := cabin as Control
	var base := host.position
	var tw := host.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var steps := maxi(3, int(sec / 0.04))
	for _i in steps:
		tw.tween_property(
			host,
			"position",
			base + Vector2(randf_range(-amp, amp), randf_range(-amp * 0.6, amp * 0.6)),
			0.04
		)
	tw.tween_property(host, "position", base, 0.05)
	await tw.finished


func _set_nib(anim: String) -> void:
	if cabin == null:
		return
	var rooms: Variant = cabin._rooms
	if typeof(rooms) != TYPE_DICTIONARY:
		return
	var main_room = (rooms as Dictionary).get("main", null)
	if main_room == null or main_room.nib == null or main_room.nib.sprite_frames == null:
		return
	if main_room.nib.sprite_frames.has_animation(anim):
		main_room.nib.play(anim)


func _pause(sec: float) -> void:
	if not is_inside_tree():
		return
	await get_tree().create_timer(sec, true, true, true).timeout
