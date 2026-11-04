extends CanvasLayer
class_name FrameMetrics
## Dev/playtest frame-time overlay (F8). Hidden until opened. Does not change combat.
## Frames over SPIKE_MS leave a cheap breadcrumb in capture JSON
## (`spike_markers`) so a shared ~100 ms hitch can be hunted without
## speculative rewrites.
## Feel spans (`span_begin` / `span_end`) time spin→callout, item resolve,
## Take apply, and draft→hotbar when main hooks them — instrument only.

const STAMP := preload("res://scripts/frame_metrics_stamp.gd")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

const SCENARIOS: Array[String] = [
	"cabin_idle",
	"fight_idle",
	"attack_x5",
	"spin_x5",
	"lunge_x5",
	"transition_x3",
	"tut_brand_new_yes",
]

## Named feel spans main.gd (and friends) can bookend. Cheap; no FX change.
const FEEL_SPANS: Array[String] = [
	"spin_to_callout",
	"use_item_resolve",
	"take_apply",
	"draft_to_hotbar",
]

## Scorecard shared hitch sits ~98–101 ms; 50 ms catches that band without
## flooding every 16.7 ms spike into the JSON.
const SPIKE_MS := 50.0
const SPIKE_KEEP := 12
const ROLL_KEEP := 120
const SPAN_KEEP := 32

static var wheel_redraws: int = 0
static var stage_redraws: int = 0
static var hall_redraws: int = 0
static var slash_redraws: int = 0
static var place_calls: int = 0
static var place_early: int = 0
static var place_usec: int = 0
## Full (non-early-out) place cost — spike tags use these, not place_calls.
static var place_full: int = 0
static var place_full_usec: int = 0
## Optional last-known tag from a hot path (`note_tag("spin")`).
## Cleared each capture frame after spike recording so a stale tag cannot stick.
static var last_tag: String = ""
## True only while a scenario capture is armed (span samples land in capture JSON).
static var _cap_armed: bool = false
static var _span_t0: Dictionary = {}
static var _span_session: Dictionary = {}
static var _span_capture: Dictionary = {}

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
var _base_full: int = 0
var _base_full_usec: int = 0
var _spike_16: int = 0
var _spike_33: int = 0
var _spike_50: int = 0
var _heavy_frames: int = 0
var _heavy_max: int = 0
var _samples := PackedFloat32Array()
var _proc := PackedFloat32Array()
var _draws := PackedFloat32Array()
var _roll := PackedFloat32Array()
var _roll_spike_50: int = 0
var _spike_markers: Array = []
var _prev_wheel: int = 0
var _prev_stage: int = 0
var _prev_hall: int = 0
var _prev_slash: int = 0
var _prev_place: int = 0
var _prev_place_full: int = 0
var _prev_place_full_usec: int = 0
var _cap_sha: String = ""
var _cap_dirty: bool = false
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
	else:
		place_full += 1
		place_full_usec += maxi(0, usec)


static func note_tag(tag: String) -> void:
	if tag == "":
		return
	last_tag = tag


static func span_begin(span: String) -> void:
	if span == "":
		return
	_span_t0[span] = Time.get_ticks_usec()
	note_tag(span)


static func span_end(span: String) -> void:
	if span == "" or not _span_t0.has(span):
		return
	var t0: int = int(_span_t0[span])
	_span_t0.erase(span)
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	_push_span_sample(_span_session, span, ms, SPAN_KEEP)
	if _cap_armed:
		_push_span_sample(_span_capture, span, ms, 0)


static func span_cancel(span: String) -> void:
	if span == "":
		return
	_span_t0.erase(span)


static func _push_span_sample(bucket: Dictionary, span: String, ms: float, keep: int) -> void:
	var arr: PackedFloat32Array
	if bucket.has(span):
		arr = bucket[span] as PackedFloat32Array
	else:
		arr = PackedFloat32Array()
	arr.push_back(ms)
	if keep > 0:
		while arr.size() > keep:
			arr.remove_at(0)
	bucket[span] = arr


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
		KEY_7:
			idx = 6
	if idx < 0 or idx >= SCENARIOS.size():
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
		# Warm the stamp cache before any capture. BuildStamp.from_repo()
		# shells out to `git status`; paying that on key 1–7 was the shared
		# ~100 ms first-frame hitch on every Scorecard scenario.
		STAMP.text()
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
	_cap_armed = true
	# Snapshot stamp before _t0 so a cold cache refresh cannot land inside
	# the first captured frame (Scorecard shared ~100 ms hitch).
	_cap_sha = STAMP.sha_hex()
	_cap_dirty = STAMP.dirty()
	_t0 = Time.get_ticks_usec()
	_base_wheel = wheel_redraws
	_base_stage = stage_redraws
	_base_hall = hall_redraws
	_base_slash = slash_redraws
	_base_place = place_calls
	_base_early = place_early
	_base_usec = place_usec
	_base_full = place_full
	_base_full_usec = place_full_usec
	_spike_16 = 0
	_spike_33 = 0
	_spike_50 = 0
	_heavy_frames = 0
	_heavy_max = 0
	_samples = PackedFloat32Array()
	_proc = PackedFloat32Array()
	_draws = PackedFloat32Array()
	_spike_markers = []
	_span_capture = {}
	_prev_wheel = wheel_redraws
	_prev_stage = stage_redraws
	_prev_hall = hall_redraws
	_prev_slash = slash_redraws
	_prev_place = place_calls
	_prev_place_full = place_full
	_prev_place_full_usec = place_full_usec
	last_tag = ""
	_last_summary = "capturing " + scenario
	set_process(true)
	_refresh_label()


func _stop_pressed() -> void:
	if _capturing:
		_stop()


func _process(delta: float) -> void:
	var ms := delta * 1000.0
	if _open:
		_roll.push_back(ms)
		if ms > SPIKE_MS:
			_roll_spike_50 += 1
		while _roll.size() > ROLL_KEEP:
			var dropped: float = float(_roll[0])
			_roll.remove_at(0)
			if dropped > SPIKE_MS:
				_roll_spike_50 = maxi(0, _roll_spike_50 - 1)
	# While the overlay is open (idle) or a capture is armed, watch for
	# frames over SPIKE_MS. Only an armed capture appends into the JSON.
	if _capturing:
		if ms > SPIKE_MS:
			_spike_50 += 1
			_record_spike(ms)
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
		_bump_prev_counters()
		# Drop sticky hot-path tag after the frame is booked — next frame
		# must re-assert (early-out place floods used to pin last_tag).
		last_tag = ""
	if not _open:
		return
	_ui_wait -= delta
	if _ui_wait > 0.0:
		return
	_ui_wait = 0.25
	_refresh_label()


func _bump_prev_counters() -> void:
	_prev_wheel = wheel_redraws
	_prev_stage = stage_redraws
	_prev_hall = hall_redraws
	_prev_slash = slash_redraws
	_prev_place = place_calls
	_prev_place_full = place_full
	_prev_place_full_usec = place_full_usec


func _record_spike(ms: float) -> void:
	var d_wheel := wheel_redraws - _prev_wheel
	var d_stage := stage_redraws - _prev_stage
	var d_hall := hall_redraws - _prev_hall
	var d_slash := slash_redraws - _prev_slash
	var d_place := place_calls - _prev_place
	var d_place_full := place_full - _prev_place_full
	var place_full_delta := place_full_usec - _prev_place_full_usec
	var heavy := FX_BUDGET.heavy_count()
	var marker := {
		"frame_ms": ms,
		"frame_i": _samples.size(),
		"heavy": heavy,
		"scenario": _scenario,
		"tag": _spike_tag(d_wheel, d_stage, d_hall, d_slash, d_place_full, place_full_delta, heavy),
		"last_tag": last_tag,
		"dirty": _cap_dirty,
		"baked_sha": STAMP.GIT_SHA,
		"sha": _cap_sha,
		"ticks_msec": Time.get_ticks_msec(),
		"os": OS.get_name(),
		"d_wheel": d_wheel,
		"d_stage": d_stage,
		"d_hall": d_hall,
		"d_slash": d_slash,
		"d_place": d_place,
		"d_place_full": d_place_full,
		"place_full_usec": place_full_delta,
		"process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
	}
	_spike_markers.append(marker)
	while _spike_markers.size() > SPIKE_KEEP:
		_spike_markers.remove_at(0)


func _spike_tag(
	d_wheel: int,
	d_stage: int,
	d_hall: int,
	d_slash: int,
	d_place_full: int,
	place_full_delta: int,
	heavy: int
) -> String:
	# Prefer an explicit hot-path tag when present (cleared each frame).
	if last_tag != "":
		return last_tag
	# Early-out place_calls must not win the tag — only real full places.
	var best := "unknown"
	var best_n := 0
	var place_score := d_place_full
	if place_full_delta > 0:
		# usec beats a bare count of 1 when comparing to redraw tallies.
		place_score = maxi(place_score, 1 + place_full_delta / 1000)
	if place_score > best_n:
		best = "place_fight_art"
		best_n = place_score
	if d_slash > best_n:
		best = "slash"
		best_n = d_slash
	if d_wheel > best_n:
		best = "wheel"
		best_n = d_wheel
	if d_stage > best_n:
		best = "stage"
		best_n = d_stage
	if d_hall > best_n:
		best = "hall"
		best_n = d_hall
	if best_n <= 0 and heavy > 0:
		return "heavy"
	return best


func _refresh_label() -> void:
	if _label == null:
		return
	# During a capture, reuse the arm snapshot — never refresh git status
	# on the 0.25s label tick (that was the shared ~100 ms hitch).
	var sha := _cap_sha if _capturing and _cap_sha != "" else STAMP.sha_hex()
	var dirty := ""
	if _capturing:
		dirty = " dirty" if _cap_dirty else ""
	elif STAMP.dirty():
		dirty = " dirty"
	var live := ""
	if _capturing and not _samples.is_empty():
		live = "  %.1f ms" % _samples[_samples.size() - 1]
	elif not _roll.is_empty():
		live = "  %.1f ms  roll>%.0f %d" % [
			_roll[_roll.size() - 1],
			SPIKE_MS,
			_roll_spike_50,
		]
	elif Engine.get_frames_per_second() > 0:
		live = "  %d fps" % Engine.get_frames_per_second()
	var cap := "idle"
	if _capturing:
		var sec := float(Time.get_ticks_usec() - _t0) / 1000000.0
		cap = "REC %s  %.1fs  spikes %d/%d  >%.0f %d" % [
			_scenario,
			sec,
			_spike_16,
			_spike_33,
			SPIKE_MS,
			_spike_50,
		]
	elif _last_summary != "":
		cap = _last_summary
	var heavy_now := FX_BUDGET.heavy_count()
	var spans := _span_line()
	_label.text = "sha %s%s%s\n%s\n%s\nheavy %d\nF8 hide   1-7 capture   same key stops" % [
		sha,
		dirty,
		live,
		cap,
		spans,
		heavy_now,
	]


func _span_line() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for span in FEEL_SPANS:
		var src: Dictionary = _span_capture if _capturing and not _span_capture.is_empty() else _span_session
		if not src.has(span):
			continue
		var arr: PackedFloat32Array = src[span] as PackedFloat32Array
		if arr.is_empty():
			continue
		parts.append("%s last %.0f p50 %.0f n=%d" % [
			span,
			float(arr[arr.size() - 1]),
			_p50(arr),
			arr.size(),
		])
	if parts.is_empty():
		return "spans — (hooks idle)"
	return "spans  " + " | ".join(parts)


func _stop() -> void:
	if not _capturing:
		return
	_capturing = false
	_cap_armed = false
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
	var markers: Array = _spike_markers.duplicate()
	var note := ""
	if _spike_50 <= 0:
		note = "no frames over %.0f ms" % SPIKE_MS
	else:
		var last: Dictionary = markers[markers.size() - 1] if not markers.is_empty() else {}
		note = "spike_markers: %d frame(s) over %.0f ms (kept last %d); last tag=%s heavy=%s frame_ms=%.1f" % [
			_spike_50,
			SPIKE_MS,
			SPIKE_KEEP,
			str(last.get("tag", "")),
			str(last.get("heavy", 0)),
			float(last.get("frame_ms", 0.0)),
		]
	return {
		"sha": _cap_sha if _cap_sha != "" else STAMP.sha_hex(),
		"baked_sha": STAMP.GIT_SHA,
		"dirty": _cap_dirty if _cap_sha != "" else STAMP.dirty(),
		"godot": godot,
		"platform": OS.get_name(),
		"web": OS.has_feature("web"),
		"viewport": [int(vp.x), int(vp.y)],
		"scenario": _scenario,
		"note": note,
		"spike_ms_threshold": SPIKE_MS,
		"spike_markers": markers,
		"duration_sec": dur,
		"frames": frames,
		"fps": float(frames) / dur,
		"frame_ms": {
			"avg": _avg(_samples),
			"p50": _p50(_samples),
			"p95": _p95(_samples),
			"max": _max(_samples),
		},
		"spikes": {
			"over_16_7": _spike_16,
			"over_33_3": _spike_33,
			"over_50": _spike_50,
		},
		"feel_spans": _span_report(_span_capture),
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
			"full_per_sec": float(place_full - _base_full) / dur,
			"usec_total": usec,
			"usec_avg": (float(usec) / float(place_n)) if place_n > 0 else 0.0,
			"full_usec_total": place_full_usec - _base_full_usec,
			"full_usec_avg": (
				float(place_full_usec - _base_full_usec) / float(place_full - _base_full)
			) if (place_full - _base_full) > 0 else 0.0,
		},
	}


func _span_report(bucket: Dictionary) -> Dictionary:
	var out := {}
	for span in FEEL_SPANS:
		if not bucket.has(span):
			out[span] = {"n": 0, "last": 0.0, "p50": 0.0, "p95": 0.0, "max": 0.0, "samples_ms": []}
			continue
		var arr: PackedFloat32Array = bucket[span] as PackedFloat32Array
		var listed: Array = []
		for v in arr:
			listed.append(float(v))
		out[span] = {
			"n": arr.size(),
			"last": float(arr[arr.size() - 1]) if not arr.is_empty() else 0.0,
			"p50": _p50(arr),
			"p95": _p95(arr),
			"max": _max(arr),
			"samples_ms": listed,
		}
	return out


func _summary_line(report: Dictionary, path: String) -> String:
	var frame: Dictionary = report.get("frame_ms", {})
	var spikes: Dictionary = report.get("spikes", {})
	return "%s  avg %.1f  p50 %.1f  p95 %.1f  max %.1f  >16.7 %s  >33.3 %s\n%s" % [
		str(report.get("scenario", "")),
		float(frame.get("avg", 0.0)),
		float(frame.get("p50", 0.0)),
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
	var stem := "%s_%s_%s" % [_safe(str(report.get("scenario", "cap"))), plat, _safe(sha)]
	var named := "user://perf/%s.json" % stem
	var last := "user://perf/last_capture.json"
	var csv_named := "user://perf/%s.csv" % stem
	var csv_last := "user://perf/last_capture.csv"
	var csv_text := _csv(report)
	_store(named, text)
	_store(last, text)
	_store(csv_named, csv_text)
	_store(csv_last, csv_text)
	if OS.has_feature("web"):
		var fname := named.get_file()
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), fname, "application/json")
		JavaScriptBridge.download_buffer(csv_text.to_utf8_buffer(), csv_named.get_file(), "text/csv")
	return ProjectSettings.globalize_path(named)


func _csv(report: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("kind,span,n,p50_ms,p95_ms,max_ms,avg_ms,spikes_over_16_7,spikes_over_33_3,spikes_over_50,scenario,sha,notes")
	var frame: Dictionary = report.get("frame_ms", {})
	var spikes: Dictionary = report.get("spikes", {})
	lines.append("%s,%s,%s,%.3f,%.3f,%.3f,%.3f,%s,%s,%s,%s,%s,\"%s\"" % [
		"frame",
		"frame",
		str(report.get("frames", 0)),
		float(frame.get("p50", 0.0)),
		float(frame.get("p95", 0.0)),
		float(frame.get("max", 0.0)),
		float(frame.get("avg", 0.0)),
		str(spikes.get("over_16_7", 0)),
		str(spikes.get("over_33_3", 0)),
		str(spikes.get("over_50", 0)),
		_safe(str(report.get("scenario", ""))),
		_safe(str(report.get("sha", ""))),
		str(report.get("note", "")).replace("\"", "'"),
	])
	var feel: Dictionary = report.get("feel_spans", {})
	for span in FEEL_SPANS:
		var row: Dictionary = feel.get(span, {})
		lines.append("%s,%s,%s,%.3f,%.3f,%.3f,%.3f,,,,%s,%s,\"\"" % [
			"feel_span",
			span,
			str(row.get("n", 0)),
			float(row.get("p50", 0.0)),
			float(row.get("p95", 0.0)),
			float(row.get("max", 0.0)),
			float(row.get("last", 0.0)),
			_safe(str(report.get("scenario", ""))),
			_safe(str(report.get("sha", ""))),
		])
	return "\n".join(lines) + "\n"


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
	return _percentile(samples, 0.95)


func _p50(samples: PackedFloat32Array) -> float:
	return _percentile(samples, 0.50)


func _percentile(samples: PackedFloat32Array, p: float) -> float:
	if samples.is_empty():
		return 0.0
	var copy := samples.duplicate()
	copy.sort()
	var idx := int(floor(float(copy.size() - 1) * p))
	idx = clampi(idx, 0, copy.size() - 1)
	return float(copy[idx])
