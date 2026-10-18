extends SceneTree
## Headless checks for layout_check.gd. No main scene, no user://.

const CHECK := preload("res://scripts/dev/layout_check.gd")
const FIXTURE := "res://design/visual/layouts/_t2_selftest.layout.json"


func _initialize() -> void:
	var bad := 0
	bad += _case_pass()
	bad += _case_rect_off()
	bad += _case_missing()
	bad += _case_z_off()
	bad += _case_draw_rect_skip()
	bad += _case_file_roundtrip()
	var dotted := Node.new()
	dotted.name = "Route.Classic"
	print("DOT_NAME=", dotted.name)
	dotted.free()
	_delete(FIXTURE)
	_delete(CHECK.OUT_PATH)
	if bad == 0:
		print("LAYOUT_CHECK_SELFTEST ok")
		quit(0)
	else:
		print("LAYOUT_CHECK_SELFTEST fail ", bad)
		quit(1)


func _case_pass() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(220, 90, 1240, 860), 10)
	_box(host, "RouteTitle0", Rect2(260, 140, 380, 48), 12)
	var report := CHECK._evaluate(self, "self-pass", _layout([
		{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
		{"id": "RouteTitle0", "kind": "label", "rect": [260, 140, 380, 48], "z": 12},
	]), "")
	_free(host)
	return _expect("pass", report, 2, [])


func _case_rect_off() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(230, 90, 1240, 860), 10)
	var report := CHECK._evaluate(self, "self-rect", _layout([
		{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
	]), "")
	_free(host)
	return _expect("rect_off", report, 1, ["MapPanel:rect_off"])


func _case_missing() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(220, 90, 1240, 860), 10)
	var report := CHECK._evaluate(self, "self-missing", _layout([
		{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
		{"id": "RouteTitle0", "kind": "label", "rect": [260, 140, 380, 48], "z": 12},
	]), "")
	_free(host)
	return _expect("missing_node", report, 1, ["RouteTitle0:missing_node"])


func _case_z_off() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(220, 90, 1240, 860), 4)
	var report := CHECK._evaluate(self, "self-z", _layout([
		{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
	]), "")
	_free(host)
	return _expect("z_off", report, 1, ["MapPanel:z_off"])


func _case_draw_rect_skip() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(220, 90, 1240, 860), 10)
	var skipped := CHECK._evaluate(self, "self-draw", _layout([
		{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
		{"id": "PortraitDbg", "kind": "draw_rect", "rect": [1180, 600, 256, 256], "z": 11},
	]), "")
	var required := CHECK._evaluate(self, "self-draw-req", _layout([
		{"id": "PortraitDbg", "kind": "draw_rect", "rect": [1180, 600, 256, 256], "required": true},
	]), "")
	_free(host)
	var bad := _expect("draw_rect_skip", skipped, 1, [])
	bad += _expect("draw_rect_required", required, 0, ["PortraitDbg:missing_node"])
	return bad


func _case_file_roundtrip() -> int:
	var host := _host()
	_box(host, "MapPanel", Rect2(220, 90, 1240, 860), 10)
	var body := {
		"id": "_t2_selftest",
		"viewport": [1680, 1040],
		"units": "viewport_px",
		"origin": "top-left",
		"y": "down",
		"nodes": [
			{"id": "MapPanel", "kind": "ninepatch", "rect": [220, 90, 1240, 860], "z": 10},
		],
	}
	var f := FileAccess.open(FIXTURE, FileAccess.WRITE)
	if f == null:
		print("FAIL file_roundtrip: cannot write fixture")
		_free(host)
		return 1
	f.store_string(JSON.stringify(body))
	f.close()
	var report: Dictionary = CHECK.layout_check("_t2_selftest", self)
	_free(host)
	if not FileAccess.file_exists(CHECK.OUT_PATH):
		print("FAIL file_roundtrip: layout_check.json missing")
		return 1
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHECK.OUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		print("FAIL file_roundtrip: output is not JSON")
		return 1
	var disk: Dictionary = parsed
	if str(disk.get("layout", "")) != "_t2_selftest" or int(disk.get("checked", -1)) != 1:
		print("FAIL file_roundtrip: ", JSON.stringify(disk))
		return 1
	if (disk.get("failures", []) as Array).size() != (report.get("failures", []) as Array).size():
		print("FAIL file_roundtrip: disk failures differ")
		return 1
	print("PASS file_roundtrip checked=1 failures=0")
	return 0


func _layout(nodes: Array) -> Dictionary:
	return {"id": "self", "nodes": nodes}


func _host() -> Control:
	var host := Control.new()
	host.name = "LayoutCheckHost"
	host.position = Vector2.ZERO
	host.size = Vector2(1680, 1040)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(host)
	return host


func _box(parent: Node, node_name: String, rect: Rect2, z: int) -> void:
	var c := Control.new()
	c.name = node_name
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.z_index = z
	c.position = rect.position
	c.size = rect.size
	parent.add_child(c)


func _expect(label: String, report: Dictionary, checked: int, reasons: Array) -> int:
	var got: Array = []
	for row in report.get("failures", []):
		got.append("%s:%s" % [row.get("id", ""), row.get("reason", "")])
	var ok := int(report.get("checked", -1)) == checked and _same(got, reasons)
	print(("PASS " if ok else "FAIL "), label, " checked=", report.get("checked", -1), " failures=", JSON.stringify(got))
	if not ok:
		print("  expected checked=", checked, " failures=", JSON.stringify(reasons))
		print("  report=", JSON.stringify(report))
		return 1
	return 0


func _same(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if str(a[i]) != str(b[i]):
			return false
	return true


func _free(n: Node) -> void:
	if n != null and is_instance_valid(n):
		n.free()


func _delete(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
