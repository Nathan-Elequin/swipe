extends Node
## Tiny cabin stand-in for BoardSequences selftest. No real UI.


var items_by_id: Dictionary = {}
var _campaign_shell = null
var _rules: Dictionary = {}
var sfx = null
var hero_name := "Sprout"
var _current_room := "hall"
var _int_root: Control = null


func _ready() -> void:
	_int_root = Control.new()
	_int_root.name = "RoomsClip"
	_int_root.visible = true
	add_child(_int_root)
	_ensure_fade()


func bind(rules: Dictionary, state: Dictionary) -> void:
	_rules = rules
	_campaign_shell = load("res://scripts/campaign_shell.gd").new()
	_campaign_shell.rules = rules
	_campaign_shell.state = state


func _ensure_fade() -> ColorRect:
	var wipe = get_node_or_null("BoardFadeWipe")
	if wipe is ColorRect:
		return wipe as ColorRect
	wipe = ColorRect.new()
	wipe.name = "BoardFadeWipe"
	wipe.color = Color("0B0706")
	wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wipe.size = Vector2(1680, 1040)
	wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wipe.z_index = 200
	wipe.visible = false
	wipe.modulate.a = 0.0
	add_child(wipe)
	return wipe as ColorRect


func hide_cabin_dev_strip() -> void:
	pass


func show_menu(room: String = "hall") -> void:
	_current_room = room


func pan_to(room: String) -> void:
	_current_room = room


func _biome_rules() -> Dictionary:
	return _rules


func _campaign_shell_state() -> Dictionary:
	if _campaign_shell != null:
		return _campaign_shell.state
	return {}


func bucket_reveal_for(bucket_n: int) -> Array:
	return [{"id": "spy_%d" % bucket_n, "name": "Spy", "kind": "item"}]


func _bucket_entries(bucket_n: int) -> Array:
	return bucket_reveal_for(bucket_n)
