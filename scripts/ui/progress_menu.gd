extends CanvasLayer
## Post-run progress / collection menu. Primary between-run surface (cabin optional).
## Copy: postrun.* via PLAYER_COPY. No Nib dialogue tree. Mouse + keyboard.
## present() returns {action, biome_index} after dismiss — callers finalize BEFORE launching a run.

signal closed

const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const BIOME := preload("res://scripts/biome_cabinets.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const STAGGER_S := 0.07
const STEP_HOLD_S := 0.45
## FLAG: no Spin key for already-collected non-new state in detail strip.
const FLAG_MISSING_COLLECTED_COPY := "postrun.collection.item_collected (missing — blank state for collected non-new)"

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
var _new_ids: Array = []
var _kind: String = "win"
var _played_pool: String = "b1"
var _played_name: String = ""
var _rules: Dictionary = {}
var _state: Dictionary = {}
var _push_block: bool = false
var _tutorial: bool = false
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
func present(payload: Dictionary, ack_cb: Callable = Callable()) -> Dictionary:
	_build()
	_ack_cb = ack_cb
	_items_by_id = payload.get("items_by_id", {})
	_tex_by_item = payload.get("tex_by_item", {})
	_swiped = payload.get("swiped", {}).duplicate()
	_new_ids = payload.get("new_ids", []).duplicate()
	_kind = str(payload.get("kind", "win"))
	_played_pool = str(payload.get("played_pool", "b1"))
	_played_name = str(payload.get("played_name", ""))
	_rules = payload.get("rules", {})
	_state = payload.get("state", {})
	_push_block = bool(payload.get("push_block", false))
	_tutorial = bool(payload.get("tutorial", false)) or _kind == "tutorial"
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
	## Default keyboard focus on Skip Recap.
	_btn_skip.grab_focus()
	await _run_presentation(gen)
	if visible:
		await closed
	## Guarantee every presentation id is acked once on every exit path.
	_ack_all_new()
	return _result.duplicate()


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
	if _tutorial:
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


func _rebuild_overview() -> void:
	for c in _overview_box.get_children():
		c.queue_free()
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	var q: int = CAMPAIGN_SHELL.quota_of(_rules) if not _rules.is_empty() else 5
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
		else:
			## Locked: badge + requirement (quota is unlock threshold, distinct from roster total).
			var req := ""
			var bi := 0
			for i in biomes.size():
				if str((biomes[i] as Dictionary).get("id", "")) == pid:
					bi = i
					break
			var prev: Dictionary = biomes[bi - 1] if bi > 0 else {}
			var prev_name := str(prev.get("name", ""))
			if str(prev.get("id", "")) == "b1":
				req = PLAYER_COPY.text(
					"postrun.requirement.verdant",
					"Bring home 5 different item types from successful Verdant Hollow runs to open the way deeper. They don't all have to come home together."
				)
			elif prev_name != "":
				req = PLAYER_COPY.fill(
					"postrun.requirement.bring_home",
					{"required": str(q), "area": prev_name, "destination": name},
					"Bring home {required} different item types from {area} to unlock {destination}."
				)
			line.text = "%s — %s" % [
				name,
				PLAYER_COPY.text("postrun.collection.area_locked", "Locked"),
			]
			line.add_theme_color_override("font_color", Color("7a7060"))
			_overview_box.add_child(line)
			if req != "":
				var req_l := Label.new()
				req_l.text = req
				req_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				req_l.add_theme_font_size_override("font_size", 16)
				req_l.add_theme_color_override("font_color", Color("8a8070"))
				_overview_box.add_child(req_l)
			continue
		_overview_box.add_child(line)


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
	_reveal_all_new_in_view()


func _update_area_count_lab() -> void:
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	var name := _area_filter
	for raw in biomes:
		if str((raw as Dictionary).get("id", "")) == _area_filter:
			name = str((raw as Dictionary).get("name", _area_filter))
			break
	var count: int = _visible_collected_in_pool(_area_filter)
	var total: int = _pool_roster(_area_filter).size()
	_area_count_lab.text = PLAYER_COPY.fill(
		"postrun.collection.area_count",
		{"area": name, "count": str(count), "total": str(total)},
		"{area} collection: {count}/{total}"
	)


func _rebuild_grid() -> void:
	_kill_arrival_tweens()
	for c in _grid.get_children():
		c.queue_free()
	_cell_by_id.clear()
	_focus_cells.clear()
	_update_area_count_lab()
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


func _make_item_cell(id: String) -> Control:
	var card: Dictionary = _items_by_id.get(id, {})
	var collected: bool = bool(_swiped.get(id, false))
	var is_new: bool = _new_ids.has(id)
	var revealed: bool = (not is_new) or bool(_revealed_new.get(id, false)) or _phase == Phase.IDLE
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(360, 88)
	box.focus_mode = Control.FOCUS_ALL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("241e18") if collected and revealed else Color("161310")
	## Non-color states: New! / missing text + border weight/pattern (dashed via thicker border).
	if is_new and revealed:
		sb.border_color = Color("e8c36a")
		sb.set_border_width_all(3)
	elif not collected:
		sb.border_color = Color("4a4034")
		sb.set_border_width_all(2)
		sb.border_color = Color("4a4034")
	else:
		sb.border_color = Color("5a4e40")
		sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	box.add_theme_stylebox_override("panel", sb)
	var focus_sb := sb.duplicate()
	focus_sb.border_color = Color("f0e6d8")
	focus_sb.set_border_width_all(3)
	box.add_theme_stylebox_override("focus", focus_sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = _tex_by_item.get(id, null)
	if tex != null:
		icon.texture = tex
	else:
		icon.modulate = Color(0.35, 0.35, 0.35, 1)
	if not collected or (is_new and not revealed):
		icon.modulate = Color(0.55, 0.55, 0.55, 1)
	row.add_child(icon)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	var name_l := Label.new()
	name_l.text = str(card.get("name", id))
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.add_theme_color_override("font_color", Color("f0e6d8") if collected and revealed else Color("9a9080"))
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(name_l)
	var state_l := Label.new()
	if is_new and revealed:
		state_l.text = PLAYER_COPY.text("postrun.collection.item_new", "New!")
		state_l.add_theme_color_override("font_color", Color("e8c36a"))
	elif not collected:
		state_l.text = PLAYER_COPY.text("postrun.collection.item_missing", "Not yet collected")
		state_l.add_theme_color_override("font_color", Color("7a7060"))
	else:
		## Collected non-new: no Spin key — leave blank (FLAG_MISSING_COLLECTED_COPY).
		state_l.text = ""
	state_l.add_theme_font_size_override("font_size", 14)
	state_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(state_l)
	var inspect := func() -> void:
		var state_txt := state_l.text
		if state_txt == "" and collected:
			## FLAG: no postrun.collection.item_collected — show name only.
			_detail.text = name_l.text
			push_warning(FLAG_MISSING_COLLECTED_COPY)
		else:
			_detail.text = "%s — %s" % [name_l.text, state_txt]
	box.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			inspect.call()
			box.grab_focus()
		elif ev.is_action_pressed("ui_accept"):
			inspect.call()
			get_viewport().set_input_as_handled()
	)
	if is_new and not revealed and _phase != Phase.IDLE:
		box.modulate.a = 0.0
	return box


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
	## Manual tab/Next/area cancels auto timers; reveal news already on this view; do not free mid-tween.
	if _phase == Phase.IDLE:
		return
	_cancel_presentation()
	_reveal_all_new_in_view()


func _on_tab(tab: int) -> void:
	_conclude_auto_for_manual()
	_show_panel(tab)
	if tab == Tab.COLLECTION:
		_rebuild_grid()
		_reveal_all_new_in_view()
		if not _focus_cells.is_empty():
			(_focus_cells[0] as Control).grab_focus()
	elif tab == Tab.NEXT_TARGET:
		_rebuild_target()
		if _target_actions.get_child_count() > 0:
			var first = _target_actions.get_child(0)
			if first is Control and (first as Control).focus_mode != Control.FOCUS_NONE:
				(first as Control).grab_focus()


func _reveal_all_new_in_view() -> void:
	for id in _new_ids:
		_revealed_new[str(id)] = true
		var cell: Control = _cell_by_id.get(str(id), null)
		if cell != null:
			cell.modulate.a = 1.0
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


func _land_new(id: String) -> void:
	var sid := str(id)
	_revealed_new[sid] = true
	var cell: Control = _cell_by_id.get(sid, null)
	if cell != null:
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(cell, "modulate:a", 1.0, 0.12)
		_active_tweens.append(tw)
	_ack_id(sid)
	_update_area_count_lab()
	_rebuild_overview()


func _on_skip() -> void:
	_cancel_presentation()
	## Fast-forward: reveal all news across pools, then pause on Next Goal.
	for id in _new_ids:
		_revealed_new[str(id)] = true
	_ack_all_new()
	_show_panel(Tab.NEXT_TARGET if not _next_goal().is_empty() else Tab.COLLECTION)
	_area_filter = _played_pool if _played_pool != "" else _area_filter
	_rebuild_area_tabs()
	_rebuild_target()
	_reveal_all_new_in_view()


func _on_next_step() -> void:
	## Manual Next concludes current auto step and advances; cancels later timers.
	var from_tab: int = _tab
	_cancel_presentation()
	_skip_pres = false
	if from_tab == Tab.OVERVIEW:
		_phase = Phase.AREA
		_show_panel(Tab.COLLECTION)
		_area_filter = _played_pool
		_rebuild_area_tabs()
		_btn_next.disabled = false
		_btn_skip.disabled = false
	elif from_tab == Tab.COLLECTION:
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
			_land_new(str(id))
			await _wait_pres(STAGGER_S, gen)
		await _wait_pres(STEP_HOLD_S * 0.4, gen)
	if _skip_pres or gen != _pres_gen:
		return
	## Ensure every new id was revealed+acked (including empty-news paths).
	_ack_all_new()
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
	_result = {"action": "cabin", "biome_index": 0}
	dismiss()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and not _btn_next.disabled:
		_on_next_step()
		get_viewport().set_input_as_handled()
