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
	# last_tag clears each capture frame — assert on the spike frame only.
	metrics.note_tag("qa_spike")
	node._process(0.098)
	metrics.span_begin("spin_to_callout")
	OS.delay_usec(12000)
	metrics.span_end("spin_to_callout")
	metrics.span_begin("use_item_resolve")
	OS.delay_usec(8000)
	metrics.span_end("use_item_resolve")
	node._stop()
	var path := "user://perf/last_capture.json"
	if not FileAccess.file_exists(path):
		push_error("missing last_capture.json")
		quit(1)
		return
	var csv_path := "user://perf/last_capture.csv"
	if not FileAccess.file_exists(csv_path):
		push_error("missing last_capture.csv")
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
	if int(report.get("frames", 0)) != 22:
		push_error("frame count %s" % str(report.get("frames", 0)))
		quit(1)
		return
	var spikes: Dictionary = report.get("spikes", {})
	if int(spikes.get("over_16_7", 0)) != 22 or int(spikes.get("over_33_3", 0)) != 2:
		push_error("spike counts %s" % str(spikes))
		quit(1)
		return
	if int(spikes.get("over_50", 0)) != 1:
		push_error("over_50 %s" % str(spikes.get("over_50", 0)))
		quit(1)
		return
	var markers: Variant = report.get("spike_markers", [])
	if typeof(markers) != TYPE_ARRAY or (markers as Array).is_empty():
		push_error("spike_markers missing")
		quit(1)
		return
	var first: Dictionary = (markers as Array)[0]
	if float(first.get("frame_ms", 0.0)) < 90.0:
		push_error("spike frame_ms %s" % str(first.get("frame_ms", 0.0)))
		quit(1)
		return
	if str(first.get("tag", "")) != "qa_spike":
		push_error("spike tag %s" % str(first.get("tag", "")))
		quit(1)
		return
	if str(report.get("note", "")).find("spike_markers") < 0:
		push_error("note missing spike_markers summary")
		quit(1)
		return
	var frame: Dictionary = report.get("frame_ms", {})
	if float(frame.get("max", 0.0)) < 90.0:
		push_error("max frame ms %s" % str(frame))
		quit(1)
		return
	if not frame.has("p50"):
		push_error("frame_ms missing p50")
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
	if float(place.get("full_usec_total", 0.0)) != 70.0:
		push_error("full place usec %s" % str(place))
		quit(1)
		return
	if not first.has("place_full_usec"):
		push_error("spike missing place_full_usec")
		quit(1)
		return
	var feel: Dictionary = report.get("feel_spans", {})
	var spin_span: Dictionary = feel.get("spin_to_callout", {})
	if int(spin_span.get("n", 0)) < 1:
		push_error("spin_to_callout missing from feel_spans")
		quit(1)
		return
	var csv_body := FileAccess.get_file_as_string(csv_path)
	if csv_body.find("feel_span") < 0 or csv_body.find("spin_to_callout") < 0:
		push_error("csv missing feel_span rows")
		quit(1)
		return
	print("FRAME_METRICS_RUN_OK")
	quit(0)
