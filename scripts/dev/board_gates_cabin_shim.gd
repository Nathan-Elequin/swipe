extends Node
## Tiny cabin stand-in for BoardSequences selftest. No real UI.


var items_by_id: Dictionary = {}
var _campaign_shell = null
var _rules: Dictionary = {}
var sfx = null
var hero_name := "Sprout"


func bind(rules: Dictionary, state: Dictionary) -> void:
	_rules = rules
	_campaign_shell = load("res://scripts/campaign_shell.gd").new()
	_campaign_shell.rules = rules
	_campaign_shell.state = state


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
