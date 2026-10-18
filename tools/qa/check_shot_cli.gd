extends SceneTree
## Parses the shot CLI and the harness registry. Does not boot main.gd or touch user://home_cabin.json.

func _init() -> void:
	var cli = load("res://scripts/shot_cli.gd")
	if cli == null:
		push_error("shot_cli failed to parse")
		quit(1)
		return
	if cli.enabled_for(true, PackedStringArray(["--shots=all"])):
		push_error("template build must ignore --shots")
		quit(1)
		return
	if not cli.enabled_for(false, PackedStringArray(["--shots=30_hub_idle"])):
		push_error("cli --shots should enable")
		quit(1)
		return
	if cli.enabled_for(false, PackedStringArray()):
		push_error("empty args must not enable")
		quit(1)
		return
	if not cli.enabled_for(false, PackedStringArray(["--shots="])):
		push_error("empty --shots= should still enable and then fail in the harness")
		quit(1)
		return
	if cli.list_raw(PackedStringArray(["--shots="])) != "":
		push_error("empty --shots= should pass an empty list")
		quit(1)
		return
	var alias: String = cli.list_raw(PackedStringArray(["--text-targets"]))
	if alias != cli.TEXT_TARGETS:
		push_error("text-targets alias mismatch")
		quit(1)
		return
	var prefer: String = cli.list_raw(PackedStringArray(["--text-targets", "--shots=30_hub_idle"]))
	if prefer != "30_hub_idle":
		push_error("--shots should win over --text-targets")
		quit(1)
		return
	if cli.out_dir(PackedStringArray(["--shots-out=res://design/audit-shots/cursor"])) != "res://design/audit-shots/cursor":
		push_error("shots-out parse failed")
		quit(1)
		return
	if cli.out_dir(PackedStringArray()) != cli.DEFAULT_OUT:
		push_error("default out dir mismatch")
		quit(1)
		return
	var parsed: PackedStringArray = cli.parse_names(" 30_hub_idle ,text_item_hand.png, ")
	if parsed.size() != 2 or parsed[0] != "30_hub_idle" or parsed[1] != "text_item_hand":
		push_error("parse_names failed: %s" % ",".join(parsed))
		quit(1)
		return
	var flag := FileAccess.get_file_as_string("res://scripts/dev_flag.gd")
	if not flag.contains("return OS.has_feature(\"editor\")"):
		push_error("DevFlag.on must stay editor-only")
		quit(1)
		return
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	if not main_src.contains("SHOT_CLI.enabled"):
		push_error("main.gd does not gate shots through ShotCli")
		quit(1)
		return
	if main_src.contains("begin_text_targets"):
		push_error("begin_text_targets should be gone")
		quit(1)
		return
	call_deferred("_async_check")


func _async_check() -> void:
	var harness_scr = load("res://scripts/dev/shot_harness.gd")
	if harness_scr == null:
		push_error("shot_harness failed to parse")
		quit(1)
		return
	var harness = harness_scr.new()
	root.add_child(harness)
	var err: String = harness.self_check()
	if err != "":
		push_error(err)
		quit(1)
		return
	var async_err: String = await harness.self_check_async()
	if async_err != "":
		push_error(async_err)
		quit(1)
		return
	var names: PackedStringArray = harness.shot_names()
	print("SHOT_COUNT %s" % names.size())
	for stem in names:
		print("SHOT_NAME %s" % stem)
	print("SHOT_CLI_OK")
	quit(0)
