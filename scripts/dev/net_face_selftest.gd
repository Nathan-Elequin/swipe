extends SceneTree
## Headless proof: Net face is a bare burst; 1/2/3 chip parks bottom-right.
## Does not boot main.gd.

const CARD := preload("res://scripts/item_card.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	## Mirror main._face_rows("net"): bare impact, no on-icon range text.
	var rows: Array = [[_fg("impact", "", "blue")]]
	failed = _check("one_row", rows.size() == 1) or failed
	failed = _check("one_cell", (rows[0] as Array).size() == 1) or failed
	var cell: Dictionary = (rows[0] as Array)[0]
	failed = _check("impact_key", str(cell.get("k", "")) == "impact") or failed
	failed = _check("no_on_icon_text", str(cell.get("t", "")) == "") or failed
	failed = _check("blue_tint", str(cell.get("tint", "")) == "blue") or failed

	var card: PanelContainer = CARD.new()
	root.add_child(card)
	card.setup(1, "net", "−1–3", null, Color("5c2626"), Color("c0c0c0"), "Net", Color.WHITE, "BLK", null)
	card.set_glyphs(rows)
	card.set_choice_badge("1 / 2 / 3")
	## Force a layout pass so chrome children have positions.
	card.size = Vector2(CARD.CARD_W, CARD.CARD_H)
	card.queue_sort()
	await process_frame
	await process_frame

	var badge: Label = _find_choice_badge(card)
	failed = _check("badge_present", badge != null and badge.visible) or failed
	if badge != null:
		var face_h: float = CARD.CARD_H
		failed = _check("badge_bottom_half", badge.position.y > face_h * 0.5) or failed
		failed = _check("badge_right_half", badge.position.x > CARD.CARD_W * 0.4) or failed
		failed = _check("badge_text", badge.text.find("1") >= 0 and badge.text.find("3") >= 0) or failed

	card.queue_free()
	if failed:
		push_error("net_face self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK net_face")
		quit(0)


func _fg(k: String, t: String = "", tint: String = "", border: String = "", sup: String = "", icon: String = "") -> Dictionary:
	return {"k": k, "t": t, "tint": tint, "border": border, "sup": sup, "id": icon}


func _find_choice_badge(host: Node) -> Label:
	for n in host.find_children("*", "Label", true, false):
		var lab: Label = n as Label
		if lab != null and lab.visible and lab.text.find("/") >= 0:
			return lab
	return null


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok
