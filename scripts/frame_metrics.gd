extends CanvasLayer
class_name FrameMetrics
## Dev frame-time overlay (F8). Hidden until opened. Does not change combat.

const STAMP := preload("res://scripts/frame_metrics_stamp.gd")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

const SCENARIOS: Array[String] = [
	"cabin_idle",
	"fight_idle",
	"attack_x5",
	"spin_x5",
	"lunge_x5",
	"transition_x3",
]

static var wheel_redraws: int = 0
static var stage_redraws: int = 0
static var hall_redraws: int = 0
static var slash_redraws: int = 0
static var place_calls: int = 0
static var place_early: int = 0
static var place_usec: int = 0

var _open: bool = false
var _capturing: bool = false
var _scenario: String = ""
var _t0: int = 0
var _ui_wait: float = 0.0
var _base_wheel: int = 0
var _base_stage: int = 0
var _base_hall: int = 0
var _base_slash: int = 0
var _base_place: int = 0
var _base_early: int = 0
var _base_usec: int = 0
var _spike_16: int = 0
var _spike_33: int = 0
var _heavy_frames: int = 0
var _heavy_max: int = 0
var _samples := PackedFloat32Array()
var _proc := PackedFloat32Array()
var _draws := PackedFloat32Array()
var _last_summary: String = ""
var _panel: PanelContainer
var _label: Label


static func attach(parent: Node) -> void:
	if parent == null:
		return
	if parent.get_node_or_null("FrameMetrics") != null:
		return
	var scr := load("res://scripts/frame_metrics.gd") as GDScript
	var node: CanvasLayer = scr.new()
	node.name = "FrameMetrics"
	parent.add_child(node)


static func note_wheel() -> void:
	wheel_redraws += 1


static func note_stage() -> void:
	stage_redraws += 1


static func note_hall() -> void:
	hall_redraws += 1


static func note_slash() -> void:
	slash_redraws += 1


static func note_place(usec: int, early: bool) -> void:
	place_calls += 1
	place_usec += usec
	if early:
		place_early += 1


func _ready() -> void:
	layer = 190
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	_build_panel()
	_panel.visible = false


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.position = Vector2(8, 8)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _plate())
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	_panel.add_child(box)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.focus_mode = Control.FOCUS_NONE
	_label.add_theme_font_override("font", ThemeDB.fallback_font)
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", Color("f0e6d8"))
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(_label)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(grid)
	for i in SCENARIOS.size():
		var id := SCENARIOS[i]
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = "%d %s" % [i + 1, id]
		btn.add_theme_font_override("font", ThemeDB.fallback_font)
		btn.add_theme_font_size_override("font_size", 11)
		btn.pressed.connect(_arm.bind(id))
		grid.add_child(btn)
	var stop := Button.new()
	stop.focus_mode = Control.FOCUS_NONE
	stop.text = "stop"
	stop.add_theme_font_override("font", ThemeDB.fallback_font)
	stop.add_theme_font_size_override("font_size", 11)
	stop.pressed.connect(_stop_pressed)
	box.add_child(stop)
	add_child(_panel)


func _plate() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.04, 0.03, 0.025, 0.88)
	box.border_color = Color("100e0c")
	box.set_border_width_all(1)
	box.content_margin_left = 6
	box.content_margin_right = 6
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	return box


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.keycode == KEY_F8:
		_toggle()
		get_viewport().set_input_as_handled()
		return
	if not _open or _typing():
		return
	var idx := -1
	match key.keycode:
		KEY_1:
			idx = 0
		KEY_2:
			idx = 1
		KEY_3:
			idx = 2
		KEY_4:
			idx = 3
		KEY_5:
			idx = 4
		KEY_6:
			idx = 5
	if idx < 0:
		return
	_arm(SCENARIOS[idx])
	get_viewport().set_input_as_handled()


func _typing() -> bool:
	var focus := get_viewport().gui_get_focus_owner()
	return focus is LineEdit or focus is TextEdit


func _toggle() -> void:
	_open = not _open
	_panel.visible = _open
	if _open:
		_ui_wait = 0.0
		_refresh_label()
	set_process(_open or _capturing)


func _arm(scenario: String) -> void:
	if _capturing and _scenario == scenario:
		_stop()
		return
	if _capturing:
		_stop()
	_scenario = scenario
	_capturing = true
	_t0 = Time.get_ticks_usec()
	_base_wheel = wheel_redraws
	_base_stage = stage_redraws
	_base_hall = hall_redraws
	_base_slash = slash_redraws
	_base_place = place_calls
	_base_early = place_early
	_base_usec = place_usec
	_spike_16 = 0
	_spike_33 = 0
	_heavy_frames = 0
	_heavy_max = 0
	_samples = PackedFloat32Array()
	_proc = PackedFloat32Array()
	_draws = PackedFloat32Array()
	_last_summary = "capturing " + scenario
	set_process(true)
	_refresh_label()


func _stop_pressed() -> void:
	if _capturing:
		_stop()


func _process(delta: float) -> void:
	if _capturing:
		var ms := delta * 1000.0
		_samples.push_back(ms)
		if ms > 16.7:
			_spike_16 += 1
		if ms > 33.3:
			_spike_33 += 1
		_proc.push_back(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
		_draws.push_back(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var heavy := FX_BUDGET.heavy_count()
		if heavy > 0:
			_heavy_frames += 1
		if heavy > _heavy_max:
			_heavy_max = heavy
	if not _open:
		return
	_ui_wait -= delta
	if _ui_wait > 0.0:
		return
	_ui_wait = 0.25
	_refresh_label()


func _refresh_label() -> void:
	if _label == null:
		return
	var sha := STAMP.sha_hex()
	var dirty := " dirty" if STAMP.dirty() else ""
	var live := ""
	if not _samples.is_empty():
		live = "  %.1f ms" % _samples[_samples.size() - 1]
	elif Engine.get_frames_per_second() > 0:
		live = "  %d fps" % Engine.get_frames_per_second()
	var cap := "idle"
	if _capturing:
		var sec := float(Time.get_ticks_usec() - _t0) / 1000000.0
		cap = "REC %s  %.1fs  spikes %d/%d" % [_scenario, sec, _spike_16, _spike_33]
	elif _last_summary != "":
		cap = _last_summary
	var heavy_now := FX_BUDGET.heavy_count()
	_label.text = "sha %s%s%s\n%s\nheavy %d\nF8 hide   1-6 capture   same key stops" % [sha, dirty, live, cap, heavy_now]


func _stop() -> void:
	if not _capturing:
		return
	_capturing = false
	set_process(_open)
	var dur := float(Time.get_ticks_usec() - _t0) / 1000000.0
	if dur < 0.05 or _samples.is_empty():
		_last_summary = "too short"
		_refresh_label()
		return
	var report := _report(dur)
	var path := _write(report)
	_last_summary = _summary_line(report, path)
	print("FRAME_METRICS ", path)
	print("FRAME_METRICS_DIR ", OS.get_user_data_dir())
	_refresh_label()


func _report(dur: float) -> Dictionary:
	var frames := _samples.size()
	var info := Engine.get_version_info()
	var godot := "%s.%s.%s" % [info.get("major", 0), info.get("minor", 0), info.get("patch", 0)]
	var vp := Vector2.ZERO
	if get_viewport() != null:
		vp = get_viewport().get_visible_rect().size
	var place_n := place_calls - _base_place
	var wheel_n := wheel_redraws - _base_wheel
	var stage_n := stage_redraws - _base_stage
	var hall_n := hall_redraws - _base_hall
	var slash_n := slash_redraws - _base_slash
	var usec := place_usec - _base_usec
	return {
		"sha": STAMP.sha_hex(),
		"baked_sha": STAMP.GIT_SHA,
		"dirty": STAMP.dirty(),
		"godot": godot,
		"platform": OS.get_name(),
		"web": OS.has_feature("web"),
		"viewport": [int(vp.x), int(vp.y)],
		"scenario": _scenario,
		"note": "",
		"duration_sec": dur,
		"frames": frames,
		"fps": float(frames) / dur,
		"frame_ms": {
			"avg": _avg(_samples),
			"p95": _p95(_samples),
			"max": _max(_samples),
		},
		"spikes": {
			"over_16_7": _spike_16,
			"over_33_3": _spike_33,
		},
		"process_ms": {
			"avg": _avg(_proc),
			"max": _max(_proc),
		},
		"draw_calls": {
			"avg": _avg(_draws),
			"max": _max(_draws),
		},
		"heavy": {
			"max": _heavy_max,
			"pct_frames": (100.0 * float(_heavy_frames) / float(frames)) if frames > 0 else 0.0,
		},
		"redraws_per_sec": {
			"wheel": float(wheel_n) / dur,
			"stage": float(stage_n) / dur,
			"hall": float(hall_n) / dur,
			"slash": float(slash_n) / dur,
		},
		"place_fight_art": {
			"calls_per_sec": float(place_n) / dur,
			"early_outs_per_sec": float(place_early - _base_early) / dur,
			"usec_total": usec,
			"usec_avg": (float(usec) / float(place_n)) if place_n > 0 else 0.0,
		},
	}


func _summary_line(report: Dictionary, path: String) -> String:
	var frame: Dictionary = report.get("frame_ms", {})
	var spikes: Dictionary = report.get("spikes", {})
	return "%s  avg %.1f  p95 %.1f  max %.1f  >16.7 %s  >33.3 %s\n%s" % [
		str(report.get("scenario", "")),
		float(frame.get("avg", 0.0)),
		float(frame.get("p95", 0.0)),
		float(frame.get("max", 0.0)),
		str(spikes.get("over_16_7", 0)),
		str(spikes.get("over_33_3", 0)),
		path,
	]


func _write(report: Dictionary) -> String:
	var text := JSON.stringify(report, "\t")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://perf"))
	var sha := str(report.get("sha", "nosha"))
	var plat := _safe(str(report.get("platform", "os")))
	var named := "user://perf/%s_%s_%s.json" % [_safe(str(report.get("scenario", "cap"))), plat, _safe(sha)]
	var last := "user://perf/last_capture.json"
	_store(named, text)
	_store(last, text)
	if OS.has_feature("web"):
		var fname := named.get_file()
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), fname, "application/json")
	return ProjectSettings.globalize_path(named)


func _store(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("frame metrics could not write %s" % path)
		return
	f.store_string(text)
	f.close()


func _safe(raw: String) -> String:
	var out := ""
	for i in raw.length():
		var c := raw.substr(i, 1)
		var ok := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_" or c == "-"
		out += c if ok else "_"
	return out


func _avg(samples: PackedFloat32Array) -> float:
	if samples.is_empty():
		return 0.0
	var total := 0.0
	for v in samples:
		total += float(v)
	return total / float(samples.size())


func _max(samples: PackedFloat32Array) -> float:
	var m := 0.0
	for v in samples:
		m = maxf(m, float(v))
	return m


func _p95(samples: PackedFloat32Array) -> float:
	if samples.is_empty():
		return 0.0
	var copy := samples.duplicate()
	copy.sort()
	var idx := int(floor(float(copy.size() - 1) * 0.95))
	idx = clampi(idx, 0, copy.size() - 1)
	return float(copy[idx])
