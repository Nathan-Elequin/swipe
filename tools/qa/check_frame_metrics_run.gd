extends SceneTree
## Headless capture smoke. Does not boot main.gd.

func _init() -> void:
	var metrics := load("res://scripts/frame_metrics.gd")
	if metrics == null:
		push_error("frame_metrics failed to parse")
		quit(1)
		return
	var node: CanvasLayer = metrics.new()
	root.add_child(node)
	node._arm("fight_idle")
	node._t0 = Time.get_ticks_usec() - 1000000
	metrics.note_wheel()
	metrics.note_stage()
	metrics.note_hall()
	metrics.note_slash()
	metrics.note_place(30, true)
	metrics.note_place(70, false)
	for _i in 20:
		node._process(0.020)
	node._process(0.040)
	node._stop()
	var path := "user://perf/last_capture.json"
	if not FileAccess.file_exists(path):
		push_error("missing last_capture.json")
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("capture is not a dictionary")
		quit(1)
		return
	var report: Dictionary = parsed
	if str(report.get("scenario", "")) != "fight_idle":
		push_error("scenario mismatch")
		quit(1)
		return
	if int(report.get("frames", 0)) != 21:
		push_error("frame count %s" % str(report.get("frames", 0)))
		quit(1)
		return
	var spikes: Dictionary = report.get("spikes", {})
	if int(spikes.get("over_16_7", 0)) != 21 or int(spikes.get("over_33_3", 0)) != 1:
		push_error("spike counts %s" % str(spikes))
		quit(1)
		return
	var frame: Dictionary = report.get("frame_ms", {})
	if float(frame.get("max", 0.0)) < 39.0:
		push_error("max frame ms %s" % str(frame))
		quit(1)
		return
	if str(report.get("sha", "")) == "":
		push_error("sha empty")
		quit(1)
		return
	var place: Dictionary = report.get("place_fight_art", {})
	if float(place.get("usec_total", 0.0)) != 100.0:
		push_error("place usec %s" % str(place))
		quit(1)
		return
	print("FRAME_METRICS_RUN_OK")
	quit(0)
