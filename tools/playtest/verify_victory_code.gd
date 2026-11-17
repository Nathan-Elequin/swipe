extends SceneTree
## Headless verifier twin of tools/playtest/verify_victory_code.py.
##
## Run:
##   godot --headless --path . --script res://tools/playtest/verify_victory_code.gd -- <anon_id> <code> [milestone]


const VC := preload("res://scripts/playtest_victory_code.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		## Also accept raw cmdline after `--`.
		args = OS.get_cmdline_args()
		var cut := args.find("--")
		if cut >= 0 and cut + 1 < args.size():
			args = args.slice(cut + 1)
		else:
			args = PackedStringArray()
	if args.size() < 2:
		printerr("Usage: verify_victory_code.gd -- <anon_id> <code> [milestone]")
		quit(2)
		return
	var anon_id := str(args[0])
	var code := str(args[1])
	var milestone := str(args[2]) if args.size() > 2 else "big"
	var expected: String = VC.generate(anon_id, milestone)
	var ok: bool = VC.verify(anon_id, code, milestone)
	print("VALID" if ok else "INVALID")
	print("expected=%s" % expected)
	print("got=%s" % (VC.normalize(code) if VC.normalize(code) != "" else code.strip_edges()))
	quit(0 if ok else 1)
