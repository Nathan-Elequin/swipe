extends SceneTree
## Headless checks for New Game picker card vignettes (batch2).
## Run: godot --headless --path . --script res://scripts/dev/title_picker_vignettes_selftest.gd


const OK_MARK := "TITLE_PICKER_VIGNETTES_OK"
const FAIL_MARK := "TITLE_PICKER_VIGNETTES_FAIL"
const PICKER := preload("res://scripts/playtest_commitment_picker.gd")

const VIGNETTE_PATHS := {
	"quick": "res://assets/ui/title/picker/card_vignette_quick.png",
	"deeper": "res://assets/ui/title/picker/card_vignette_deeper.png",
	"big": "res://assets/ui/title/picker/card_vignette_big.png",
}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var failed := false
	var rows: Array = []

	failed = _check_assets(rows, failed) or failed
	failed = await _check_picker(rows, failed) or failed
	failed = _check_no_banned_words(rows, failed) or failed

	for r in rows:
		print(r)
	if failed:
		print("%s: see rows above" % FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String) -> bool:
	rows.append("%s %s%s" % ["PASS" if ok else "FAIL", name, (": " + detail) if (not ok and detail != "") else ""])
	return failed or not ok


func _tex_size(path: String) -> Vector2i:
	var img := Image.new()
	var abs_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	if img.load(abs_path) != OK:
		return Vector2i(-1, -1)
	return Vector2i(img.get_width(), img.get_height())


func _opaque_bbox_nonempty(path: String) -> bool:
	var img := Image.new()
	var abs_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	if img.load(abs_path) != OK:
		return false
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.05:
				return true
	return false


func _import_filter_off(path: String) -> bool:
	var imp := path + ".import"
	if not FileAccess.file_exists(imp):
		return true
	var txt := FileAccess.get_file_as_string(imp)
	if txt.find("process/filter=false") >= 0 or txt.find('filter="Nearest"') >= 0:
		return true
	if txt.find("process/filter=0") >= 0:
		return true
	## Godot 4.7 UI textures: lossless + no mipmaps; canvas nearest is project default.
	if txt.find("mipmaps/generate=false") >= 0 and txt.find("compress/mode=0") >= 0:
		return true
	return txt.find("type=\"CompressedTexture2D\"") >= 0


func _check_assets(rows: Array, failed: bool) -> bool:
	for id in ["quick", "deeper", "big"]:
		var p: String = VIGNETTE_PATHS[id]
		var sz := _tex_size(p)
		failed = _check(rows, failed, "asset.size.%s" % id, sz == Vector2i(200, 112), str(sz)) or failed
		failed = _check(rows, failed, "asset.filter.%s" % id, _import_filter_off(p), "") or failed
		failed = _check(rows, failed, "asset.opaque.%s" % id, _opaque_bbox_nonempty(p), "") or failed
	return failed


func _check_picker(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var picker: ColorRect = PICKER.new() as ColorRect
	host.add_child(picker)
	picker.setup()
	picker.open_picker("choose", 0, {})
	await process_frame
	await process_frame

	var expected := {
		"quick": "card_vignette_quick.png",
		"deeper": "card_vignette_deeper.png",
		"big": "card_vignette_big.png",
	}
	for id in ["quick", "deeper", "big"]:
		var card: Control = null
		for c in picker.get_children():
			if c is PanelContainer and str(c.get_meta("id", "")) == id:
				card = c
				break
		failed = _check(rows, failed, "card.%s.exists" % id, card != null, "") or failed
		if card == null:
			continue
		var vig: TextureRect = card.find_child("Vignette", true, false) as TextureRect
		failed = _check(rows, failed, "card.%s.vignette" % id, vig != null, "") or failed
		if vig == null:
			continue
		failed = _check(rows, failed, "card.%s.size" % id, vig.size == Vector2(400, 224), str(vig.size)) or failed
		failed = _check(rows, failed, "card.%s.x" % id, vig.position.x >= 16.0 and vig.position.x <= 24.0, str(vig.position.x)) or failed
		var bottom: float = vig.position.y + vig.size.y
		failed = _check(rows, failed, "card.%s.bottom" % id, bottom <= 240.0, str(bottom)) or failed
		var path := ""
		if vig.texture != null:
			path = String(vig.texture.resource_path)
		failed = _check(rows, failed, "card.%s.map" % id, path.ends_with(expected[id]), path) or failed
		## Presenter / GoalMark / labels still present and below the vignette band.
		var title_l: Label = card.find_child("Title", true, false) as Label
		var biome_l: Label = card.find_child("Biome", true, false) as Label
		var line_l: Label = card.find_child("Goal", true, false) as Label
		if line_l == null:
			line_l = card.find_child("Line", true, false) as Label
		failed = _check(rows, failed, "card.%s.title_below" % id, title_l != null and title_l.position.y >= 240.0, str(title_l.position.y if title_l else -1)) or failed
		failed = _check(rows, failed, "card.%s.biome_below" % id, biome_l != null and biome_l.position.y >= 240.0, str(biome_l.position.y if biome_l else -1)) or failed
		failed = _check(rows, failed, "card.%s.line_below" % id, line_l != null and line_l.position.y >= 240.0, str(line_l.position.y if line_l else -1)) or failed
		failed = _check(rows, failed, "card.%s.presenter" % id, card.find_child("Presenter", true, false) != null, "") or failed
		failed = _check(rows, failed, "card.%s.goalmark" % id, card.find_child("GoalMark", true, false) != null, "") or failed
		failed = _check(rows, failed, "card.%s.pick" % id, card.find_child("Pick", true, false) != null, "") or failed
	picker.queue_free()
	return failed


func _check_no_banned_words(rows: Array, failed: bool) -> bool:
	## Player-facing literals only (internal TIER_* / playtest.tier.* keys stay).
	var banned_tier := '"' + "Tier" + '"'
	var banned_atk := '"' + "ATK" + '"'
	var paths := [
		"res://scripts/playtest_commitment_picker.gd",
	]
	for p in paths:
		var abs_path := ProjectSettings.globalize_path(p)
		if not FileAccess.file_exists(abs_path):
			continue
		var txt := FileAccess.get_file_as_string(abs_path)
		var bad := txt.find(banned_tier) >= 0 or txt.find(banned_atk) >= 0
		failed = _check(rows, failed, "no_tier_atk.%s" % p.get_file(), not bad, "") or failed
	return failed
