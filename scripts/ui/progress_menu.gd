extends CanvasLayer
## Post-run progress / collection menu. Primary between-run surface (cabin optional).
## Copy: postrun.* via PLAYER_COPY. No Nib dialogue tree. Mouse + keyboard.

signal cabin_wanted
signal start_run_wanted(biome_index: int)
signal closed

const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const BIOME := preload("res://scripts/biome_cabinets.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const STAGGER_S := 0.07
const STEP_HOLD_S := 0.55

enum Tab { OVERVIEW, COLLECTION, NEXT_TARGET }
enum Phase { INTRO, AREA, TARGET, IDLE }

var _root: Control
var _title: Label
var _summary: Label
var _tab_bar: HBoxContainer
var _tab_btns: Array = []
var _body: Control
var _overview_box: VBoxContainer
var _grid_scroll: ScrollContainer
var _grid: GridContainer
var _area_tabs: HBoxContainer
var _target_box: VBoxContainer
var _target_prompt: Label
var _target_progress: Label
var _target_req: Label
var _route_lab: Label
var _hand_note: Label
var _footer: HBoxContainer
var _btn_skip: Button
var _btn_next: Button
var _btn_cabin: Button
var _btn_new_run: Button
var _dest_row: HBoxContainer
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
var _focus_order: Array = []


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
	panel.offset_left = 48
	panel.offset_top = 28
	panel.offset_right = -48
	panel.offset_bottom = -28
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c1814")
	sb.border_color = Color("3a3228")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	_root.add_child(panel)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 12)
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
	_summary.custom_minimum_size = Vector2(0, 40)
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
	_body.custom_minimum_size = Vector2(0, 520)
	col.add_child(_body)

	_overview_box = VBoxContainer.new()
	_overview_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overview_box.add_theme_constant_override("separation", 8)
	_body.add_child(_overview_box)

	_area_tabs = HBoxContainer.new()
	_area_tabs.add_theme_constant_override("separation", 6)
	_area_tabs.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_area_tabs.offset_bottom = 40
	_body.add_child(_area_tabs)

	_grid_scroll = ScrollContainer.new()
	_grid_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grid_scroll.offset_top = 48
	_grid_scroll.offset_bottom = -8
	_body.add_child(_grid_scroll)
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	_grid_scroll.add_child(_grid)

	_target_box = VBoxContainer.new()
	_target_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_target_box.add_theme_constant_override("separation", 10)
	_body.add_child(_target_box)
	_target_prompt = _body_label(28)
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
	_dest_row = HBoxContainer.new()
	_dest_row.add_theme_constant_override("separation", 8)
	_dest_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer.add_child(_dest_row)
	_btn_cabin = _mk_btn("postrun.cabin", "Visit Cabin")
	_btn_cabin.pressed.connect(_on_cabin)
	_footer.add_child(_btn_cabin)
	_btn_new_run = _mk_btn("postrun.new_run", "New Run")
	_btn_new_run.pressed.connect(_on_new_run_default)
	_footer.add_child(_btn_new_run)

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


## Present return results. ack_cb(id) optional — called when a new item lands / on skip.
func present(payload: Dictionary, ack_cb: Callable = Callable()) -> void:
	_build()
	_ack_cb = ack_cb
	_items_by_id = payload.get("items_by_id", {})
	_tex_by_item = payload.get("tex_by_item", {})
	_swiped = payload.get("swiped", {})
	_new_ids = payload.get("new_ids", []).duplicate()
	_kind = str(payload.get("kind", "win"))
	_played_pool = str(payload.get("played_pool", "b1"))
	_played_name = str(payload.get("played_name", ""))
	_rules = payload.get("rules", {})
	_state = payload.get("state", {})
	_push_block = bool(payload.get("push_block", false))
	_tutorial = bool(payload.get("tutorial", false)) or _kind == "tutorial"
	_skip_pres = false
	_pres_gen += 1
	var gen: int = _pres_gen
	_apply_summary()
	_rebuild_overview()
	_rebuild_area_tabs()
	_rebuild_destinations()
	_rebuild_target()
	_show_panel(Tab.OVERVIEW)
	visible = true
	_btn_skip.disabled = false
	_btn_next.disabled = false
	_phase = Phase.INTRO
	await _run_presentation(gen)
	## Stay open until Visit Cabin / Start New Run (or explicit dismiss).
	## Skip Recap / Next only advance presentation — never auto-launch or close.
	if visible:
		await closed


func dismiss() -> void:
	_pres_gen += 1
	var was_open := visible
	visible = false
	if was_open:
		closed.emit()


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
		if str(card.get("pool", "")) != pool:
			continue
		## Gear-looking ids without usable ownership implication: still list for collection.
		out.append(str(id))
	out.sort()
	return out


func _collected_in_pool(pool: String) -> int:
	var n := 0
	for id in _pool_roster(pool):
		if bool(_swiped.get(id, false)):
			n += 1
	return n


func _rebuild_overview() -> void:
	for c in _overview_box.get_children():
		c.queue_free()
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules) if not _rules.is_empty() else BIOME.CASES
	for raw in biomes:
		var b: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else {}
		var pid := str(b.get("id", ""))
		if pid == "":
			continue
		var name := str(b.get("name", pid))
		var roster: Array = _pool_roster(pid)
		var count: int = _collected_in_pool(pid)
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
			line.text = "%s — %s" % [
				name,
				PLAYER_COPY.text("postrun.collection.area_locked", "Locked"),
			]
			line.add_theme_color_override("font_color", Color("7a7060"))
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
		var btn := Button.new()
		btn.text = str(b.get("name", pid))
		btn.toggle_mode = true
		btn.button_pressed = pid == _area_filter
		btn.pressed.connect(_on_area_tab.bind(pid))
		_area_tabs.add_child(btn)
	_rebuild_grid()


func _on_area_tab(pool: String) -> void:
	_area_filter = pool
	_rebuild_area_tabs()


func _rebuild_grid() -> void:
	for c in _grid.get_children():
		c.queue_free()
	_cell_by_id.clear()
	var roster: Array = _pool_roster(_area_filter)
	for id in roster:
		var cell := _make_item_cell(str(id))
		_grid.add_child(cell)
		_cell_by_id[str(id)] = cell


func _make_item_cell(id: String) -> Control:
	var card: Dictionary = _items_by_id.get(id, {})
	var collected: bool = bool(_swiped.get(id, false))
	var is_new: bool = _new_ids.has(id)
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(280, 96)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("241e18") if collected else Color("161310")
	sb.border_color = Color("e8c36a") if is_new else (Color("5a4e40") if collected else Color("2e2820"))
	sb.set_border_width_all(2 if is_new or not collected else 1)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	box.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex: Texture2D = _tex_by_item.get(id, null)
	if tex != null:
		icon.texture = tex
	else:
		## Missing art: empty box — never imply usable gear ownership.
		icon.modulate = Color(0.3, 0.3, 0.3, 1)
	if not collected:
		icon.modulate = Color(0.55, 0.55, 0.55, 1)
	row.add_child(icon)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_col)
	var name_l := Label.new()
	name_l.text = str(card.get("name", id))
	name_l.add_theme_font_size_override("font_size", 18)
	name_l.add_theme_color_override("font_color", Color("f0e6d8") if collected else Color("9a9080"))
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(name_l)
	var state_l := Label.new()
	if is_new:
		state_l.text = PLAYER_COPY.text("postrun.collection.item_new", "New!")
		state_l.add_theme_color_override("font_color", Color("e8c36a"))
	elif not collected:
		state_l.text = PLAYER_COPY.text("postrun.collection.item_missing", "Not yet collected")
		state_l.add_theme_color_override("font_color", Color("7a7060"))
	else:
		state_l.text = ""
	state_l.add_theme_font_size_override("font_size", 14)
	text_col.add_child(state_l)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_detail.text = "%s — %s" % [name_l.text, state_l.text if state_l.text != "" else ("collected" if collected else "")]
	)
	## New arrivals start hidden for stagger.
	if is_new and _phase != Phase.IDLE:
		box.modulate.a = 0.0
	return box


func _next_goal() -> Dictionary:
	## First locked biome by index, else empty.
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
		var area_name := str(prev.get("name", area_id))
		var count: int = CAMPAIGN_SHELL.cabinet_count(_state, area_id)
		return {
			"dest_id": str(dest.get("id", "")),
			"dest_name": str(dest.get("name", "")),
			"area_id": area_id,
			"area_name": area_name,
			"count": count,
			"required": q,
			"index": i,
		}
	return {}


func _rebuild_target() -> void:
	_target_prompt.text = ""
	_target_progress.text = ""
	_target_req.text = ""
	_route_lab.text = ""
	## Highest unlocked destination (index>0) may show requirement.met — never invent all-goals-complete.
	var unlocked_dest := _highest_unlocked_destination()
	if not unlocked_dest.is_empty() and not _push_block:
		_target_req.text = PLAYER_COPY.fill(
			"postrun.requirement.met",
			{"destination": str(unlocked_dest.get("name", ""))},
			"{destination} unlocked"
		)
	var goal: Dictionary = _next_goal()
	if not goal.is_empty():
		_target_prompt.text = PLAYER_COPY.fill(
			"postrun.next_target.prompt",
			{"destination": str(goal.get("dest_name", ""))},
			"Next goal: {destination}"
		)
		_target_progress.text = PLAYER_COPY.fill(
			"postrun.next_target.progress",
			{"count": str(goal.get("count", 0)), "required": str(goal.get("required", 5))},
			"Progress: {count}/{required} different item types"
		)
		var dest_name := str(goal.get("dest_name", ""))
		var area_name := str(goal.get("area_name", ""))
		## Generic bring_home only where the real rule is collection quota; Verdant uses dedicated string.
		var req_line := ""
		if str(goal.get("area_id", "")) == "b1":
			req_line = PLAYER_COPY.text(
				"postrun.requirement.verdant",
				"Bring home 5 different item types from successful Verdant Hollow runs to open the way deeper. They don't all have to come home together."
			)
		else:
			req_line = PLAYER_COPY.fill(
				"postrun.requirement.bring_home",
				{
					"required": str(goal.get("required", 5)),
					"area": area_name,
					"destination": dest_name,
				},
				"Bring home {required} different item types from {area} to unlock {destination}."
			)
		## Prefer active requirement over prior unlock banner when a next goal exists.
		_target_req.text = req_line
		## Route: destination not can_start as fresh — explain same-run path.
		## D2 reached same-run is NOT a fresh-start shortcut — route text only, never a continue button.
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
	## hand_note only when source starter_item_mix sums to 6 (verified [3,2,1]); omit/flag otherwise.
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
		## Mismatch vs Spin copy — omit rather than invent alternate wording.
		_hand_note.text = ""
		_hand_note.visible = false
		if not _rules.is_empty():
			push_warning("postrun.hand_note omitted: starter_item_mix does not sum to 6")


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


func _rebuild_destinations() -> void:
	for c in _dest_row.get_children():
		c.queue_free()
	if _rules.is_empty():
		return
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(_rules)
	var showed_req := false
	var showed_unlocked_note := false
	for i in biomes.size():
		if not CAMPAIGN_SHELL.can_start(_rules, _state, i):
			## Locked start: show shortcut requirement as label, not start button.
			## D2 same-run reach ≠ fresh-start — never emit a start button here.
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
					_dest_row.add_child(lab)
					showed_req = true
			continue
		var b: Dictionary = biomes[i]
		## Fresh shortcut (i>0 + can_start): announce new starting point once.
		if i > 0 and not showed_unlocked_note:
			var note := Label.new()
			note.add_theme_font_size_override("font_size", 14)
			note.add_theme_color_override("font_color", Color("e8c36a"))
			note.text = PLAYER_COPY.fill(
				"postrun.shortcut.unlocked",
				{"start_area": str(b.get("name", ""))},
				"New starting point: {start_area}"
			)
			_dest_row.add_child(note)
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
		btn.custom_minimum_size = Vector2(180, 40)
		var idx: int = i
		btn.pressed.connect(func() -> void:
			start_run_wanted.emit(idx)
			dismiss()
		)
		_dest_row.add_child(btn)


func _show_panel(tab: int) -> void:
	_tab = tab
	_overview_box.visible = tab == Tab.OVERVIEW
	_area_tabs.visible = tab == Tab.COLLECTION
	_grid_scroll.visible = tab == Tab.COLLECTION
	_target_box.visible = tab == Tab.NEXT_TARGET
	for i in _tab_btns.size():
		var b: Button = _tab_btns[i]
		b.disabled = false
		b.modulate = Color(1, 1, 1, 1) if i == tab else Color(0.75, 0.75, 0.75, 1)


func _on_tab(tab: int) -> void:
	_phase = Phase.IDLE
	_show_panel(tab)
	if tab == Tab.COLLECTION:
		_rebuild_grid()
		## Reveal any still-hidden new cells when browsing.
		for id in _new_ids:
			var cell: Control = _cell_by_id.get(str(id), null)
			if cell != null:
				cell.modulate.a = 1.0


func _ack_id(id: String) -> void:
	if _ack_cb.is_valid():
		_ack_cb.call(id)


func _ack_all_new() -> void:
	for id in _new_ids:
		_ack_id(str(id))


func _on_skip() -> void:
	_skip_pres = true
	_pres_gen += 1
	_ack_all_new()
	## Reveal cells.
	_phase = Phase.IDLE
	_show_panel(Tab.NEXT_TARGET if not _next_goal().is_empty() else Tab.OVERVIEW)
	if _tab == Tab.COLLECTION or true:
		_area_filter = _played_pool if _played_pool != "" else _area_filter
		_rebuild_area_tabs()
		for id in _new_ids:
			var cell: Control = _cell_by_id.get(str(id), null)
			if cell != null:
				cell.modulate.a = 1.0
	_btn_skip.disabled = true
	_btn_next.disabled = true


func _on_next_step() -> void:
	match _phase:
		Phase.INTRO:
			_phase = Phase.AREA
			_show_panel(Tab.COLLECTION)
			_area_filter = _played_pool
			_rebuild_area_tabs()
		Phase.AREA:
			_phase = Phase.TARGET
			_show_panel(Tab.NEXT_TARGET)
		_:
			_phase = Phase.IDLE
			_btn_next.disabled = true
			_btn_skip.disabled = true


func _run_presentation(gen: int) -> void:
	if _tutorial or _kind == "loss" or _new_ids.is_empty() or _push_block:
		## Brief truthful result — no arrival celebration.
		_phase = Phase.INTRO
		_show_panel(Tab.OVERVIEW)
		if not _skip_pres and gen == _pres_gen:
			await _wait_pres(STEP_HOLD_S, gen)
		if gen != _pres_gen:
			return
		_phase = Phase.TARGET
		_show_panel(Tab.NEXT_TARGET)
		_phase = Phase.IDLE
		_btn_next.disabled = true
		_btn_skip.disabled = true
		_ack_all_new()
		return
	## Overview
	_phase = Phase.INTRO
	_show_panel(Tab.OVERVIEW)
	if not _skip_pres and gen == _pres_gen:
		await _wait_pres(STEP_HOLD_S, gen)
	if _skip_pres or gen != _pres_gen:
		return
	## Area just played + stagger
	_phase = Phase.AREA
	_show_panel(Tab.COLLECTION)
	_area_filter = _played_pool
	_rebuild_area_tabs()
	for id in _new_ids:
		if _skip_pres or gen != _pres_gen:
			break
		var cell: Control = _cell_by_id.get(str(id), null)
		if cell != null:
			var tw := create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_property(cell, "modulate:a", 1.0, 0.12)
		_ack_id(str(id))
		await _wait_pres(STAGGER_S, gen)
	if _skip_pres or gen != _pres_gen:
		return
	await _wait_pres(STEP_HOLD_S * 0.6, gen)
	if _skip_pres or gen != _pres_gen:
		return
	## Next target — pause for selection
	_phase = Phase.TARGET
	_show_panel(Tab.NEXT_TARGET)
	_phase = Phase.IDLE
	_btn_next.disabled = true
	_btn_skip.disabled = true


func _wait_pres(sec: float, gen: int) -> void:
	if sec <= 0.0:
		return
	var left := sec
	while left > 0.0 and gen == _pres_gen and not _skip_pres:
		var step: float = minf(left, 0.05)
		await get_tree().create_timer(step, true, false, true).timeout
		left -= step


func _on_cabin() -> void:
	_ack_all_new()
	cabin_wanted.emit()
	dismiss()


func _on_new_run_default() -> void:
	## Prefer first can_start (always b1 when rules present).
	if _rules.is_empty():
		start_run_wanted.emit(0)
		dismiss()
		return
	for i in CAMPAIGN_SHELL.biomes_of(_rules).size():
		if CAMPAIGN_SHELL.can_start(_rules, _state, i):
			start_run_wanted.emit(i)
			dismiss()
			return
	start_run_wanted.emit(0)
	dismiss()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		## Escape: do not force cabin; leave menu open unless Skip already finished.
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and not _btn_next.disabled:
		_on_next_step()
		get_viewport().set_input_as_handled()
