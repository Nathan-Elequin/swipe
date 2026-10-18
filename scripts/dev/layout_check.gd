extends RefCounted
## Compare a running scene to design/visual/layouts/<id>.layout.json.
## Node.name must equal JSON "id". Rects are viewport px, top-left origin, +/-2 px.
## Shot harness calls layout_check(layout_id) after a capture.

const TOL := 2.0
const LAYOUT_DIR := "res://design/visual/layouts/"
const OUT_PATH := "res://design/audit-shots/cursor/layout_check.json"


static func layout_check(layout_id: String, tree: SceneTree) -> Dictionary:
	var path := LAYOUT_DIR + layout_id + ".layout.json"
	var data := _read_json(path)
	var report: Dictionary = _evaluate(tree, layout_id, data, path)
	_write(report)
	return report


static func _evaluate(tree: SceneTree, layout_id: String, data: Dictionary, path: String) -> Dictionary:
	var failures: Array = []
	var checked := 0
	if data.is_empty():
		failures.append({
			"id": layout_id,
			"reason": "missing_node",
			"expected": path,
			"actual": null,
		})
	else:
		var root: Node = tree.root if tree != null else null
		for entry in _entries(data):
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var id := str(entry.get("id", ""))
			if id == "":
				continue
			var node := _find(root, id)
			if node == null:
				if str(entry.get("kind", "")) == "draw_rect" and not bool(entry.get("required", false)):
					continue
				failures.append({
					"id": id,
					"reason": "missing_node",
					"expected": entry.get("rect", null),
					"actual": null,
				})
				continue
			checked += 1
			var want: Variant = entry.get("rect", null)
			if want is Array and (want as Array).size() >= 4:
				var got := _measure(node)
				var exp := want as Array
				if _rect_off(got, exp):
					failures.append({
						"id": id,
						"reason": "rect_off",
						"expected": [exp[0], exp[1], exp[2], exp[3]],
						"actual": [got.position.x, got.position.y, got.size.x, got.size.y],
					})
			if entry.has("z"):
				var want_z := int(entry.get("z", 0))
				var got_z: Variant = null
				if node is CanvasItem:
					got_z = (node as CanvasItem).z_index
				if got_z == null or int(got_z) != want_z:
					failures.append({
						"id": id,
						"reason": "z_off",
						"expected": want_z,
						"actual": got_z,
					})
	return {
		"updated": _now(),
		"layout": layout_id,
		"checked": checked,
		"failures": failures,
	}


static func _entries(data: Dictionary) -> Array:
	var out: Array = []
	if data.has("nodes"):
		for n in data.get("nodes", []):
			out.append(n)
		return out
	_walk_elements(data.get("elements", []), out)
	return out


static func _walk_elements(arr: Variant, out: Array) -> void:
	if typeof(arr) != TYPE_ARRAY:
		return
	for e in arr:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		out.append(e)
		_walk_elements((e as Dictionary).get("children", []), out)


static func _find(n: Node, id: String) -> Node:
	if n == null:
		return null
	if str(n.name) == id:
		return n
	for c in n.get_children():
		var hit := _find(c, id)
		if hit != null:
			return hit
	return null


static func _measure(n: Node) -> Rect2:
	if n is Control:
		return (n as Control).get_global_rect()
	if n is Sprite2D:
		return _xform_rect(n as CanvasItem, (n as Sprite2D).get_rect())
	if n is AnimatedSprite2D:
		return _xform_rect(n as CanvasItem, _anim_local(n as AnimatedSprite2D))
	if n is CanvasItem:
		var origin: Vector2 = (n as CanvasItem).get_global_transform_with_canvas().origin
		return Rect2(origin, Vector2.ZERO)
	return Rect2()


static func _anim_local(an: AnimatedSprite2D) -> Rect2:
	if an.sprite_frames == null:
		return Rect2()
	var tex: Texture2D = an.sprite_frames.get_frame_texture(an.animation, an.frame)
	if tex == null:
		return Rect2()
	var sz := tex.get_size()
	var origin := Vector2.ZERO if not an.centered else -sz * 0.5
	return Rect2(origin, sz)


static func _xform_rect(ci: CanvasItem, local: Rect2) -> Rect2:
	var xf := ci.get_global_transform_with_canvas()
	var p: Vector2 = xf * local.position
	var s: Vector2 = xf.basis_xform(local.size)
	return Rect2(p, s.abs())


static func _rect_off(got: Rect2, exp: Array) -> bool:
	var nums: Array[float] = [
		got.position.x, got.position.y, got.size.x, got.size.y,
	]
	for i in 4:
		if absf(nums[i] - float(exp[i])) > TOL:
			return true
	return false


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


static func _write(report: Dictionary) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_PATH).get_base_dir()
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f == null:
		push_error("layout_check: cannot write %s" % OUT_PATH)
		return
	f.store_string(JSON.stringify(report, "\t"))


static func _now() -> String:
	return Time.get_datetime_string_from_system(true)
