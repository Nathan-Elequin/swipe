extends SceneTree
## Headless proof: cabin-wax draft stamps are 16×16 and ItemCard exposes overlay methods.
## Run: godot --headless --path . --script res://scripts/dev/draft_pick_seal_selftest.gd
## Does not boot main.gd.

const CARD := preload("res://scripts/item_card.gd")

const PATHS := [
	"res://assets/ui/draft/pick_seal.png",
	"res://assets/ui/draft/pick_seal_press_f0.png",
	"res://assets/ui/draft/pick_seal_press_f1.png",
	"res://assets/ui/draft/pick_seal_press_f2.png",
	"res://assets/ui/draft/pick_seal_press_f3.png",
	"res://assets/ui/draft/draft_leftbehind.png",
	"res://assets/ui/draft/recycle_return_f0.png",
	"res://assets/ui/draft/recycle_return_f1.png",
	"res://assets/ui/draft/recycle_return_f2.png",
	"res://assets/ui/draft/recycle_return_f3.png",
]


func _init() -> void:
	var failed := false
	for path in PATHS:
		failed = _png(path, 16) or failed
	var card: Control = CARD.new()
	failed = _check("play_draft_pick_seal", card.has_method("play_draft_pick_seal")) or failed
	failed = _check("show_draft_leftbehind", card.has_method("show_draft_leftbehind")) or failed
	failed = _check("play_recycle_return", card.has_method("play_recycle_return")) or failed
	failed = _check("clear_draft_stamp", card.has_method("clear_draft_stamp")) or failed
	card.free()
	print("draft_pick_seal_selftest failed=%s" % failed)
	quit(1 if failed else 0)


func _png(path: String, want: int) -> bool:
	if not FileAccess.file_exists(path):
		print("FAIL missing ", path)
		return true
	var img := Image.new()
	var err: Error = img.load(path)
	if err != OK:
		print("FAIL load ", path)
		return true
	var ok: bool = img.get_width() == want and img.get_height() == want
	print(("PASS " if ok else "FAIL ") + "%s %sx%s want %s" % [path, img.get_width(), img.get_height(), want])
	return not ok


func _check(label: String, ok: bool) -> bool:
	print(("PASS " if ok else "FAIL ") + label)
	return not ok
