extends CanvasLayer
## Post-run progress / collection menu. Primary between-run surface (cabin optional).
## Copy: postrun.* via PLAYER_COPY. No Nib dialogue tree. Mouse + keyboard.
## present() returns {action, biome_index} after dismiss — callers finalize BEFORE launching a run.

signal closed

const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const BIOME := preload("res://scripts/biome_cabinets.gd")
const JOURNEY := preload("res://scripts/collection_journey.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const STAGGER_S := 0.07
const STEP_HOLD_S := 0.45
enum Tab { OVERVIEW, COLLECTION, NEXT_TARGET }
enum Phase { INTRO, AREA, TARGET, IDLE }

var _root: Control
var _title: Label
var _summary: Label
var _tab_bar: HBoxContainer
var _tab_btns: Array = []
var _body: Control
var _overview_box: VBoxContainer
var _collection_box: VBoxContainer
var _area_count_lab: Label
var _area_req_lab: Label
var _grid_scroll: ScrollContainer
var _grid: GridContainer
var _area_tabs: HBoxContainer
var _target_box: VBoxContainer
var _target_prompt: Label
var _target_progress: Label
var _target_req: Label
var _route_lab: Label
var _hand_note: Label
var _target_actions: HBoxContainer
var _footer: HBoxContainer
var _btn_skip: Button
var _btn_next: Button
var _btn_cabin: Button
var _detail: Label
var _built: bool = false

var _items_by_id: Dictionary = {}
var _tex_by_item: Dictionary = {}
var _swiped: Dictionary = {}
## Permanent recognition (offer/reveal). Distinct from banked/swiped.
var _seen: Dictionary = {}
var _new_ids: Array = []
var _kind: String = "win"
var _played_pool: String = "b1"
var _played_name: String = ""
var _rules: Dictionary = {}
var _state: Dictionary = {}
var _push_block: bool = false
var _tutorial: bool = false
## Durable return milestones (gate / cabinet_full / collection_complete). Facts only.
var _milestones: Array = []
var _milestones_shown: bool = false
var _area_filter: String = ""
var _tab: int = Tab.OVERVIEW
var _phase: int = Phase.INTRO
var _pres_gen: int = 0
var _skip_pres: bool = false
var _ack_cb: Callable = Callable()
var _cell_by_id: Dictionary = {}
var _revealed_new: Dictionary = {}
var _acked: Dictionary = {}
var _result: Dictionary = {}
var _active_tweens: Array = []
var _focus_cells: Array = []
var _present_busy: bool = false
var _session_id: int = 0
var _cell_tweens: Dictionary = {} ## id -> Tween


func _ready() -> void:
	layer = 96
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "ProgressMenu"
	visible = false
	_build()


func is_open() -> bool:
	return visible and _built


func _build() -> void:
	if _built:
		return
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("12100e")
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(bg)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_top = 24
	panel.offset_right = -40
	panel.offset_bottom = -24
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c1814")
	sb.border_color = Color("3a3228")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	_root.add_child(panel)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	col.add_child(head)
	_title = Label.new()
	_title.text = PLAYER_COPY.text("postrun.title", "Run Results")
	_title.add_theme_font_size_override("font_size", 36)
	_title.add_theme_color_override("font_color", Color("f0e6d8"))
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title)
	_btn_skip = _mk_btn("postrun.skip", "Skip Recap")
	_btn_skip.pressed.connect(_on_skip)
	head.add_child(_btn_skip)

	_summary = Label.new()
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary.add_theme_font_size_override("font_size", 22)
	_summary.add_theme_color_override("font_color", Color("e8c36a"))
	_summary.custom_minimum_size = Vector2(0, 36)
	col.add_child(_summary)

	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 8)
	col.add_child(_tab_bar)
	for pair in [
		[Tab.OVERVIEW, "postrun.tab.overview", "Overview"],
		[Tab.COLLECTION, "postrun.tab.collection", "Collection"],
		[Tab.NEXT_TARGET, "postrun.tab.next_target", "Next Goal"],
	]:
		var b := _mk_btn(str(pair[1]), str(pair[2]))
		var ti: int = int(pair[0])
		b.pressed.connect(_on_tab.bind(ti))
		_tab_bar.add_child(b)
		_tab_btns.append(b)

	_body = Control.new()
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size = Vector2(0, 620)
	col.add_child(_body)

	_overview_box = VBoxContainer.new()
	_overview_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overview_box.add_theme_constant_override("separation", 8)
	_body.add_child(_overview_box)

	_collection_box = VBoxContainer.new()
	_collection_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_collection_box.add_theme_constant_override("separation", 8)
	_body.add_child(_collection_box)
	_area_tabs = HBoxContainer.new()
	_area_tabs.add_theme_constant_override("separation", 6)
	_collection_box.add_child(_area_tabs)
	_area_count_lab = Label.new()
	_area_count_lab.add_theme_font_size_override("font_size", 20)
	_area_count_lab.add_theme_color_override("font_color", Color("e8c36a"))
	_collection_box.add_child(_area_count_lab)
	_area_req_lab = Label.new()
	_area_req_lab.add_theme_font_size_override("font_size", 16)
	_area_req_lab.add_theme_color_override("font_color", Color("8a8070"))
	_area_req_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_area_req_lab.visible = false
	_collection_box.add_child(_area_req_lab)
	_grid_scroll = ScrollContainer.new()
	_grid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_grid_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_collection_box.add_child(_grid_scroll)
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_grid_scroll.add_child(_grid)

	_target_box = VBoxContainer.new()
	_target_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_target_box.add_theme_constant_override("separation", 12)
	_body.add_child(_target_box)
	_target_prompt = _body_label(30)
	_target_box.add_child(_target_prompt)
	_target_progress = _body_label(22)
	_target_box.add_child(_target_progress)
	_target_req = _body_label(20)
	_target_req.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target_box.add_child(_target_req)
	_route_lab = _body_label(18)
	_route_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_route_lab.add_theme_color_override("font_color", Color("a89f90"))
	_target_box.add_child(_route_lab)
	_hand_note = _body_label(16)
	_hand_note.add_theme_color_override("font_color", Color("8a8070"))
	_target_box.add_child(_hand_note)
	_target_actions = HBoxContainer.new()
	_target_actions.add_theme_constant_override("separation", 12)
	_target_box.add_child(_target_actions)

	_detail = _body_label(18)
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_theme_color_override("font_color", Color("c8b89a"))
	col.add_child(_detail)

	_footer = HBoxContainer.new()
	_footer.add_theme_constant_override("separation", 12)
	col.add_child(_footer)
	_btn_next = _mk_btn("postrun.next", "Next")
	_btn_next.pressed.connect(_on_next_step)
	_footer.add_child(_btn_next)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer.add_child(spacer)
	_btn_cabin = _mk_btn("postrun.cabin", "Visit Cabin")
	_btn_cabin.pressed.connect(_on_cabin)
	_footer.add_child(_btn_cabin)

	_built = true
	_show_panel(Tab.OVERVIEW)


func _mk_btn(key: String, fallback: String) -> Button:
	var b := Button.new()
	b.text = PLAYER_COPY.text(key, fallback)
	b.custom_minimum_size = Vector2(140, 40)
	b.focus_mode = Control.FOCUS_ALL
	return b


func _body_label(size: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("f0e6d8"))
	return l


## Authoritative biome pool for a catalog card (numeric pool / bucket → b1..b5).
func _card_biome_pool(card: Dictionary) -> String:
	if card.is_empty():
		return ""
	## Accept already-resolved biome ids used by synthetic fixtures.
	var raw_pool: Variant = card.get("pool", null)
	if typeof(raw_pool) == TYPE_STRING:
		var s := str(raw_pool)
		if s.begins_with("b"):
			return s
	if _rules.is_empty():
		## Fixture without rules: string "b1" or numeric 1→b1 fallback for tests only.
		if typeof(raw_pool) == TYPE_STRING and str(raw_pool).begins_with("b"):
			return str(raw_pool)
		var n: int = BucketRules.of_card(card)
		return ("b%d" % n) if n >= 1 else ""
	return CAMPAIGN_SHELL.pool_for_bucket(_rules, BucketRules.of_card(card))


## Present return results. Returns {action: "cabin"|"start"|"dismiss", biome_index: int}.
## Overlapping present() dismisses+awaits the prior session before initializing.
func present(payload: Dictionary, ack_cb: Callable = Callable()) -> Dictionary:
	_build()
	if _present_busy:
		dismiss()
		while _present_busy:
			await get_tree().process_frame
	_present_busy = true
	_session_id += 1
	var session: int = _session_id
	_ack_cb = ack_cb
	_items_by_id = payload.get("items_by_id", {})
	_tex_by_item = payload.get("tex_by_item", {})
	_swiped = payload.get("swiped", {}).duplicate()
	_seen = payload.get("seen", {}).duplicate()
	## Banked implies seen for catalogue — fill gaps without mutating cabin save.
	for sid in _swiped.keys():
		_seen[str(sid)] = true
	_new_ids = payload.get("new_ids", []).duplicate()
	_kind = str(payload.get("kind", "win"))
	_played_pool = str(payload.get("played_pool", "b1"))
	_played_name = str(payload.get("played_name", ""))
	_rules = payload.get("rules", {})
	_state = payload.get("state", {})
	_push_block = bool(payload.get("push_block", false))
	_tutorial = bool(payload.get("tutorial", false)) or _kind == "tutorial"
	_milestones = payload.get("milestones", []).duplicate()
	_milestones_shown = false
	_skip_pres = false
	_revealed_new.clear()
	_acked.clear()
	_result = {"action": "dismiss", "biome_index": 0}
	_kill_arrival_tweens()
	_pres_gen += 1
	var gen: int = _pres_gen
	_apply_summary()
	_rebuild_overview()
	_rebuild_area_tabs()
	_rebuild_target()
	_show_panel(Tab.OVERVIEW)
	visible = true
	_btn_skip.disabled = false
	_btn_next.disabled = false
	_phase = Phase.INTRO
	_btn_skip.grab_focus()
	await _run_presentation(gen)
	if visible and session == _session_id:
		await closed
	if session == _session_id:
		_ack_all_new()
	var out: Dictionary = _result.duplicate()
	## Finalize needs the run kind (win/loss/tutorial) — cabin haul credit keys off it.
	out["kind"] = _kind
	if session == _session_id:
		_present_busy = false
	return out


func dismiss() -> void:
	_cancel_presentation()
	_ack_all_new()
	var was_open := visible
	visible = false
	if was_open:
		closed.emit()


func _cancel_presentation() -> void:
	_skip_pres = true
	_pres_gen += 1
	_kill_arrival_tweens()
	_phase = Phase.IDLE
	_btn_next.disabled = true
	_btn_skip.disabled = true


func _kill_arrival_tweens() -> void:
	for tw in _active_tweens:
		if tw != null and is_instance_valid(tw):
			tw.kill()
	_active_tweens.clear()


func _apply_summary() -> void:
	if _kind == "tutorial_skipped":
		_summary.text = PLAYER_COPY.text("postrun.summary.tutorial_skipped", "Tutorial skipped.")
		return
	if _tutorial or _kind == "tutorial":
		_summary.text = PLAYER_COPY.text(
			"postrun.summary.tutorial",
			"Tutorial complete. Tutorial items don't count toward collection progress."
		)
		return
	if _kind == "loss":
		var area := _played_name if _played_name != "" else _played_pool
		_summary.text = PLAYER_COPY.fill(
			"postrun.summary.death",
			{"area": area},
			"Run ended in {area}. No collection progress from this return."
		)
		return
	var n: int = _new_ids.size()
	if n > 0:
		_summary.text = PLAYER_COPY.fill(
			"postrun.summary.success_new",
			{"count": str(n)},
			"New item types added: {count}."
		)
	else:
		_summary.text = PLAYER_COPY.text(
			"postrun.summary.success_none",
			"Made it home. No new item types added."
		)


func _pool_roster(pool: String) -> Array:
	var out: Array = []
	for id in _items_by_id.keys():
		var card: Dictionary = _items_by_id[id]
		if typeof(card) != TYPE_DICTIONARY:
			continue
		## Tokens / aside never enter collection cabinets.
		if BucketRules.is_token(card):
			continue
		## Match production banking roster (main milestones_from_bank) — hold/retired
		## must not inflate totals or allow Full collection while live cabinets are short.
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if _card_biome_pool(card) != pool:
			continue
		out.append(str(id))
	out.sort()
	return out


func _visible_collected_in_pool(pool: String) -> int:
	## Stagger-aware: new ids count only after revealed this presentation.
	var n := 0
	for id in _pool_roster(pool):
		var sid := str(id)
		if not bool(_swiped.get(sid, false)):
			continue
		if _new_ids.has(sid) and not bool(_revealed_new.get(sid, false)):
			continue
		n += 1
	return n


func _requirement_text_for_pool(pid: String) -> String:
	## Locked destination requirement using existing Spin bring_home / verdant keys only.
	if _rules.is_empty() or pid == "":
		return ""
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules)
	var q: int = CAMPAIGN_SHELL.quota_of(_rules)
	var bi := -1
	for i in biomes.size():
		if str((biomes[i] as Dictionary).get("id", "")) == pid:
			bi = i
			break
	if bi <= 0:
		return ""
	var dest: Dictionary = biomes[bi]
	var prev: Dictionary = biomes[bi - 1]
	var prev_id := str(prev.get("id", ""))
	var dest_name := str(dest.get("name", pid))
	var prev_name := str(prev.get("name", prev_id))
	if prev_id == "b1":
		return PLAYER_COPY.text(
			"postrun.requirement.verdant",
			"Bring home 5 different item types from successful Verdant Hollow runs to open the way deeper. They don't all have to come home together."
		)
	return PLAYER_COPY.fill(
		"postrun.requirement.bring_home",
		{"required": str(q), "area": prev_name, "destination": dest_name},
		"Bring home {required} different item types from {area} to unlock {destination}."
	)


func _overall_unique_counts() -> Vector2i:
	## Distinct item types across authoritative biome pools (roster uniques), not unlock quota.
	var seen_collected: Dictionary = {}
	var seen_total: Dictionary = {}
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	for raw0 in biomes:
		var pid0 := str((raw0 as Dictionary).get("id", ""))
		if pid0 == "":
			continue
		for id in _pool_roster(pid0):
			var sid := str(id)
			seen_total[sid] = true
			if bool(_swiped.get(sid, false)):
				if _new_ids.has(sid) and not bool(_revealed_new.get(sid, false)):
					continue
				seen_collected[sid] = true
	return Vector2i(seen_collected.size(), seen_total.size())


func _milestone_line_text(m: Dictionary) -> String:
	var kind := str(m.get("kind", ""))
	if kind == "gate":
		## COPY GAP — Spin: postrun.milestone.gate
		return PLAYER_COPY.fill(
			"postrun.milestone.gate",
			{
				"from": str(m.get("from", 0)),
				"to": str(m.get("to", 0)),
				"quota": str(m.get("quota", 5)),
				"next": str(m.get("next_name", m.get("next_id", ""))),
			},
			"[Spin copy: Route open — {from}→{to}/{quota} banked. Next: {next}]"
		)
	if kind == "cabinet_full":
		## COPY GAP — Spin: postrun.milestone.cabinet_full (display/recognition only)
		return PLAYER_COPY.fill(
			"postrun.milestone.cabinet_full",
			{
				"pool": str(m.get("pool", "")),
				"count": str(m.get("count", 0)),
				"total": str(m.get("total", 0)),
			},
			"[Spin copy: Cabinet complete {count}/{total} — display only]"
		)
	if kind == "final_clear":
		## COPY GAP — Spin: postrun.milestone.final_clear (distinct from inheritance)
		## Reuses approved summary "Made it home…" for the header; this line is the
		## durable final-dungeon recognition fact only — no invented story copy.
		return PLAYER_COPY.fill(
			"postrun.milestone.final_clear",
			{
				"area": str(m.get("name", m.get("pool", ""))),
			},
			"[Spin copy: Final dungeon cleared — {area}]"
		)
	if kind == "collection_complete":
		## COPY GAP — Spin: postrun.milestone.collection_complete (neutral handoff)
		return PLAYER_COPY.text(
			"postrun.milestone.collection_complete",
			"[Spin copy: Full collection — reserved inheritance entry]"
		)
	return ""


func _rebuild_overview() -> void:
	for c in _overview_box.get_children():
		c.queue_free()
	## Milestone queue (A17) — durable facts; skip reveals all at once.
	## Never paint collection_complete while overview totals are still short
	## (guards bad fixtures / unrevealed new_ids undercount).
	var overview_totals: Vector2i = _overall_unique_counts()
	var roster_full_now: bool = overview_totals.y > 0 and overview_totals.x >= overview_totals.y
	if not _milestones.is_empty():
		var head := Label.new()
		head.name = "MilestoneHead"
		head.add_theme_font_size_override("font_size", 18)
		head.add_theme_color_override("font_color", Color("e8c36a"))
		## COPY GAP — Spin: postrun.milestone.heading
		head.text = PLAYER_COPY.text(
			"postrun.milestone.heading",
			"[Spin copy: This return]"
		)
		_overview_box.add_child(head)
		for raw_m in _milestones:
			if typeof(raw_m) != TYPE_DICTIONARY:
				continue
			var mk := str((raw_m as Dictionary).get("kind", ""))
			if mk == "collection_complete" and not roster_full_now:
				continue
			var ml := Label.new()
			ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ml.add_theme_font_size_override("font_size", 18)
			ml.add_theme_color_override("font_color", Color("f0e6d8"))
			ml.text = _milestone_line_text(raw_m as Dictionary)
			if ml.text != "":
				_overview_box.add_child(ml)
		_milestones_shown = true
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	## Spin postrun.collection.total — overall unique item-type aggregate.
	if PLAYER_COPY.has_key("postrun.collection.total"):
		var totals: Vector2i = _overall_unique_counts()
		var oline := Label.new()
		oline.name = "OverallTotal"
		oline.add_theme_font_size_override("font_size", 22)
		oline.add_theme_color_override("font_color", Color("e8c36a"))
		oline.text = PLAYER_COPY.fill(
			"postrun.collection.total",
			{"count": str(totals.x), "total": str(totals.y)},
			"Item types collected: {count}/{total}"
		)
		_overview_box.add_child(oline)
	for raw in biomes:
		var b: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else {}
		var pid := str(b.get("id", ""))
		if pid == "":
			continue
		var name := str(b.get("name", pid))
		var roster: Array = _pool_roster(pid)
		var count: int = _visible_collected_in_pool(pid)
		var total: int = roster.size()
		var unlocked: bool = true
		if not _rules.is_empty():
			unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, pid)
		var line := Label.new()
		line.add_theme_font_size_override("font_size", 20)
		if unlocked:
			line.text = PLAYER_COPY.fill(
				"postrun.collection.area_count",
				{"area": name, "count": str(count), "total": str(total)},
				"{area} collection: {count}/{total}"
			)
			line.add_theme_color_override("font_color", Color("f0e6d8"))
			_overview_box.add_child(line)
		else:
			line.text = "%s — %s" % [
				name,
				PLAYER_COPY.text("postrun.collection.area_locked", "Locked"),
			]
			line.add_theme_color_override("font_color", Color("7a7060"))
			_overview_box.add_child(line)
			var req := _requirement_text_for_pool(pid)
			if req != "":
				var req_l := Label.new()
				req_l.text = req
				req_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				req_l.add_theme_font_size_override("font_size", 16)
				req_l.add_theme_color_override("font_color", Color("8a8070"))
				_overview_box.add_child(req_l)


func _rebuild_area_tabs() -> void:
	for c in _area_tabs.get_children():
		c.queue_free()
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	if _area_filter == "" and biomes.size() > 0:
		_area_filter = _played_pool if _played_pool != "" else str(biomes[0].get("id", "b1"))
	for raw in biomes:
		var b: Dictionary = raw
		var pid := str(b.get("id", ""))
		var unlocked := true
		if not _rules.is_empty():
			unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, pid)
		var btn := Button.new()
		var label := str(b.get("name", pid))
		if not unlocked:
			label = "%s (%s)" % [
				label,
				PLAYER_COPY.text("postrun.collection.area_locked", "Locked"),
			]
		btn.text = label
		btn.toggle_mode = true
		btn.button_pressed = pid == _area_filter
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(_on_area_tab.bind(pid))
		_area_tabs.add_child(btn)
	_rebuild_grid()


func _on_area_tab(pool: String) -> void:
	_conclude_auto_for_manual()
	_area_filter = pool
	_rebuild_area_tabs()
	_land_all_news_in_filter(true)


func _update_area_count_lab() -> void:
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	var name := _area_filter
	var unlocked := true
	for raw in biomes:
		if str((raw as Dictionary).get("id", "")) == _area_filter:
			name = str((raw as Dictionary).get("name", _area_filter))
			break
	if not _rules.is_empty():
		unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, _area_filter)
	var count: int = _visible_collected_in_pool(_area_filter)
	var total: int = _pool_roster(_area_filter).size()
	_area_count_lab.text = PLAYER_COPY.fill(
		"postrun.collection.area_count",
		{"area": name, "count": str(count), "total": str(total)},
		"{area} collection: {count}/{total}"
	)
	## Locked area Collection page: show requirement near the grid (existing Spin keys).
	if _area_req_lab != null:
		if unlocked:
			_area_req_lab.visible = false
			_area_req_lab.text = ""
		else:
			var req := _requirement_text_for_pool(_area_filter)
			_area_req_lab.text = req
			_area_req_lab.visible = req != ""


func _rebuild_grid() -> void:
	_kill_arrival_tweens()
	for c in _grid.get_children():
		c.queue_free()
	_cell_by_id.clear()
	_focus_cells.clear()
	_update_area_count_lab()
	## Journey A: locked future cabinets reveal no item names/icons (no spoilers).
	var area_unlocked := true
	if not _rules.is_empty() and _area_filter != "":
		area_unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, _area_filter)
	if not area_unlocked:
		var locked_word := PLAYER_COPY.text("postrun.collection.area_locked", "Locked")
		var total: int = _pool_roster(_area_filter).size()
		var show_n: int = mini(total, maxi(1, _grid.columns * 2))
		for i in show_n:
			var cell := _make_locked_placeholder_cell(i, locked_word)
			_grid.add_child(cell)
			_focus_cells.append(cell)
		_wire_cell_focus_neighbors()
		return
	var roster: Array = _pool_roster(_area_filter)
	for id in roster:
		var cell := _make_item_cell(str(id))
		_grid.add_child(cell)
		_cell_by_id[str(id)] = cell
		_focus_cells.append(cell)
	_wire_cell_focus_neighbors()


func _wire_cell_focus_neighbors() -> void:
	var cols: int = maxi(1, _grid.columns)
	for i in _focus_cells.size():
		var cell: Control = _focus_cells[i]
		var left: Control = _focus_cells[i - 1] if i > 0 else null
		var right: Control = _focus_cells[i + 1] if i + 1 < _focus_cells.size() else null
		var up: Control = _focus_cells[i - cols] if i - cols >= 0 else null
		var down: Control = _focus_cells[i + cols] if i + cols < _focus_cells.size() else null
		cell.focus_neighbor_left = left.get_path() if left else NodePath()
		cell.focus_neighbor_right = right.get_path() if right else NodePath()
		cell.focus_neighbor_top = up.get_path() if up else NodePath()
		cell.focus_neighbor_bottom = down.get_path() if down else NodePath()


func _make_locked_placeholder_cell(index: int, locked_word: String) -> Control:
	## Anonymous locked slot — no catalog id, name, or art (Journey A spoiler ban).
	var box := PanelContainer.new()
	box.name = "Cell_locked_%s" % index
	box.custom_minimum_size = Vector2(360, 88)
	box.focus_mode = Control.FOCUS_ALL
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.bg_color = Color("161310")
	sb.border_color = Color("4a4034")
	sb.set_border_width_all(2)
	box.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.modulate = Color(0.35, 0.35, 0.35, 1)
	row.add_child(icon)
	var text_col := VBoxContainer.new()
	text_col.name = "Text"
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	var name_l := Label.new()
	name_l.name = "Name"
	name_l.text = "?"
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.add_theme_color_override("font_color", Color("9a9080"))
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(name_l)
	var state_l := Label.new()
	state_l.name = "State"
	state_l.text = locked_word
	state_l.add_theme_font_size_override("font_size", 14)
	state_l.add_theme_color_override("font_color", Color("7a7060"))
	state_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(state_l)
	return box


func _make_item_cell(id: String) -> Control:
	var card: Dictionary = _items_by_id.get(id, {})
	var box := PanelContainer.new()
	box.name = "Cell_%s" % id
	box.set_meta("item_id", id)
	box.custom_minimum_size = Vector2(360, 88)
	box.focus_mode = Control.FOCUS_ALL
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = _tex_by_item.get(id, null)
	if tex != null:
		icon.texture = tex
	row.add_child(icon)
	var text_col := VBoxContainer.new()
	text_col.name = "Text"
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	var name_l := Label.new()
	name_l.name = "Name"
	name_l.text = str(card.get("name", id))
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(name_l)
	var state_l := Label.new()
	state_l.name = "State"
	state_l.add_theme_font_size_override("font_size", 14)
	state_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(state_l)
	box.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_inspect_cell(id)
			box.grab_focus()
		elif ev.is_action_pressed("ui_accept"):
			_inspect_cell(id)
			get_viewport().set_input_as_handled()
	)
	_refresh_cell_visual(box, id, false)
	return box


func _inspect_cell(id: String) -> void:
	var cell: Control = _cell_by_id.get(id, null)
	if cell == null:
		return
	var name_l: Label = cell.find_child("Name", true, false) as Label
	var state_l: Label = cell.find_child("State", true, false) as Label
	var nm := name_l.text if name_l else id
	var st := state_l.text if state_l else ""
	_detail.text = "%s — %s" % [nm, st] if st != "" else nm


## Unified new/collected/seen/missing visual state. Call on build, land, skip, and manual reveal.
## "seen" = recognized (offer/reveal) but not banked — Journey A catalogue contract.
func _refresh_cell_visual(box: Control, id: String, animate_in: bool) -> void:
	if box == null or not is_instance_valid(box):
		return
	var kind: String = JOURNEY.catalogue_cell_kind(id, _seen, _swiped, _new_ids)
	var collected: bool = kind == "collected" or kind == "new"
	var is_new: bool = kind == "new"
	var is_seen_only: bool = kind == "seen"
	var revealed: bool = (not is_new) or bool(_revealed_new.get(id, false))
	var icon: TextureRect = box.find_child("Icon", true, false) as TextureRect
	var name_l: Label = box.find_child("Name", true, false) as Label
	var state_l: Label = box.find_child("State", true, false) as Label
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if is_new and revealed:
		sb.bg_color = Color("241e18")
		sb.border_color = Color("e8c36a")
		sb.set_border_width_all(3)
	elif collected and revealed:
		sb.bg_color = Color("241e18")
		sb.border_color = Color("5a4e40")
		sb.set_border_width_all(1)
	elif is_seen_only:
		## Known identity, not banked — hatch + text (not color alone).
		sb.bg_color = Color("1a1712")
		sb.border_color = Color("8a7a58")
		sb.set_border_width_all(2)
	elif not collected:
		sb.bg_color = Color("161310")
		sb.border_color = Color("4a4034")
		sb.set_border_width_all(2)
	else:
		## New but not yet revealed — build hidden; style as missing until land.
		sb.bg_color = Color("161310")
		sb.border_color = Color("4a4034")
		sb.set_border_width_all(2)
	box.add_theme_stylebox_override("panel", sb)
	var focus_sb := sb.duplicate()
	focus_sb.border_color = Color("f0e6d8")
	focus_sb.set_border_width_all(3)
	box.add_theme_stylebox_override("focus", focus_sb)
	## Kill any in-flight arrival tween for this cell so settle never inherits mid-fade dim.
	if _cell_tweens.has(id):
		var old_tw: Tween = _cell_tweens[id]
		if old_tw != null and is_instance_valid(old_tw):
			old_tw.kill()
		_cell_tweens.erase(id)
	## Unseen (missing) cells stay anonymous — no catalog name/art until offer/reveal marks seen.
	var is_unseen_missing: bool = kind == "missing"
	if icon != null:
		if is_unseen_missing:
			icon.texture = null
			icon.modulate = Color(0.35, 0.35, 0.35, 1)
		else:
			var tex: Texture2D = _tex_by_item.get(id, null)
			icon.texture = tex
			if is_new and revealed:
				icon.modulate = Color(1, 1, 1, 1)
			elif is_seen_only:
				## Readable icon + hatch via border; slightly dim, not missing-gray.
				icon.modulate = Color(0.78, 0.74, 0.62, 1)
			elif not collected or (is_new and not revealed):
				icon.modulate = Color(0.55, 0.55, 0.55, 1)
			elif tex == null:
				icon.modulate = Color(0.35, 0.35, 0.35, 1)
			else:
				icon.modulate = Color(1, 1, 1, 1)
	if name_l != null:
		if is_unseen_missing:
			name_l.text = "?"
			name_l.add_theme_color_override("font_color", Color("9a9080"))
		else:
			## Restore authored name when seen/banked (cell may have been "?" earlier).
			var card: Dictionary = _items_by_id.get(id, {})
			name_l.text = str(card.get("name", id))
			var bright := (collected and revealed) or (is_new and revealed) or is_seen_only
			name_l.add_theme_color_override(
				"font_color",
				Color("f0e6d8") if bright else Color("9a9080")
			)
	if state_l != null:
		if is_new and revealed:
			state_l.text = PLAYER_COPY.text("postrun.collection.item_new", "New!")
			state_l.add_theme_color_override("font_color", Color("e8c36a"))
		elif is_seen_only:
			## COPY GAP — Spin: approved key postrun.collection.item_seen not yet authored.
			state_l.text = PLAYER_COPY.text(
				"postrun.collection.item_seen",
				"[Spin copy: Recognized — not banked yet]"
			)
			state_l.add_theme_color_override("font_color", Color("c4b48a"))
		elif not collected:
			state_l.text = PLAYER_COPY.text("postrun.collection.item_missing", "Not yet collected")
			state_l.add_theme_color_override("font_color", Color("7a7060"))
		elif collected and revealed:
			state_l.text = PLAYER_COPY.text("postrun.collection.item_collected", "Collected")
			state_l.add_theme_color_override("font_color", Color("a89f90"))
		else:
			state_l.text = ""
	if is_new and not revealed:
		## Hidden until land — full white RGB, alpha 0 (not gray RGB that sticks after fade).
		box.modulate = Color(1, 1, 1, 0)
	elif animate_in:
		box.modulate = Color(1, 1, 1, 0)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(box, "modulate:a", 1.0, 0.12)
		tw.finished.connect(func() -> void:
			if is_instance_valid(box):
				box.modulate = Color(1, 1, 1, 1)
			_cell_tweens.erase(id)
		)
		_cell_tweens[id] = tw
		_active_tweens.append(tw)
	else:
		## Settled end-state: never leave partial alpha / gray row modulate.
		box.modulate = Color(1, 1, 1, 1)


func _next_goal() -> Dictionary:
	if _rules.is_empty():
		return {}
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules)
	var q: int = CAMPAIGN_SHELL.quota_of(_rules)
	for i in biomes.size():
		if CAMPAIGN_SHELL.biome_unlocked(_rules, _state, i):
			continue
		var dest: Dictionary = biomes[i]
		var prev: Dictionary = biomes[i - 1] if i > 0 else {}
		var area_id := str(prev.get("id", "b1"))
		return {
			"dest_id": str(dest.get("id", "")),
			"dest_name": str(dest.get("name", "")),
			"area_id": area_id,
			"area_name": str(prev.get("name", area_id)),
			"count": CAMPAIGN_SHELL.cabinet_count(_state, area_id),
			"required": q,
			"index": i,
		}
	return {}


func _rebuild_target() -> void:
	_target_prompt.text = ""
	_target_progress.text = ""
	_target_req.text = ""
	_route_lab.text = ""
	for c in _target_actions.get_children():
		c.queue_free()
	var goal: Dictionary = _next_goal()
	if not goal.is_empty():
		_target_prompt.text = PLAYER_COPY.fill(
			"postrun.next_target.prompt",
			{"destination": str(goal.get("dest_name", ""))},
			"Next goal: {destination}"
		)
		## Quota progress (unlock threshold) — distinct from roster {count}/{total}.
		_target_progress.text = PLAYER_COPY.fill(
			"postrun.next_target.progress",
			{"count": str(goal.get("count", 0)), "required": str(goal.get("required", 5))},
			"Progress: {count}/{required} different item types"
		)
		var dest_name := str(goal.get("dest_name", ""))
		var area_name := str(goal.get("area_name", ""))
		if str(goal.get("area_id", "")) == "b1":
			_target_req.text = PLAYER_COPY.text(
				"postrun.requirement.verdant",
				"Bring home 5 different item types from successful Verdant Hollow runs to open the way deeper. They don't all have to come home together."
			)
		else:
			_target_req.text = PLAYER_COPY.fill(
				"postrun.requirement.bring_home",
				{
					"required": str(goal.get("required", 5)),
					"area": area_name,
					"destination": dest_name,
				},
				"Bring home {required} different item types from {area} to unlock {destination}."
			)
		var dest_i: int = int(goal.get("index", 1))
		if not CAMPAIGN_SHELL.can_start(_rules, _state, dest_i):
			var start_i: int = 0
			for si in range(dest_i - 1, -1, -1):
				if CAMPAIGN_SHELL.can_start(_rules, _state, si):
					start_i = si
					break
			var start_b: Dictionary = CAMPAIGN_SHELL.biomes_of(_rules)[start_i]
			_route_lab.text = PLAYER_COPY.fill(
				"postrun.destination.route",
				{
					"destination": dest_name,
					"start_area": str(start_b.get("name", "")),
				},
				"Reach {destination} by starting in {start_area} and continuing during the same run."
			)
	elif not _push_block:
		var unlocked_dest := _highest_unlocked_destination()
		if not unlocked_dest.is_empty():
			_target_req.text = PLAYER_COPY.fill(
				"postrun.requirement.met",
				{"destination": str(unlocked_dest.get("name", ""))},
				"{destination} unlocked"
			)
	var hand_ok := false
	if not _rules.is_empty():
		var mix: Variant = _rules.get("starter_item_mix", [3, 2, 1])
		var counts: Array = mix if typeof(mix) == TYPE_ARRAY else []
		var sum := 0
		for raw in counts:
			sum += int(raw)
		hand_ok = sum == 6 and CAMPAIGN_SHELL.starter_hook_count(_rules) == 6
	if hand_ok:
		_hand_note.text = PLAYER_COPY.text(
			"postrun.hand_note",
			"Each new run starts with 6 random items from unlocked pools."
		)
		_hand_note.visible = true
	else:
		_hand_note.text = ""
		_hand_note.visible = false
		if not _rules.is_empty():
			push_warning("postrun.hand_note omitted: starter_item_mix does not sum to 6")
	## One clear primary start action group (no redundant footer New Run).
	_fill_start_actions(_target_actions)


func _highest_unlocked_destination() -> Dictionary:
	if _rules.is_empty():
		return {}
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules)
	var last: Dictionary = {}
	for i in range(1, biomes.size()):
		if CAMPAIGN_SHELL.biome_unlocked(_rules, _state, i):
			last = biomes[i]
		else:
			break
	return last


func _fill_start_actions(row: HBoxContainer) -> void:
	for c in row.get_children():
		c.queue_free()
	if _rules.is_empty():
		var btn0 := Button.new()
		btn0.text = PLAYER_COPY.text("postrun.button.start_default", "Start New Run")
		btn0.custom_minimum_size = Vector2(220, 44)
		btn0.focus_mode = Control.FOCUS_ALL
		btn0.pressed.connect(func() -> void: _choose_start(0))
		row.add_child(btn0)
		return
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules)
	var showed_req := false
	var showed_unlocked_note := false
	var any_start := false
	for i in biomes.size():
		if not CAMPAIGN_SHELL.can_start(_rules, _state, i):
			if (not showed_req) and i > 0 and not CAMPAIGN_SHELL.shortcut_open(_rules, _state, i):
				var need_i: int = i + 1
				if need_i < biomes.size():
					var lab := Label.new()
					lab.add_theme_font_size_override("font_size", 14)
					lab.add_theme_color_override("font_color", Color("7a7060"))
					lab.text = PLAYER_COPY.fill(
						"postrun.shortcut.requirement",
						{
							"required_area": str(biomes[need_i].get("name", "")),
							"start_area": str(biomes[i].get("name", "")),
						},
						"Unlock {required_area} to start new runs in {start_area}."
					)
					row.add_child(lab)
					showed_req = true
			continue
		var b: Dictionary = biomes[i]
		if i > 0 and not showed_unlocked_note:
			var note := Label.new()
			note.add_theme_font_size_override("font_size", 14)
			note.add_theme_color_override("font_color", Color("e8c36a"))
			note.text = PLAYER_COPY.fill(
				"postrun.shortcut.unlocked",
				{"start_area": str(b.get("name", ""))},
				"New starting point: {start_area}"
			)
			row.add_child(note)
			showed_unlocked_note = true
		var btn := Button.new()
		if i == 0:
			btn.text = PLAYER_COPY.text("postrun.button.start_default", "Start New Run")
		else:
			btn.text = PLAYER_COPY.fill(
				"postrun.button.start_at",
				{"start_area": str(b.get("name", ""))},
				"Start New Run in {start_area}"
			)
		btn.custom_minimum_size = Vector2(220, 44)
		btn.focus_mode = Control.FOCUS_ALL
		var idx: int = i
		btn.pressed.connect(func() -> void: _choose_start(idx))
		row.add_child(btn)
		any_start = true
	if not any_start:
		var fallback := Button.new()
		fallback.text = PLAYER_COPY.text("postrun.button.start_default", "Start New Run")
		fallback.custom_minimum_size = Vector2(220, 44)
		fallback.focus_mode = Control.FOCUS_ALL
		fallback.pressed.connect(func() -> void: _choose_start(0))
		row.add_child(fallback)


func _show_panel(tab: int) -> void:
	_tab = tab
	_overview_box.visible = tab == Tab.OVERVIEW
	_collection_box.visible = tab == Tab.COLLECTION
	_target_box.visible = tab == Tab.NEXT_TARGET
	for i in _tab_btns.size():
		var b: Button = _tab_btns[i]
		b.disabled = false
		b.modulate = Color(1, 1, 1, 1) if i == tab else Color(0.75, 0.75, 0.75, 1)


func _conclude_auto_for_manual() -> void:
	## Manual tab/Next/area cancels auto timers without freeing mid-tween late overrides.
	if _phase == Phase.IDLE:
		return
	_cancel_presentation()


func _on_tab(tab: int) -> void:
	_conclude_auto_for_manual()
	_show_panel(tab)
	if tab == Tab.COLLECTION:
		_area_filter = _area_filter if _area_filter != "" else _played_pool
		_rebuild_area_tabs()
		_land_all_news_in_filter(true)
		if not _focus_cells.is_empty():
			(_focus_cells[0] as Control).grab_focus()
	elif tab == Tab.NEXT_TARGET:
		_land_all_remaining_news(false)
		_rebuild_target()
		if _target_actions.get_child_count() > 0:
			var first = _target_actions.get_child(0)
			if first is Control and (first as Control).focus_mode != Control.FOCUS_NONE:
				(first as Control).grab_focus()


func _land_all_news_in_filter(animate: bool) -> void:
	for id in _new_ids_for_pool(_area_filter):
		_land_new(str(id), animate)
	_update_area_count_lab()
	_rebuild_overview()


func _land_all_remaining_news(animate: bool) -> void:
	for id in _new_ids:
		_land_new(str(id), animate)
	_update_area_count_lab()
	_rebuild_overview()


func _ack_id(id: String) -> void:
	var sid := str(id)
	if bool(_acked.get(sid, false)):
		return
	_acked[sid] = true
	if _ack_cb.is_valid():
		_ack_cb.call(sid)


func _ack_all_new() -> void:
	for id in _new_ids:
		_ack_id(str(id))


func _land_new(id: String, animate: bool = true) -> void:
	## Full visual state before ack — New! border/text/icon, not alpha-only fade.
	var sid := str(id)
	_revealed_new[sid] = true
	var cell: Control = _cell_by_id.get(sid, null)
	if cell != null:
		_refresh_cell_visual(cell, sid, animate)
	_ack_id(sid)
	_update_area_count_lab()
	_rebuild_overview()


## Snap every revealed new cell to full bright settle (for shots / skip / manual conclude).
func settle_landed_visuals() -> void:
	for id in _new_ids:
		var sid := str(id)
		if not bool(_revealed_new.get(sid, false)):
			continue
		var cell: Control = _cell_by_id.get(sid, null)
		if cell != null:
			_refresh_cell_visual(cell, sid, false)


func _on_skip() -> void:
	_cancel_presentation()
	_show_panel(Tab.NEXT_TARGET if not _next_goal().is_empty() else Tab.COLLECTION)
	_area_filter = _played_pool if _played_pool != "" else _area_filter
	_rebuild_area_tabs()
	_land_all_remaining_news(false)
	settle_landed_visuals()
	_rebuild_target()
	_ack_all_new()


func _on_next_step() -> void:
	## Manual Next cancels auto, then actually presents/lands news for the visited step.
	var from_tab: int = _tab
	_cancel_presentation()
	_skip_pres = false
	if from_tab == Tab.OVERVIEW:
		_phase = Phase.AREA
		_show_panel(Tab.COLLECTION)
		_area_filter = _played_pool if _played_pool != "" else _area_filter
		_rebuild_area_tabs()
		_land_all_news_in_filter(true)
		_btn_next.disabled = false
		_btn_skip.disabled = false
	elif from_tab == Tab.COLLECTION:
		## Mid-stagger Next: finish remaining news for current+other pools before Target.
		_land_all_remaining_news(false)
		_phase = Phase.IDLE
		_show_panel(Tab.NEXT_TARGET)
		_rebuild_target()
		_btn_next.disabled = true
		_btn_skip.disabled = true
	else:
		_phase = Phase.IDLE
		_btn_next.disabled = true
		_btn_skip.disabled = true


func _new_ids_for_pool(pool: String) -> Array:
	var out: Array = []
	for id in _new_ids:
		var card: Dictionary = _items_by_id.get(str(id), {})
		if _card_biome_pool(card) == pool:
			out.append(str(id))
	return out


func _pools_with_new() -> Array:
	var seen: Dictionary = {}
	var out: Array = []
	## Played area first.
	if _played_pool != "":
		seen[_played_pool] = true
		out.append(_played_pool)
	for id in _new_ids:
		var p := _card_biome_pool(_items_by_id.get(str(id), {}))
		if p == "" or seen.has(p):
			continue
		seen[p] = true
		out.append(p)
	return out


func _run_presentation(gen: int) -> void:
	## Every return: Overview → played/collection → Next Goal. Brief holds; stagger only real news.
	_phase = Phase.INTRO
	_show_panel(Tab.OVERVIEW)
	if not _skip_pres and gen == _pres_gen:
		await _wait_pres(STEP_HOLD_S, gen)
	if _skip_pres or gen != _pres_gen:
		return
	_phase = Phase.AREA
	_show_panel(Tab.COLLECTION)
	_area_filter = _played_pool if _played_pool != "" else _area_filter
	_rebuild_area_tabs()
	## Land news pool-by-pool so multi-pool arrivals are visible before ack.
	for pool in _pools_with_new():
		if _skip_pres or gen != _pres_gen:
			return
		if str(pool) != _area_filter:
			_area_filter = str(pool)
			_rebuild_area_tabs()
		var news: Array = _new_ids_for_pool(str(pool))
		if news.is_empty():
			## Still show played area briefly even with zero news.
			if str(pool) == _played_pool:
				await _wait_pres(STEP_HOLD_S * 0.5, gen)
			continue
		for id in news:
			if _skip_pres or gen != _pres_gen:
				return
			_land_new(str(id), true)
			await _wait_pres(STAGGER_S, gen)
		await _wait_pres(STEP_HOLD_S * 0.4, gen)
	if _skip_pres or gen != _pres_gen:
		return
	## Ensure every new id was revealed+acked (including empty-news paths).
	_ack_all_new()
	## A17: ordered milestone recap after banked news; one skip already showed everything.
	if not _milestones.is_empty() and not _skip_pres and gen == _pres_gen:
		_show_panel(Tab.OVERVIEW)
		_rebuild_overview()
		await _wait_pres(STEP_HOLD_S, gen)
		if _skip_pres or gen != _pres_gen:
			return
	_phase = Phase.TARGET
	_show_panel(Tab.NEXT_TARGET)
	_rebuild_target()
	_phase = Phase.IDLE
	_btn_next.disabled = true
	_btn_skip.disabled = true
	if _target_actions.get_child_count() > 0:
		var first = _target_actions.get_child(0)
		if first is Button:
			(first as Button).grab_focus()


func _wait_pres(sec: float, gen: int) -> void:
	if sec <= 0.0:
		return
	var left := sec
	while left > 0.0 and gen == _pres_gen and not _skip_pres:
		var step: float = minf(left, 0.05)
		await get_tree().create_timer(step, true, false, true).timeout
		left -= step


func _choose_start(biome_index: int) -> void:
	_result = {"action": "start", "biome_index": biome_index}
	dismiss()


func _on_cabin() -> void:
	## Optional cabin — pass played pool so hall can focus that cabinet (A11).
	_result = {
		"action": "cabin",
		"biome_index": 0,
		"focus_pool": _played_pool,
		"kind": _kind,
	}
	dismiss()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		## Journey A: Esc/Back restores the caller (dismiss without choosing Start/Cabin).
		_result = {"action": "dismiss", "biome_index": 0, "kind": _kind}
		dismiss()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and not _btn_next.disabled:
		_on_next_step()
		get_viewport().set_input_as_handled()
