extends "res://scripts/core/tutorial_flow.gd"
## UI lane. Screens, HUD, inspect paint, cues, hand cards, feel.
## Do not rewrite locked player-copy strings; look them up.

const FILL_YELLOW := Color("4a3d14")
const LOG_KIND := {
	"on_click": {"hex": "#E8C36A", "tag": "On Click"},
	"on_spin": {"hex": "#6EC8E8", "tag": "On Spin"},
	"on_item_use": {"hex": "#E07A3D", "tag": "On Item Use"},
	"on_resolve": {"hex": "#F0E6D8", "tag": "On Resolve"},
	"on_remove_slice": {"hex": "#D19A66", "tag": "On Remove Slice"},
	"on_draft": {"hex": "#8DCB8D", "tag": "On Draft"},
	"on_place": {"hex": "#A3BE8C", "tag": "On Place"},
	"on_bribe": {"hex": "#D19A66", "tag": "On Bribe"},
	"var": {"hex": "#C9A0FF", "tag": "Var"},
	"atk": {"hex": "#E06C75", "tag": "ATK"},
	"blk": {"hex": "#6BB3D9", "tag": "BLK"},
	"hp": {"hex": "#E06C75", "tag": "HP"},
	"discard": {"hex": "#8A8178", "tag": "Discard"},
	"keep": {"hex": "#A3BE8C", "tag": "Keep"},
	"end": {"hex": "#BF616A", "tag": "End"},
}


func _prefer_pixel_art() -> void:
	if art == null:
		return
	for id in tex_by_item.keys():
		var pix: Texture2D = art.item_tex(str(id))
		if pix != null:
			tex_by_item[id] = pix
	for id2 in tex_by_monster.keys():
		var port: Texture2D = art.monster_still(str(id2))
		if port != null:
			tex_by_monster[id2] = port


func _load_textures() -> void:
	tex_heart = _tex("res://assets/icons/heart.svg")
	tex_sword = _tex("res://assets/icons/sword.svg")
	tex_shield = _tex("res://assets/icons/shield.svg")
	tex_rotate = _tex("res://assets/icons/rotate.svg")
	tex_plus = _tex("res://assets/icons/plus.svg")
	tex_by_monster = {
		"wizard": _tex("res://assets/icons/wand.svg"),
		"golem": _tex("res://assets/icons/mountain.svg"),
		"goblin": _tex("res://assets/icons/users.svg"),
		"skeleton": _tex("res://assets/icons/skull.svg"),
		"hornet_swarm": _tex("res://assets/icons/sparkles.svg"),
		"lich": _tex("res://assets/icons/droplet.svg"),
		"ogre": _tex("res://assets/icons/hammer.svg"),
		"berserker": _tex("res://assets/icons/swords.svg"),
		"dire_wolf": _tex("res://assets/icons/footprints.svg"),
		"bandit": _tex("res://assets/icons/trending.svg"),
		"two_headed_serpent": _tex("res://assets/icons/link.svg"),
		"slime_boss": _tex("res://assets/icons/copy.svg"),
		"leech_league": _tex("res://assets/icons/users.svg"),
		"wraith": _tex("res://assets/icons/sparkles.svg"),
		"mimic": _tex("res://assets/icons/layers.svg"),
		"spider_queen": _tex("res://assets/icons/link.svg"),
		"commander": _tex("res://assets/icons/swords.svg"),
		"dragon": _tex("res://assets/icons/wand.svg"),
		"needleback": _tex("res://assets/icons/link.svg"),
		"gelatinous_cube": _tex("res://assets/icons/layers.svg"),
		"gargoyle": _tex("res://assets/icons/mountain.svg"),
		"harpy": _tex("res://assets/icons/sparkles.svg"),
		"kobold_trapper": _tex("res://assets/icons/users.svg"),
		"clockwork_knight": _tex("res://assets/icons/rotate.svg"),
		"basilisk": _tex("res://assets/icons/ban.svg"),
		"hollow": _tex("res://assets/icons/users.svg"),
		"beggar": _tex("res://assets/icons/layers.svg"),
		"wick": _tex("res://assets/icons/trending.svg"),
		"anvil": _tex("res://assets/icons/mountain.svg"),
	}
	tex_by_item = {
		"shield": tex_shield,
		"throwing_knife": tex_sword,
		"sai": _tex("res://assets/icons/swords.svg"),
		"medallion": _tex("res://assets/icons/sparkles.svg"),
		"helmet": _tex("res://assets/icons/layers.svg"),
		"da_boot": _tex("res://assets/icons/footprints.svg"),
		"bloody_gauntlets": _tex("res://assets/icons/droplet.svg"),
		"bracers": _tex("res://assets/icons/link.svg"),
		"left_bracer": _tex("res://assets/icons/link.svg"),
		"knucklers": _tex("res://assets/icons/hammer.svg"),
		"spiked_flail": _tex("res://assets/icons/trending.svg"),
		"sledgehammer": _tex("res://assets/icons/mountain.svg"),
		"grimoire": _tex("res://assets/icons/wand.svg"),
		"breastplate": _tex("res://assets/icons/shield.svg"),
		"smoke_bomb": _tex("res://assets/icons/sparkles.svg"),
		"fangs": _tex("res://assets/icons/skull.svg"),
		"poison_flask": _tex("res://assets/icons/droplet.svg"),
		"healing_potion": _tex("res://assets/icons/heart.svg"),
		"crossbow": _tex("res://assets/icons/plus.svg"),
		"pocketwatch": _tex("res://assets/icons/rotate.svg"),
		"double_axe": _tex("res://assets/icons/swords.svg"),
		"victory_flask": _tex("res://assets/icons/heart.svg"),
		"grappling_hook": _tex("res://assets/icons/link.svg"),
		"spiked_shield": tex_shield,
		"grief_jar": _tex("res://assets/icons/droplet.svg"),
		"longbow": _tex("res://assets/icons/plus.svg"),
		"lantern": _tex("res://assets/icons/sparkles.svg"),
		"mirror_shard": _tex("res://assets/icons/copy.svg"),
		"caltrops": _tex("res://assets/icons/footprints.svg"),
		"echo_bell": _tex("res://assets/icons/copy.svg"),
		"quiet_bell": _tex("res://assets/icons/ban.svg"),
		"net": _tex("res://assets/icons/link.svg"),
		"iron_chain": _tex("res://assets/icons/link.svg"),
		"counting_beads": _tex("res://assets/icons/sparkles.svg"),
		"last_match": _tex("res://assets/icons/palm.svg"),
		"measuring_tape": tex_sword,
		"mute_stone": _tex("res://assets/icons/rotate.svg"),
	}
	tex_special = {
		"no_atk_dmg": _tex("res://assets/icons/ban.svg"),
		"last_hp": _tex("res://assets/icons/copy.svg"),
		"double_hit": _tex("res://assets/icons/swords.svg"),
		"buff_hp": _tex("res://assets/icons/users.svg"),
		"hp_spin": tex_heart,
		"kill_scale": _tex("res://assets/icons/trending.svg"),
		"atk_spin": tex_sword,
		"item_atk": _tex("res://assets/icons/layers.svg"),
		"two_items": _tex("res://assets/icons/sparkles.svg"),
		"atk_eq_hp": _tex("res://assets/icons/link.svg"),
		"pack_hp": _tex("res://assets/icons/users.svg"),
		"copy_atk": _tex("res://assets/icons/copy.svg"),
		"gift": _tex("res://assets/icons/layers.svg"),
		"queen_hits": _tex("res://assets/icons/swords.svg"),
		"buff_atk": _tex("res://assets/icons/trending.svg"),
		"pierce": _tex("res://assets/icons/ban.svg"),
		"thorns": _tex("res://assets/icons/link.svg"),
		"eat_item": _tex("res://assets/icons/layers.svg"),
		"petrify": _tex("res://assets/icons/mountain.svg"),
		"interrupt": _tex("res://assets/icons/sparkles.svg"),
		"item_swings": _tex("res://assets/icons/footprints.svg"),
		"split_t2": _tex("res://assets/icons/rotate.svg"),
		"no_keep": _tex("res://assets/icons/ban.svg"),
		"even_twice": _tex("res://assets/icons/users.svg"),
		"zero_toll": _tex("res://assets/icons/skull.svg"),
		"left_atk": _tex("res://assets/icons/layers.svg"),
		"empty_purse": _tex("res://assets/icons/layers.svg"),
		"wickrise": _tex("res://assets/icons/trending.svg"),
		"one_chip": _tex("res://assets/icons/mountain.svg"),
		"no_defeat": _tex("res://assets/icons/ban.svg"),
		"atk_eq_blk": _tex("res://assets/icons/link.svg"),
		"item_double": _tex("res://assets/icons/swords.svg"),
		"pack_atk": _tex("res://assets/icons/users.svg"),
	}


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	dungeon_bg = DUNGEON_BG.new()
	add_child(dungeon_bg)
	dungeon_bg.setup(art)

	theme = load("res://themes/swipe_theme.tres")
	play_field = Control.new()
	play_field.set_anchors_preset(PRESET_FULL_RECT)
	play_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_field.clip_contents = false
	play_field.resized.connect(_layout_play_field)
	add_child(play_field)

	trophy = TROPHY_MOUNT.new()
	var skull_tex: Texture2D = tex_by_monster.get("skeleton", tex_heart)
	if art != null and art.tile("skull") != null:
		skull_tex = art.tile("skull")
	trophy.setup(skull_tex)
	play_field.add_child(trophy)

	tray = HBoxContainer.new()
	tray.add_theme_constant_override("separation", 12)
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	tray.visible = false
	play_field.add_child(tray)

	wheel_view = WHEEL_SCRIPT.new()
	wheel_view.custom_minimum_size = Vector2(624, 624)
	play_field.add_child(wheel_view)
	wheel_view.set_atlas(tex_heart, tex_sword, tex_plus, tex_by_monster, tex_special, tex_shield)
	var heart_full: Texture2D = _tex("res://assets/icons/heart_full.png")
	var heart_empty: Texture2D = _tex("res://assets/icons/heart_empty.png")
	if art != null:
		wheel_view.set_portraits(art.portraits())
		wheel_view.set_player(art.frames("knight_m"))
		if art.tile("ui_heart_full") != null:
			heart_full = art.tile("ui_heart_full")
		if art.tile("ui_heart_empty") != null:
			heart_empty = art.tile("ui_heart_empty")
	wheel_view.set_hub_hearts(heart_full, heart_empty)
	wheel_view.z_index = 0
	trophy.z_index = 6
	tray.z_index = 7
	wheel_view.slice_clicked.connect(_on_slice_clicked)
	wheel_view.slice_hovered.connect(_on_slice_hovered)
	wheel_view.slice_right_clicked.connect(_on_slice_right_clicked)

	hud = WHEEL_HUD_SCN.instantiate()
	add_child(hud)
	hearts_box = hud.hearts_box
	cue_label = hud.cue_label
	btn_spin = hud.btn_spin
	btn_done = hud.btn_done
	btn_start = hud.btn_start
	btn_place = hud.btn_place
	btn_bribe = hud.btn_bribe
	hotbar_box = hud.hotbar_box
	choice_box = hud.choice_box
	var ht: Texture2D = heart_full if heart_full != null else tex_heart
	if art != null and art.tile("ui_heart_full") != null:
		ht = art.tile("ui_heart_full")
	hud.setup_hearts(ht)
	btn_spin.pressed.connect(_on_spin)
	btn_done.pressed.connect(_on_done)
	btn_start.pressed.connect(_on_new)
	btn_place.pressed.connect(_on_place_mode)
	btn_bribe.pressed.connect(_on_bribe_mode)
	btn_spin.mouse_entered.connect(_on_spin_hover.bind(true))
	btn_spin.mouse_exited.connect(_on_spin_hover.bind(false))
	btn_place.mouse_entered.connect(_on_place_hover.bind(true))
	btn_place.mouse_exited.connect(_on_place_hover.bind(false))
	btn_done.mouse_entered.connect(_on_done_hover.bind(true))
	btn_done.mouse_exited.connect(_on_done_hover.bind(false))

	blk_hud = PanelContainer.new()
	blk_hud.visible = false
	blk_value = Label.new()

	placement_ui = PLACEMENT_SCN.instantiate()
	placement_ui.visible = false
	hud.plate_slot.add_child(placement_ui)
	fight_ui = FIGHT_SCN.instantiate()
	fight_ui.visible = false
	hud.plate_slot.add_child(fight_ui)
	if fight_ui.btn_resolve:
		fight_ui.btn_resolve.pressed.connect(_on_done)
	inspect = INSPECT_SCN.instantiate()
	inspect.accept_clicks = true
	inspect.size_flags_horizontal = Control.SIZE_FILL
	inspect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	hud.plate_slot.add_child(inspect)
	victory_ui = VICTORY_SCN.instantiate()
	victory_ui.visible = false
	hud.plate_slot.add_child(victory_ui)
	victory_ui.setup("victory")
	victory_ui.again_pressed.connect(_on_overlay_primary)
	defeat_ui = DEFEAT_SCN.instantiate()
	defeat_ui.visible = false
	hud.plate_slot.add_child(defeat_ui)
	defeat_ui.setup("defeat")
	defeat_ui.again_pressed.connect(_on_overlay_primary)
	if _authoring():
		inspect.edit_pressed.connect(_open_content_editor)
	_idle_inspect()

	dev_panel = VBoxContainer.new()
	dev_panel.visible = false
	dev_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dev_panel.add_theme_constant_override("separation", 8)
	hud.tools_slot.add_child(dev_panel)
	_build_dev_panel()

	log_btn = _pill("Log", Color("2a2622"), Color("6a5f52"), _toggle_log)
	log_btn.custom_minimum_size = Vector2(88, 34)
	log_btn.visible = false
	hud.tools_slot.add_child(log_btn)
	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	log_label.add_theme_font_size_override("normal_font_size", 12)
	log_label.visible = false
	log_label.add_theme_color_override("default_color", Color("d8cbb8"))
	log_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	log_label.z_index = 40
	log_label.top_level = true
	log_label.position = Vector2(1180, 28)
	log_label.size = Vector2(460, 320)
	log_label.custom_minimum_size = Vector2(460, 220)
	add_child(log_label)

	_build_overlay()
	_build_copy_stamp()
	fly_tip = HOVER_PANEL.new()
	fly_tip.visible = false
	fly_tip.z_index = 110
	fly_tip.top_level = true
	fly_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly_tip.accept_clicks = false
	add_child(fly_tip)
	if art != null:
		fly_tip.apply_skin(art.ui.get("panel_beige", null))

	talk_ui = TALK_BOX_SCN.instantiate()
	talk_ui.visible = false
	hud.plate_slot.add_child(talk_ui)
	tut = TUTORIAL_GUIDE.new()
	add_child(tut)
	tut.setup(art, talk_ui)
	tut.continued.connect(_tut_on_continue)
	tut.skipped.connect(_tut_skip)
	tut.finished.connect(_tut_finished)
	tut.auto_spin.connect(_tut_auto_spin)
	tut.play_adventure.connect(_tut_play_adventure)
	tut.mill_demo.connect(_tut_mill_demo)

	combat_stage = COMBAT_STAGE.new()
	add_child(combat_stage)
	combat_stage.setup(art)
	if _authoring():
		combat_stage.edit_wanted.connect(func(id: String) -> void: _open_content_editor("monster", id))

	face_box = HOVER_PANEL.new()
	face_box.visible = false
	face_box.z_index = 11
	face_box.top_level = true
	face_box.accept_clicks = true
	face_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(face_box)
	if art != null:
		face_box.apply_skin(art.ui.get("panel_beige", null))
	if _authoring():
		face_box.edit_pressed.connect(_open_content_editor)

	speech_box = SPEECH_BUBBLE.new()
	add_child(speech_box)
	speech_box.setup()

	draft_gate = DRAFT_GATE_SCN.instantiate()
	draft_gate.visible = false
	hud.plate_slot.add_child(draft_gate)
	draft_gate.setup(art)
	draft_gate.send_pressed.connect(_on_gate_send)
	draft_gate.refuse_pressed.connect(_on_gate_refuse)

	_courier = TextureRect.new()
	_courier.texture_filter = TEXTURE_FILTER_NEAREST
	_courier.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_courier.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_courier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_courier.z_index = 100
	_courier.top_level = true
	_courier.visible = false
	_courier.size = Vector2(96, 96)
	add_child(_courier)

	fx_flash = ColorRect.new()
	fx_flash.color = Color(1, 1, 1, 1)
	fx_flash.modulate.a = 0.0
	fx_flash.set_anchors_preset(PRESET_FULL_RECT)
	fx_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_flash.z_index = 60
	add_child(fx_flash)
	_hall_wipe = ColorRect.new()
	_hall_wipe.color = Color("080605")
	_hall_wipe.modulate.a = 0.0
	_hall_wipe.visible = false
	_hall_wipe.set_anchors_preset(PRESET_FULL_RECT)
	_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hall_wipe.z_index = 70
	add_child(_hall_wipe)

	sfx = AUDIO_FX.new()
	add_child(sfx)
	sfx.setup()
	settings_ui = SETTINGS_MENU.new()
	add_child(settings_ui)
	settings_ui.setup(sfx)
	title_ui = TITLE_SCN.instantiate()
	add_child(title_ui)
	title_ui.setup(art)
	title_ui.visible = false
	title_ui.begin_pressed.connect(_begin_run)
	title_ui.how_pressed.connect(_start_tutorial)
	title_ui.dive_pressed.connect(_quick_start)
	title_ui.adventure_pressed.connect(_begin_adventure)
	title_ui.dev_pressed.connect(_open_dev_test)
	title_ui.roster_pressed.connect(_open_roster)
	title_ui.script_pressed.connect(_open_script)
	if title_ui.has_signal("log_pressed"):
		title_ui.log_pressed.connect(_toggle_play_log)
	settings_ui.mode_picked.connect(_on_pause_mode)
	settings_ui.quit_pressed.connect(_quit_game)
	if _authoring():
		settings_ui.roster_pressed.connect(_open_roster)
		settings_ui.script_pressed.connect(_open_script)
		content_ed = CONTENT_EDITOR.new()
		add_child(content_ed)
		content_ed.setup()
		content_ed.saved.connect(_on_content_saved)
		roster_ed = ROSTER_EDITOR.new()
		add_child(roster_ed)
		roster_ed.setup(art, sfx)
		roster_ed.committed.connect(_on_roster_committed)
		roster_ed.open_card.connect(_open_content_editor)
		script_ed = SCRIPT_EDITOR.new()
		add_child(script_ed)
		script_ed.setup(sfx)
		script_ed.saved.connect(_on_script_saved)
	call_deferred("_layout_play_field")


func _build_overlay() -> void:
	overlay = ColorRect.new()
	overlay.color = Color("0c0908f4")
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var wrap := CenterContainer.new()
	wrap.set_anchors_preset(PRESET_FULL_RECT)
	overlay.add_child(wrap)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	wrap.add_child(col)
	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 64)
	overlay_title.add_theme_color_override("font_color", Color("e8c36a"))
	overlay_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	overlay_title.add_theme_constant_override("outline_size", 8)
	col.add_child(overlay_title)
	overlay_sub = Label.new()
	overlay_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_sub.custom_minimum_size = Vector2(720, 0)
	overlay_sub.add_theme_font_size_override("font_size", 20)
	overlay_sub.add_theme_color_override("font_color", Color("d8cbb8"))
	overlay_sub.add_theme_color_override("font_outline_color", Color("100e0c"))
	overlay_sub.add_theme_constant_override("outline_size", 3)
	col.add_child(overlay_sub)
	overlay_score = Label.new()
	overlay_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_score.add_theme_font_size_override("font_size", 32)
	overlay_score.add_theme_color_override("font_color", Color("e8c36a"))
	overlay_score.visible = false
	col.add_child(overlay_score)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	col.add_child(row)
	overlay_tut = _pill(PLAYER_COPY.text("title.how_to_play", "How to Play"), Color("3a2820"), Color("e8c36a"), _start_tutorial)
	overlay_dive = _pill(PLAYER_COPY.text("title.dive_in", "Dive In"), Color("2a2622"), Color("c4a574"), _quick_start)
	overlay_btn = _pill(PLAYER_COPY.text("title.begin", "Begin"), Color("2a2622"), Color("6a5f52"), _on_overlay_primary)
	overlay_adventure = _pill(PLAYER_COPY.text("title.adventure", "Adventure Mode"), Color("3a2820"), Color("e8c36a"), _begin_adventure)
	row.add_child(overlay_tut)
	row.add_child(overlay_dive)
	row.add_child(overlay_btn)
	row.add_child(overlay_adventure)
	overlay_rest_row = HBoxContainer.new()
	overlay_rest_row.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay_rest_row.add_theme_constant_override("separation", 14)
	col.add_child(overlay_rest_row)
	overlay_continue = _pill(PLAYER_COPY.text("title.continue", "Continue"), Color("3a3220"), Color("e8c36a"), _adventure_continue)
	overlay_leave = _pill(PLAYER_COPY.text("title.leave", "Leave"), Color("2a2622"), Color("6a5f52"), _adventure_leave)
	overlay_rest_row.add_child(overlay_continue)
	overlay_rest_row.add_child(overlay_leave)
	overlay_rest_row.visible = false
	overlay_tools_row = HBoxContainer.new()
	overlay_tools_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(overlay_tools_row)
	if _authoring():
		overlay_dev = _pill("Developer Test", Color("1c1814"), Color("8a8178"), _open_dev_test)
		overlay_tools_row.add_child(overlay_dev)
		overlay_roster = _pill("Roster", Color("3a2820"), Color("c4a574"), _open_roster)
		overlay_tools_row.add_child(overlay_roster)
		overlay_script = _pill("Script", Color("3a2820"), Color("c4a574"), _open_script)
		overlay_tools_row.add_child(overlay_script)
		overlay_log = _pill("Event log: off", Color("1c1814"), Color("8a8178"), _toggle_play_log)
		overlay_tools_row.add_child(overlay_log)
	else:
		overlay_tools_row.visible = false
	overlay.z_index = 80


func _legend() -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 4)
	var order: Array[String] = [
		"on_click", "on_spin", "on_item_use", "on_resolve", "on_remove_slice",
		"on_draft", "on_place", "on_bribe",
		"var", "atk", "blk", "hp", "discard", "keep", "end"
	]
	for k in order:
		var info: Dictionary = LOG_KIND[k]
		var l := Label.new()
		l.text = str(info["tag"])
		l.add_theme_font_size_override("font_size", 11)
		l.add_theme_color_override("font_color", Color(str(info["hex"])))
		flow.add_child(l)
	return flow


func _pill(text: String, fill: Color, rim: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("c4a574"))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	b.add_theme_stylebox_override("normal", _sb(fill, rim, 2))
	b.add_theme_stylebox_override("hover", _sb(fill.lightened(0.16), rim.lightened(0.2), 3))
	b.add_theme_stylebox_override("pressed", _sb(fill.darkened(0.12), rim, 2))
	b.add_theme_stylebox_override("focus", _sb(fill, rim.lightened(0.35), 3))
	var dim := fill
	dim.a = 0.45
	b.add_theme_stylebox_override("disabled", _sb(dim, Color(rim.r, rim.g, rim.b, 0.35), 1))
	b.pressed.connect(cb)
	return b


func _sb(fill: Color, rim: Color, border: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = rim
	s.set_border_width_all(border)
	s.set_corner_radius_all(999)
	s.shadow_color = Color(0.05, 0.03, 0.02, 0.45)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 2)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


func _play_hall_wipe() -> void:
	if _hall_wipe:
		_hall_wipe.visible = true
		_hall_wipe.mouse_filter = Control.MOUSE_FILTER_STOP
		_hall_wipe.modulate.a = 0.0
	await _walk_knight_off()
	if dungeon_bg:
		var tw_pan := create_tween()
		tw_pan.tween_property(dungeon_bg, "pan", dungeon_bg.pan + 520.0, 0.45)
	if _hall_wipe:
		var tw := create_tween()
		tw.tween_property(_hall_wipe, "modulate:a", 1.0, 0.28)
		await tw.finished
	if dungeon_bg:
		dungeon_bg.bump_hall()
	if sfx:
		sfx.play("door_open", -8.0)
		sfx.play("whoosh", -10.0, 0.9)
	if _hall_wipe:
		var tw2 := create_tween()
		tw2.tween_property(_hall_wipe, "modulate:a", 0.0, 0.34)
		await tw2.finished
		_hall_wipe.visible = false
		_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _walk_knight_off() -> void:
	var frames: Array = []
	if art:
		frames = art.run_frames("knight_m")
		if frames.is_empty():
			frames = art.frames("knight_m")
	if frames.is_empty() or _courier == null:
		return
	_courier.texture = frames[0]
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2(1.35, 1.35)
	_courier.modulate.a = 1.0
	var start: Vector2 = Vector2(size.x * 0.46, size.y * 0.58)
	if wheel_view:
		start = wheel_view.global_position + wheel_view.size * Vector2(0.5, 0.62)
	_courier.global_position = start - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("cloth", -10.0)
	var dest := Vector2(size.x + 70.0, start.y) - _courier.pivot_offset
	var tw := create_tween()
	tw.tween_property(_courier, "global_position", dest, 0.62)
	var fi: int = 0
	await get_tree().process_frame
	while tw.is_running():
		fi = (fi + 1) % frames.size()
		_courier.texture = frames[fi]
		await get_tree().create_timer(0.07).timeout
	_courier.visible = false
	_courier.scale = Vector2.ONE


func _tier_metal(tier: int) -> Color:
	return UX.metal(tier)


func _utility_fill(ops_kind: String, family: String) -> Color:
	if ops_kind == "atk_neighbor" or ops_kind == "atk_opposite":
		return FILL_YELLOW
	if ops_kind == "hook_swap":
		return FILL_YELLOW
	if ops_kind == "heal_kills" or ops_kind == "heal_keep" or ops_kind == "heal_full":
		return Color("243a22")
	if ops_kind == "chaos_reroll":
		return Color("3a1460")
	match family:
		"BLK":
			return Color("1c3d52")
		"DEFEAT", "FANGS":
			return Color("3a2450")
		"PASSIVE":
			return Color("243a22")
		"SMOKE", "SKIP":
			return Color("3a2a38")
		"MARK":
			if ops_kind == "mark_poison":
				return Color("1e3324")
			return Color("4a3d14")
		_:
			return Color("5c2626")


func _item_look(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var tier: int = _tier_of(it)
	return {
		"fill": view.get("fill", Color("5c2626")),
		"metal": _tier_metal(tier),
		"tier": tier,
	}


func _item_inspect_body(it: Dictionary, _rule: Dictionary) -> String:
	var ab: String = str(it.get("ability", "")).strip_edges()
	if ab == "" or ab == "---":
		return ""
	if ab.find("[color") < 0 and ab.find("[bgcolor") < 0:
		return _paint_item_text(ab, it, false)
	return ab


func _item_display_kind(it: Dictionary) -> String:
	var tint: String = str(it.get("card_color", "")).strip_edges()
	if tint == "":
		var cat: Dictionary = items_by_id.get(str(it.get("card_id", "")), {})
		tint = str(cat.get("card_color", "")).strip_edges()
	var shown: String = UX.display_kind(tint)
	if shown != "":
		return shown
	return str(_item_view(it).get("kind", "ATK"))


func _item_inspect_look(it: Dictionary) -> Dictionary:
	var look: Dictionary = _item_look(it)
	look["title_size"] = 26
	look["title_bold"] = true
	if _shift_held and str(_item_rule(it).get("equation", "")).strip_edges() != "":
		return look
	var view: Dictionary = _item_view(it)
	var k: String = _item_display_kind(it)
	var shown: String = str(view.get("number", "")).strip_edges()
	if k == "ATK" and str(it.get("card_id", "")) == "spiked_shield":
		look["stat_kind"] = "BOTH"
		look["stat_atk"] = 2
		look["stat_blk"] = 2
		return look
	if k == "ATK":
		look["stat_kind"] = "ATK"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "BLK":
		look["stat_kind"] = "BLK"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "HEAL":
		look["stat_kind"] = "HEAL"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "DEFEAT" or k == "FANGS":
		look["stat_bb"] = _value_bb("Defeat", "", "#C9A0FF")
	elif shown != "" and shown != "—":
		look["stat_bb"] = _paint_explainer(shown)
	return look


func _pin_top_right(panel: Control) -> void:
	_pin_side_callout(panel, "right")


func _pin_side_callout(panel: Control, side: String) -> void:
	if panel == null:
		return
	panel.top_level = true
	panel.z_index = 25
	panel.reset_size()
	var sz: Vector2 = panel.get_combined_minimum_size()
	sz.x = clampf(sz.x, 260.0, 336.0)
	panel.size = sz
	var vp: Vector2 = get_viewport_rect().size
	var y := 28.0
	var x: float
	if side == "left":
		x = 32.0
	else:
		x = vp.x - sz.x - 32.0
	if wheel_view != null:
		var wr: Rect2 = wheel_view.get_global_rect().grow(8.0)
		var box := Rect2(Vector2(x, y), sz)
		if box.intersects(wr):
			if side == "left":
				x = maxf(8.0, wr.position.x - sz.x - 12.0)
			else:
				x = minf(vp.x - sz.x - 8.0, wr.end.x + 12.0)
	if hotbar_box != null and hotbar_box.visible:
		var hand: Rect2 = hotbar_box.get_global_rect()
		if y + sz.y > hand.position.y - 8.0:
			y = maxf(8.0, hand.position.y - sz.y - 8.0)
	panel.global_position = Vector2(x, y)


func _show_item_inspect(it: Dictionary) -> void:
	if it.is_empty() or fly_tip == null:
		return
	var rule: Dictionary = _item_rule(it)
	var body: String = _item_inspect_body(it, rule)
	var eq: String = str(rule.get("equation", "")) if _shift_held else ""
	var port: Texture2D = null
	if art != null:
		port = art.item_tex(str(it.get("card_id", "")))
	if inspect != null:
		inspect.hide_plate()
		inspect.top_level = false
	_set_inspect_idle(false)
	if fight_ui:
		fight_ui.visible = false
	if placement_ui:
		placement_ui.visible = false
	fly_tip.show_rule(
		str(rule["title"]),
		"",
		eq,
		body,
		str(rule.get("warn", "")),
		port,
		"item",
		str(it.get("card_id", "")),
		_item_inspect_look(it)
	)
	_pin_side_callout(fly_tip, "left")
	_sync_authoring_chrome()


func _monster_look(s: Dictionary) -> Dictionary:
	var tier: int = _tier_of(s)
	var fill := Color("2a1610")
	if tier == 2:
		fill = Color("1a0c14")
	elif tier >= 3:
		fill = Color("100308")
	return {
		"fill": fill,
		"metal": _tier_metal(tier),
		"tier": tier,
		"scary": true,
	}


func _fly_courier(tex: Texture2D, from: Vector2, to: Vector2, dur: float = 0.4) -> void:
	if _courier == null or tex == null:
		await get_tree().create_timer(0.08).timeout
		return
	_courier.texture = tex
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2.ONE
	_courier.modulate.a = 1.0
	_courier.global_position = from - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("whoosh", -10.0, 1.1)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(_courier, "global_position", to - _courier.pivot_offset, dur)
	tw.parallel().tween_property(_courier, "scale", Vector2(0.42, 0.42), dur)
	await tw.finished
	_courier.visible = false
	_courier.scale = Vector2.ONE


func _apply_overlay_copy() -> void:
	if overlay_tut:
		overlay_tut.text = PLAYER_COPY.text("title.how_to_play", "How to Play")
	if overlay_dive:
		overlay_dive.text = PLAYER_COPY.text("title.dive_in", "Dive In")
	if overlay_adventure:
		overlay_adventure.text = PLAYER_COPY.text("title.adventure", "Adventure Mode")
	if overlay_continue:
		overlay_continue.text = PLAYER_COPY.text("title.continue", "Continue")
	if overlay_leave:
		overlay_leave.text = PLAYER_COPY.text("title.leave", "Leave")
	if btn_spin:
		btn_spin.text = PLAYER_COPY.text("combat.spin", "Spin")
	_sync_overlay()


func _on_slice_hovered(index: int) -> void:
	if _fly_card != null:
		return
	if inspect == null:
		return
	if index < 0 or index >= wheel.size():
		_hover_slice = -1
		_refresh_seat_preview(-1)
		if fly_tip != null and fly_tip.edit_kind == "monster":
			fly_tip.hide_plate()
		_idle_inspect()
		return
	if index != _hover_slice and sfx and phase != "spinning":
		sfx.hover()
	_hover_slice = index
	_refresh_seat_preview(index)
	_idle_inspect()
	_sync_torch()
	_tutorial_on_slice_hover(index)


func _play_ended_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		sfx.play("bong", -6.0)
		sfx.play("whoosh", -10.0, 1.15)
		sfx.play("scratch", -10.0, 0.85)
	if combat_stage:
		combat_stage.take_hit()
	if wheel_view and facing_index >= 0:
		await wheel_view.play_slay(facing_index)
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0:
		await wheel_view.collapse_slice(facing_index)


func _play_leave_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0:
		await wheel_view.collapse_slice(facing_index)


func _play_attack_connect() -> void:
	_flash_screen(Color("e07a7a"), 0.28)
	_refresh_hearts()
	_refresh_blk(false)
	if sfx:
		sfx.play("chop", -6.0)
		sfx.play("error", -18.0, 0.8)


func _play_attack_blocked() -> void:
	_flash_screen(Color("5aa8e8"), 0.4)
	_refresh_blk(false)
	if sfx:
		sfx.play("block_heavy", -5.0)
		sfx.play("bong", -8.0, 1.12)
		sfx.play("glass", -12.0, 1.3)
	if combat_stage:
		combat_stage.play_block()
	if facing_index >= 0 and wheel_view:
		await wheel_view.play_block(facing_index)


func _flash_banner(msg: String) -> void:
	if play_field == null or msg.strip_edges() == "":
		return
	var lab := Label.new()
	lab.text = msg
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 28)
	lab.add_theme_color_override("font_color", Color("f0e6d8"))
	lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	lab.add_theme_constant_override("outline_size", 6)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 40
	play_field.add_child(lab)
	lab.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lab.offset_left = -220.0
	lab.offset_right = 220.0
	lab.offset_top = -24.0
	lab.offset_bottom = 24.0
	lab.modulate.a = 0.0
	var tw := lab.create_tween()
	tw.tween_property(lab, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.7)
	tw.tween_property(lab, "modulate:a", 0.0, 0.35)
	tw.finished.connect(lab.queue_free)


func _is_yellow_fill(fill: Color) -> bool:
	return fill.r > 0.22 and fill.g > 0.18 and fill.b < 0.16 and fill.r >= fill.g


func _apply_preview(p: Dictionary) -> void:
	if wheel_view:
		wheel_view.set_preview(p)
	_refresh_blk(false)


func _on_spin_hover(on: bool) -> void:
	if not on or phase != "ready":
		_apply_preview({})
		return
	var p: Dictionary = {}
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if bool(s.get("atk_variable", false)) or bool(s.get("hp_variable", false)):
			p[i] = {"mark": "spin"}
	_apply_preview(p)


func _on_place_hover(on: bool) -> void:
	if not on or pending_item.is_empty() or (phase != "starter" and phase != "draft"):
		if not on:
			_apply_preview({})
		return
	var p: Dictionary = {}
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) == "bandit":
			p[i] = {"atk": 1}
	_apply_preview(p)


func _refresh_seat_preview(index: int) -> void:
	if wheel_view == null:
		return
	if not _can_place() or index < 0 or index >= wheel.size() or str(wheel[index].get("kind", "")) != "empty":
		if not wheel_view.seat_fx.is_empty():
			wheel_view.set_seat_fx({})
			_apply_preview({})
		return
	var n: int = wheel.size()
	var before_hp: Array[int] = []
	var before_atk: Array[int] = []
	var before_copy: Array[int] = []
	var before_x2: Array[bool] = []
	before_hp.resize(n)
	before_atk.resize(n)
	before_copy.resize(n)
	before_x2.resize(n)
	for i in n:
		before_hp[i] = int(wheel[i].get("hp", 0))
		before_atk[i] = int(wheel[i].get("atk", 0))
		before_copy[i] = int(wheel[i].get("copy_from", -1))
		before_x2[i] = false
	var saved: Array = []
	for s in wheel:
		saved.append((s as Dictionary).duplicate(true))
	var m: Dictionary = pending_monster.duplicate(true)
	m["slot"] = str(wheel[index].get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else ""))
	m["spin_locked"] = false
	wheel[index] = m
	_sync_wheel_stats()
	var preview: Dictionary = {}
	var links: Array = []
	for i in n:
		var hp_d: int = int(wheel[i].get("hp", 0)) - before_hp[i]
		var atk_d: int = int(wheel[i].get("atk", 0)) - before_atk[i]
		if i == index:
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if hp_d != 0 or atk_d != 0:
			var row: Dictionary = {}
			if hp_d != 0:
				row["hp"] = hp_d
				links.append({"to": i, "stat": "hp", "delta": hp_d})
			if atk_d != 0:
				row["atk"] = atk_d
				var tag := ""
				var copy_src: int = int(wheel[i].get("copy_from", -1))
				if str(wheel[i].get("card_id", "")) == "wraith" and copy_src >= 0 and copy_src != before_copy[i]:
					tag = "copy"
				links.append({"to": i, "stat": "atk", "delta": atk_d, "tag": tag, "src": copy_src})
			preview[i] = row
	var own_hp: int = int(pending_monster.get("hp", 0))
	var own_atk: int = int(pending_monster.get("atk", 0))
	var self_row := {
		"id": str(wheel[index].get("card_id", "")),
		"name": str(wheel[index].get("name", "")),
		"hp": int(wheel[index].get("hp", 0)),
		"atk": int(wheel[index].get("atk", 0)),
		"hp_d": int(wheel[index].get("hp", 0)) - own_hp,
		"atk_d": int(wheel[index].get("atk", 0)) - own_atk,
		"pack_tier": int(wheel[index].get("pack_tier", wheel[index].get("tier", 1))),
		"copy_from": int(wheel[index].get("copy_from", -1)),
		"preview_x2": false,
	}
	if str(self_row["id"]) == "wraith" and int(self_row["copy_from"]) >= 0:
		links.append({
			"to": index,
			"stat": "atk",
			"delta": int(self_row["atk_d"]),
			"tag": "copy",
			"src": int(self_row["copy_from"]),
		})
	if bool(self_row["preview_x2"]):
		var qn: int = wheel.size()
		for off in [qn - 1, 1]:
			var nb: int = (index + off) % qn
			if str(wheel[nb].get("kind", "")) == "monster" and int(wheel[nb].get("hp", 0)) < int(self_row["hp"]):
				links.append({"to": index, "stat": "atk", "delta": 0, "tag": "x2", "src": nb})
	var prev_from: int = int(wheel_view.seat_fx.get("from", -1))
	wheel.clear()
	for s2 in saved:
		wheel.append(s2)
	_sync_wheel_stats()
	_apply_preview(preview)
	wheel_view.set_seat_fx({"from": index, "links": links, "self": self_row})
	if not links.is_empty() and sfx and prev_from != index:
		sfx.play("whoosh", -16.0, 1.25)


func _preview_bribe(index: int) -> Dictionary:
	var p: Dictionary = {}
	var n: int = wheel.size()
	if index < 0 or index >= n:
		return p
	if str(wheel[index].get("card_id", "")) == "lich" and not _is_silenced(wheel[index]):
		for off in [n - 1, 1]:
			var j: int = (index + off) % n
			if str(wheel[j].get("kind", "")) == "monster":
				p[j] = {"hp": -1}
	if str(wheel[index].get("card_id", "")) == "commander" and not _is_silenced(wheel[index]):
		for off_c in [n - 1, 1]:
			var jc: int = (index + off_c) % n
			if str(wheel[jc].get("kind", "")) == "monster":
				var curc: Dictionary = p.get(jc, {})
				curc["atk"] = int(curc.get("atk", 0)) - 2
				p[jc] = curc
	for off2 in [n - 1, 1]:
		var k: int = (index + off2) % n
		if str(wheel[k].get("card_id", "")) == "lich" and not _is_silenced(wheel[k]) and str(wheel[index].get("kind", "")) == "monster":
			var cur: Dictionary = p.get(index, {})
			cur["hp"] = int(cur.get("hp", 0)) - 1
			p[index] = cur
		if str(wheel[k].get("card_id", "")) == "commander" and not _is_silenced(wheel[k]) and str(wheel[index].get("kind", "")) == "monster":
			var cur2: Dictionary = p.get(index, {})
			cur2["atk"] = int(cur2.get("atk", 0)) - 2
			p[index] = cur2
	return p


func _preview_from_item(it: Dictionary) -> Dictionary:
	_ghost_blk = -1
	var p: Dictionary = {}
	if phase != "fighting" or facing_index < 0:
		return p
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var view: Dictionary = _item_view(it)
	var n: int = int(view.get("n", 0))
	match kind:
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_siphon", "blk_from_atk":
			if bool(view.get("can_use", false)):
				var gain_n: int = maxi(0, n)
				if _twins_double_blk(gain_n):
					gain_n *= 2
				_ghost_blk = blk + gain_n
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "choose", "atk_wheel", "atk_echo", "atk_spend_blk", "atk_empty", "atk_hp_gap":
			var drop_prev := false
			if kind == "choose":
				var popts: Variant = _ops_of(it).get("options", [])
				if typeof(popts) == TYPE_ARRAY:
					for po in popts:
						if typeof(po) == TYPE_DICTIONARY and (po as Dictionary).has("atk_drop"):
							drop_prev = true
							break
			if drop_prev:
				pass
			elif bool(view.get("can_use", false)) and str(wheel[facing_index].get("card_id", "")) != "goblin":
				var dmg: int = n if kind != "choose" else int(view.get("n", 3))
				var procs: int = 2 if _twins_double_atk(facing_index, dmg) else 1
				var total: int = 0
				for _p in range(procs):
					var hitn: int = dmg
					if str(wheel[facing_index].get("card_id", "")) == "anvil" and not _is_silenced(wheel[facing_index]):
						hitn = mini(hitn, 1)
					total += hitn
				p[facing_index] = {"hp": -total}
				if int(wheel[facing_index].get("hp", 0)) - total <= 0:
					if str(wheel[facing_index].get("card_id", "")) != "wick" or _is_silenced(wheel[facing_index]):
						p[facing_index]["kill"] = true
				if str(wheel[facing_index].get("card_id", "")) == "slime_boss":
					p[facing_index]["atk"] = -total
		"atk_cleave":
			if bool(view.get("can_use", false)):
				var cn: int = int(view.get("n", 2))
				for ci in _cleave_targets():
					if str(wheel[ci].get("card_id", "")) == "goblin":
						continue
					var procs_c: int = 2 if _twins_double_atk(ci, cn) else 1
					var hitn: int = 0
					for _pc in range(procs_c):
						var one: int = cn
						if str(wheel[ci].get("card_id", "")) == "anvil" and not _is_silenced(wheel[ci]):
							one = mini(cn, 1)
						hitn += one
					var slot: Dictionary = p.get(ci, {})
					slot["hp"] = int(slot.get("hp", 0)) - hitn
					if int(wheel[ci].get("hp", 0)) + int(slot.get("hp", 0)) <= 0:
						slot["kill"] = true
					if str(wheel[ci].get("card_id", "")) == "slime_boss":
						slot["atk"] = int(slot.get("atk", 0)) - cn
					p[ci] = slot
		"atk_opposite":
			var oi: int = _opposite_index()
			if bool(view.get("can_use", false)) and oi >= 0 and str(wheel[oi].get("card_id", "")) != "goblin":
				var od: int = int(view.get("n", 4))
				var procs_o: int = 2 if _twins_double_atk(oi, od) else 1
				var od_total: int = 0
				for _po in range(procs_o):
					var one_o: int = od
					if str(wheel[oi].get("card_id", "")) == "anvil" and not _is_silenced(wheel[oi]):
						one_o = mini(od, 1)
					od_total += one_o
				od = od_total
				p[oi] = {"hp": -od}
				if int(wheel[oi].get("hp", 0)) - od <= 0:
					p[oi]["kill"] = true
				if str(wheel[oi].get("card_id", "")) == "slime_boss":
					p[oi]["atk"] = -od
		"defeat_hp", "defeat_atk", "fangs", "defeat_only_item":
			if bool(view.get("can_use", false)):
				p[facing_index] = {"hp": -int(wheel[facing_index].get("hp", 0)), "kill": true}
		"atk_zero", "atk_drop":
			if bool(view.get("can_use", false)):
				var curz: Dictionary = p.get(facing_index, {})
				var drop_n: int = int(wheel[facing_index].get("atk", 0)) if kind == "atk_zero" else mini(3, int(wheel[facing_index].get("atk", 0)))
				curz["atk"] = -drop_n if kind == "atk_zero" else -mini(int(view.get("n", 3)), int(wheel[facing_index].get("atk", 0)))
				p[facing_index] = curz
		"skip_swing":
			if bool(view.get("can_use", false)):
				p[facing_index] = {"kill": true}
	if items_used_this_combat + 1 >= 2:
		for i in range(wheel.size()):
			if str(wheel[i].get("card_id", "")) == "two_headed_serpent" and i == facing_index:
				var cur2: Dictionary = p.get(i, {})
				cur2["atk"] = -int(wheel[i].get("atk", 0))
				p[i] = cur2
	if not bool(it.get("keep_after", false)) and kind != "choose":
		for i2 in range(wheel.size()):
			if str(wheel[i2].get("card_id", "")) == "bandit" and not bool(wheel[i2].get("spin_locked", false)):
				var cur3: Dictionary = p.get(i2, {})
				cur3["atk"] = int(cur3.get("atk", 0)) - 1
				p[i2] = cur3
	return p


func _punch_blk() -> void:
	if wheel_view:
		wheel_view.punch_hub()


func _refresh_blk(punch: bool) -> void:
	if wheel_view:
		wheel_view.set_vitals(hp, HP_MAX, _ghost_hp, blk, _ghost_blk)
	if punch and _ghost_blk < 0 and blk > _blk_shown and _blk_shown >= 0:
		_punch_blk()
	if _ghost_blk < 0:
		_blk_shown = blk


func _inspect_item(it: Dictionary, force: bool = false) -> void:
	if inspect == null:
		return
	if _inspect_pinned and not force:
		return
	_show_item_inspect(it)


func _paint_explainer(raw: String, num_hex: String = "#E07A7A") -> String:
	return UX.paint(raw, true, num_hex)


func _paint_item_text(raw: String, it: Dictionary, formula: bool = false) -> String:
	var t: String = raw.strip_edges()
	if t == "" or t.find("[color") >= 0 or t.find("[bgcolor") >= 0:
		return raw
	if str(it.get("card_id", "")) == "spiked_shield":
		return UX.paint(t, true, "#E07A7A", "", false)
	var k: String = _item_display_kind(it)
	if not UX.is_stat_kind(k) or k == "BOTH":
		return UX.paint(t, true, "#E07A7A", "", formula)
	return UX.paint(t, true, UX.kind_hex(k), k, formula)


func _capitalize_keywords(raw: String) -> String:
	return UX.paint(raw, false, "")


func _value_bb(word: String, n: String, hex: String) -> String:
	if n == "":
		return UX.chip(word, hex)
	return UX.chip("%s %s" % [word, n], hex)


func _item_rule(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var kind: String = str(_ops_of(it).get("kind", ""))
	var live: int = int(view.get("n", 0))
	var fighting: bool = phase == "fighting" and facing_index >= 0
	var m: Dictionary = wheel[facing_index] if fighting else {}
	var out := {
		"title": _title_case(str(it.get("name", "?"))),
		"value": "",
		"equation": "",
		"body": "",
		"warn": "",
	}
	if str(it.get("card_id", "")) == "echo_bell":
		var face_t: Dictionary = _echo_face(it)
		if not face_t.is_empty():
			out["title"] = _title_case(str(face_t.get("name", "Echo Bell")))
	var hp_c := "#E8A0A0"
	var atk_c := "#E07A7A"
	var var_c := "#C9A0FF"
	var gold := "#E8C36A"
	var blk_c := "#6BB3D9"
	var num_c: String = UX.kind_hex(str(view.get("kind", "ATK")))
	if kind == "smoke" or kind == "hook_swap":
		num_c = gold
	var cream := num_c
	match kind:
		"blk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["body"] = "Gain 4 block."
		"atk_alt_24":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) or (%s) on Item use" % [_bb(atk_c, "2"), _bb(atk_c, "4")]
			out["body"] = "Atk swaps between 2 ↔ 4 each time an Item is used."
		"choose":
			var drop_n := false
			var spike_n := false
			var copts: Variant = _ops_of(it).get("options", [])
			if typeof(copts) == TYPE_ARRAY:
				for o2 in copts:
					if typeof(o2) != TYPE_DICTIONARY:
						continue
					if (o2 as Dictionary).has("atk_drop"):
						drop_n = true
					if (o2 as Dictionary).has("blk") and (o2 as Dictionary).has("atk"):
						spike_n = true
			if drop_n:
				out["value"] = _value_bb("Attack", "−1 / −2 / −3", atk_c)
				out["body"] = "Click 1, 2, or 3. The facing monster's Attack drops by that much after every other formula, then stays there this fight."
			elif spike_n or str(it.get("card_id", "")) == "spiked_shield":
				out["value"] = "%s    %s" % [_value_bb("Attack", "2", atk_c), _value_bb("Block", "2", blk_c)]
				out["equation"] = "(%s) or (%s)" % [_bb(atk_c, "2"), _bb(blk_c, "2")]
				out["body"] = "Deal 2 attack, or gain 2 block."
			else:
				out["value"] = _value_bb("Attack", "3", atk_c)
				out["equation"] = "(%s) or (%s and %s)" % [_bb(atk_c, "3"), _bb(atk_c, "1"), _bb(gold, "Keep")]
				out["body"] = "Throw for 3 and lose it, or nick for 1 and keep it."
		"atk_if_enemy_atk_even":
			out["value"] = _value_bb("Attack", str(live if fighting else 4), atk_c)
			out["equation"] = "(%s) or (%s if %s)" % [_bb(cream, "2"), _bb(atk_c, "4"), _bb(gold, "Even ATK")]
			out["body"] = "Attack 2, or 4 if the enemy's attack is even."
		"blk_from_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "6"), _bb(blk_c, "HP")]
			out["body"] = "Block equal to the HP you are missing."
		"blk_min_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(the lower of %s and %s)" % [_bb(blk_c, "Your HP"), _bb(blk_c, "Enemy HP")]
			out["body"] = "Block equal to whoever has less HP — you or the enemy."
		"defeat_hp":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s < %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = "Defeat an enemy with less HP than you. Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.boot", "Can't — this enemy has as much HP as you, or more.")
		"atk_7_hp":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "7"), _bb(hp_c, "HP")]
			out["body"] = "Attack equal to the HP you are missing, counted from 7."
		"blk_neighbor":
			out["value"] = _value_bb("Block", str(live) if live >= 0 else "—", blk_c)
			if str(it.get("card_id", "")) == "left_bracer":
				out["equation"] = "(%s)" % _bb(blk_c, "Left Neighbor ATK")
				out["body"] = "Block equal to the Atk of the Neighbor to the Left."
			else:
				out["equation"] = "(%s)" % _bb(blk_c, "Right Neighbor ATK")
				out["body"] = "Block equal to the Atk of the Neighbor to the Right."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"atk_7_items":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "8"), _bb(gold, "Items")]
			out["body"] = "Attack equal to 8 minus the items still in your hand."
		"atk_2_kills":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "2"), _bb(var_c, "Defeat")]
			out["body"] = "Get stronger. +1 attack for each monster defeated."
		"atk_hp_loss":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s × %s)" % [_bb(cream, "2"), _bb(hp_c, "Times you Bled")]
			out["body"] = "Starts at 0. +2 attack each time you lose any HP."
		"defeat_atk":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s ≥ %s)" % [_bb(atk_c, "Enemy ATK"), _bb(cream, "5")]
			out["body"] = "Defeat an enemy with 5 or more attack. Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.sledge", "Can't — this enemy's attack is under 5.")
		"atk_last":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Last Enemy ATK")
			out["body"] = "Attack equal to the attack of the last monster you faced."
		"atk_strong_neighbor":
			out["value"] = _value_bb("Attack", str(live) if live >= 0 else "—", atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Highest Neighbor ATK")
			out["body"] = "Attack equal to the attack of the strongest neighboring enemy."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"blk_keep":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s) and %s if you Bled" % [_bb(blk_c, "2"), _bb(gold, "Keep")]
			out["body"] = "Gain 2 block. If you lose HP this combat, keep this item."
		"smoke":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Abort this fight, spin again (not the same slice), and gain a random unseen item."
		"fangs":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s) then %s then %s" % [_bb(hp_c, "Take their ATK"), _bb(var_c, "Defeat"), _bb(hp_c, "Heal their HP")]
			out["body"] = "Take their hit (block still works), defeat them, then heal equal to the HP they had."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
		"mark_poison":
			out["value"] = _value_bb("Mark", "", gold)
			out["body"] = "Mark a neighbor. When you spin them, they lose 5 HP immediately."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.poison", "Can't — no neighbor you can poison.")
		"atk_neighbor", "mark_crossbow":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) to a Neighbor" % _bb(atk_c, "ATK 4")
			out["body"] = "Deal 4 Attack to a Neighboring enemy."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"atk_cleave":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) to facing and neighbors" % _bb(atk_c, "2")
			out["body"] = "Deal 2 attack to the monster you face and each neighboring monster. The same monster is only hit once."
		"atk_opposite":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) opposite if even count" % _bb(atk_c, "4")
			out["body"] = "Deal 4 attack to the monster across from you. Needs an even number of monsters."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — odd number of monsters on the wheel."
		"heal_kills":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "1"), _bb(var_c, "Defeat")]
			out["body"] = "Heal 1, plus 1 for each monster you have already defeated."
		"hook_swap":
			out["value"] = _value_bb("Swap", "", gold)
			out["body"] = "Swap a neighboring monster into this fight, then draw a random item."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"blk_siphon":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s) +2 per fight start" % _bb(blk_c, "BLK")
			out["body"] = "Each fight start: lose 1 HP. This card gains 2 block. Click it to spend that block."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no block stored yet."
		"atk_wheel":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(var_c, "Monsters left")
			out["body"] = "Attack equal to how many monsters are still on the wheel."
		"blk_from_atk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "Facing ATK")
			out["body"] = "Block equal to the facing monster's attack."
		"atk_zero":
			out["value"] = _value_bb("Attack", "0", atk_c)
			out["body"] = "The facing monster's attack becomes 0 this fight."
		"atk_drop":
			out["value"] = _value_bb("Attack", "−1 / −2 / −3", atk_c)
			out["body"] = "Click 1, 2, or 3. The facing monster's Attack drops by that much after every other formula, then stays there this fight."
		"heal_keep":
			out["value"] = _value_bb("Heal", "2", cream)
			out["equation"] = "(%s) then Keep if still missing HP" % _bb(cream, "2")
			out["body"] = "Heal 2. Keep this if you are still below 6 HP. If you are already at 6, it is used up."
		"heal_full":
			out["value"] = _value_bb("Heal", "to 6", cream)
			out["equation"] = "(%s)" % _bb(cream, "HP 6")
			out["body"] = "Heal your HP up to 6."
		"egg_hurt":
			out["value"] = _value_bb("Attack", "2", atk_c)
			out["equation"] = "(%s) to you" % _bb(atk_c, "2")
			out["body"] = str(it.get("ability", "Take 2 Attack."))
		"blk_last":
			out["value"] = _value_bb("Block", str(last_blk_gain), blk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "Last Block gained")
			out["body"] = "Block equal to the last Block you gained this dungeon."
			if fighting and last_blk_gain <= 0:
				out["warn"] = "Can't — you have not gained Block yet this dungeon."
		"quiet":
			out["value"] = _value_bb("Quiet", "", var_c)
			out["body"] = "Remove the facing monster's unique ability for the rest of this dungeon. They use their printed Attack and HP."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — they have no unique ability."
		"echo":
			out["value"] = _value_bb("Unplayable", "", gold)
			out["body"] = "Becomes a copy of the last item you used this dungeon."
			out["warn"] = "Can't — you have not used an item this dungeon."
		"atk_echo":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Last Item ATK")
			out["body"] = "Attack equal to the last item attack you used this fight."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — you have not dealt attack with an item this fight."
		"atk_spend_blk":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "BLK")
			out["body"] = "Deal Attack equal to Block you hold. Keep this item. You keep the Block."
			if fighting and blk <= 0:
				out["warn"] = "Can't — you have 0 Block."
		"atk_empty":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(var_c, "cycle")
			out["body"] = "Deal Attack 1, then 2, then 3, then 4. Every item use this dungeon advances the cycle."
		"atk_hp_gap":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s ÷ 2)" % _bb(hp_c, "your HP")
			out["body"] = "Deal Attack equal to half your HP (rounded down) and Heal that much. If they survive, Keep this item."
		"defeat_only_item":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["body"] = "If you have zero items that deal Attack, Defeat them."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and _hand_has_atk_item(int(it.get("uid", -1))):
				out["warn"] = "Can't — you are holding an Attack item."
		"chaos_reroll":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Click other items in your hand. Each becomes a random item of the same Weak, Tough, or Deadly."
			if fighting and _chaos_candidates(int(it.get("uid", -1))).is_empty():
				out["warn"] = "Can't — this is the only item in your hand."
		"skip_swing":
			out["value"] = _value_bb("Skip", "", var_c)
			out["body"] = "Skip their attack this fight. They still leave the wheel."
		"passive":
			out["value"] = _value_bb("Unplayable", "", gold)
			out["body"] = "Unplayable. If you would die, discard this and heal 3."
		_:
			out["value"] = str(view.get("kind", ""))
			out["body"] = str(it.get("ability", ""))
	if it.get("spent", false):
		out["warn"] = PLAYER_COPY.text("warn.spent", "Already used this fight.")
	if bool(it.get("petrified", false)):
		out["warn"] = "Petrify — Unplayable until your next Spin."
	var ab: String = str(it.get("ability", ""))
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			ab = str(face.get("ability", ab))
			var fex: String = str(face.get("explainer", ""))
			if fex != "":
				out["equation"] = _paint_item_text(fex, face, true)
			if ab != "" and ab != "---":
				out["body"] = _paint_item_text(ab, face, false)
			return out
	if ab != "" and ab != "---":
		out["body"] = _paint_item_text(ab, it, false)
	var ex: String = str(it.get("explainer", ""))
	if ex != "" and ex != "---":
		out["equation"] = _paint_item_text(ex, it, true)
	return out


func _monster_rule(s: Dictionary, swap_on_shift: bool = true) -> Dictionary:
	var id: String = str(s.get("card_id", ""))
	var atk_n: String = str(s.get("atk", 0))
	var hp_n: String = str(s.get("hp", 0))
	var atk_c := "#E07A7A"
	var hp_c := "#E8A0A0"
	var out := {
		"title": _title_case(str(s.get("name", "?"))),
		"value": "%s    %s" % [_value_bb("Attack", atk_n, atk_c), _value_bb("HP", hp_n, hp_c)],
		"equation": "",
		"body": "",
		"warn": "",
		"speech": "",
		"hint": "",
		"reminder": "",
	}
	var card: Dictionary = monsters_by_id.get(id, {})
	var reminder: String = str(s.get("reminder", "")).strip_edges()
	if reminder == "":
		reminder = str(card.get("reminder", "")).strip_edges()
	out["reminder"] = reminder
	var call_n: String = str(s.get("call_name", "")).strip_edges()
	if call_n == "":
		call_n = str(card.get("call_name", "")).strip_edges()
	out["call"] = call_n
	var sid: String = str(s.get("special_id", ""))
	out["call_hex"] = UX.call_hex(sid)
	if _is_silenced(s):
		out["speech"] = ""
		out["equation"] = ""
		out["reminder"] = ""
		out["hint"] = ""
		out["call"] = ""
		out["call_hex"] = ""
		return out
	if swap_on_shift and _shift_held:
		if reminder != "":
			out["equation"] = _paint_explainer(reminder, atk_c)
			out["equation_kind"] = "formula"
	elif call_n != "":
		out["equation"] = UX.call_bb(call_n, sid)
		out["equation_kind"] = "call"
	var speech: String = str(s.get("ability", "")).strip_edges()
	if speech == "" or speech == "---":
		speech = str(card.get("ability", "")).strip_edges()
	if speech == "---":
		speech = ""
	if speech != "":
		out["speech"] = _paint_explainer(speech)
	return out


func _monster_plate_look(s: Dictionary, rule: Dictionary, title_size: int = 22) -> Dictionary:
	var look: Dictionary = _monster_look(s)
	if _shift_held:
		look["hint"] = ""
	else:
		look["hint"] = str(rule.get("hint", ""))
	look["hp"] = int(s.get("hp", 0))
	look["atk"] = int(s.get("atk", 0))
	look["title_size"] = title_size
	look["title_bold"] = true
	look["call"] = str(rule.get("call", ""))
	look["call_hex"] = str(rule.get("call_hex", UX.call_hex(str(s.get("special_id", "")))))
	look["equation_kind"] = str(rule.get("equation_kind", ""))
	return look


func _refresh_gate_owner() -> void:
	if draft_gate == null or not draft_gate.visible:
		return
	if not draft_gate.has_method("show_owner"):
		return
	if pending_monster.is_empty() or str(draft_gate.card_id) == "":
		if draft_gate.has_method("hide_owner"):
			draft_gate.hide_owner()
		return
	var rule: Dictionary = _monster_rule(pending_monster)
	var look: Dictionary = _monster_plate_look(pending_monster, rule, 26)
	look["body_size"] = 17
	draft_gate.show_owner(
		str(rule.get("title", "")),
		str(rule.get("value", "")),
		str(rule.get("equation", "")),
		str(rule.get("speech", "")),
		str(rule.get("warn", "")),
		look
	)


func _sync_placement() -> void:
	var seating: bool = phase == "draft" and draft_action == "seat" and not pending_monster.is_empty()
	if placement_ui != null:
		placement_ui.visible = seating
		if seating:
			var tex: Texture2D = null
			if art != null:
				tex = art.monster_still(str(pending_monster.get("card_id", "")))
			if placement_ui.has_method("show_pending"):
				placement_ui.show_pending(pending_monster, tex)
			if draft_gate != null:
				draft_gate.visible = false
	_sync_torch()


func _sync_torch() -> void:
	if hud == null or not hud.has_method("set_torch"):
		return
	var seating: bool = phase == "draft" and draft_action == "seat"
	var hi: int = -1
	if wheel_view != null:
		hi = int(wheel_view.hover_index)
	var on: bool = seating and hi >= 0 and hi < wheel.size() and str(wheel[hi].get("kind", "")) == "empty"
	if not on:
		hud.set_torch(Vector2.ZERO, Vector2.ZERO, false)
		return
	var mouth: Vector2 = Vector2(1236, 190)
	if placement_ui != null and placement_ui.has_method("door_mouth_global"):
		mouth = placement_ui.door_mouth_global()
	var dest: Vector2 = wheel_view.slice_portrait_global(hi)
	hud.set_torch(mouth, dest, true)


func _idle_inspect() -> void:
	if inspect == null:
		return
	if in_tutorial and tut != null and tut.visible:
		inspect.hide_plate()
		_set_inspect_idle(false)
		if fight_ui:
			fight_ui.visible = false
		if placement_ui and not (phase == "draft" and draft_action == "seat"):
			placement_ui.visible = false
		if talk_ui:
			talk_ui.visible = not (draft_gate != null and draft_gate.visible and draft_gate.mode == "ask")
		return
	if talk_ui and not in_tutorial:
		talk_ui.visible = false
	if phase == "title":
		inspect.hide_plate()
		if fly_tip != null:
			fly_tip.hide_plate()
		_set_inspect_idle(false)
		return
	if phase == "draft" and draft_action == "seat":
		inspect.hide_plate()
		_set_inspect_idle(false)
		_sync_torch()
		return
	var gate_up: bool = draft_gate != null and draft_gate.visible and phase == "draft"
	if gate_up and (draft_action == "ask" or draft_action == "seat" or draft_action == "busy"):
		if _fly_card != null or not _hover_item.is_empty():
			return
		inspect.hide_plate()
		_set_inspect_idle(false)
		return
	if _fly_card != null:
		return
	if _hover_slice >= 0 and _hover_slice < wheel.size() and _hover_slice != facing_index:
		if str(wheel[_hover_slice].get("kind", "")) == "monster":
			_fill_inspect_from_slice(_hover_slice)
			return
	if fly_tip != null and fly_tip.edit_kind == "monster":
		fly_tip.hide_plate()
	inspect.hide_plate()
	inspect.top_level = false
	_set_inspect_idle(false)
	if fight_ui != null:
		fight_ui.visible = false
	if placement_ui != null and phase == "draft" and draft_action == "seat":
		placement_ui.visible = true


func _set_inspect_idle(on: bool) -> void:
	if hud != null and hud.has_method("set_idle_visible"):
		hud.set_idle_visible(on)


func _fill_inspect_from_slice(index: int) -> void:
	if index < 0 or index >= wheel.size():
		_idle_inspect()
		return
	_set_inspect_idle(false)
	if fight_ui:
		fight_ui.visible = false
	if placement_ui:
		placement_ui.visible = false
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		if inspect != null:
			inspect.hide_plate()
		if fly_tip != null:
			fly_tip.hide_plate()
		return
	var rule: Dictionary = _monster_rule(s, false)
	var body: String = str(rule.get("speech", ""))
	if body == "":
		body = str(rule.get("reminder", ""))
	var port: Texture2D = null
	if art != null:
		port = art.monster_still(str(s.get("card_id", "")))
	var look: Dictionary = _monster_plate_look(s, rule, 26)
	if inspect != null:
		inspect.hide_plate()
		inspect.top_level = false
	if fly_tip == null:
		return
	fly_tip.show_rule(str(rule["title"]), "", "", body, str(rule.get("warn", "")), port, "monster", str(s.get("card_id", "")), look)
	_pin_side_callout(fly_tip, "right")
	_sync_authoring_chrome()


func _refresh_monster_plates() -> void:
	_idle_inspect()
	_refresh_face()


func _place_fly(near: Control = null) -> void:
	if fly_tip == null or not fly_tip.visible:
		return
	var kind: String = str(fly_tip.edit_kind)
	if kind == "item":
		_pin_side_callout(fly_tip, "left")
		return
	if kind == "monster":
		_pin_side_callout(fly_tip, "right")
		return
	fly_tip.reset_size()
	var sz: Vector2 = fly_tip.get_combined_minimum_size()
	sz.x = maxf(sz.x, 280.0)
	var pos: Vector2
	if near != null and is_instance_valid(near):
		if near == _offer_card:
			pos = near.global_position + Vector2(-sz.x - 12.0, -8.0)
		else:
			pos = near.global_position + Vector2(near.size.x + 10.0, -8.0)
	else:
		pos = get_global_mouse_position() + Vector2(20.0, 16.0)
	var vp: Vector2 = get_viewport_rect().size
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - sz.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - sz.y - 8.0))
	fly_tip.global_position = pos
	fly_tip.size = sz


func _place_speech() -> void:
	if speech_box == null:
		return
	if overlay != null and overlay.visible:
		speech_box.hide_speech()
		return
	if content_ed != null and content_ed.visible:
		speech_box.hide_speech()
		return
	if roster_ed != null and roster_ed.visible:
		speech_box.hide_speech()
		return
	if script_ed != null and script_ed.visible:
		speech_box.hide_speech()
		return
	if fly_tip != null and fly_tip.visible and fly_tip.edit_kind == "item":
		speech_box.hide_speech()
		return
	if _gate_line != "" and draft_gate != null and draft_gate.visible:
		var look := {}
		if not pending_monster.is_empty():
			look = _monster_look(pending_monster)
		speech_box.present(draft_gate.mouth_global(), _gate_line, look, true, draft_gate.panel_left())
		return
	if _cube_line != "" and not _shift_held and combat_stage != null and combat_stage.visible:
		var cube_look := {}
		if facing_index >= 0 and facing_index < wheel.size():
			cube_look = _monster_look(wheel[facing_index])
		speech_box.present(combat_stage.mouth_global(), _cube_line, cube_look, true)
		return
	if not _shift_held:
		speech_box.hide_speech()
		return
	if fly_tip != null and fly_tip.visible and fly_tip.edit_kind == "item":
		speech_box.hide_speech()
		return
	var s: Dictionary = {}
	var mouth: Vector2 = Vector2.ZERO
	var hover_i: int = -1
	if wheel_view != null:
		hover_i = int(wheel_view.hover_index)
	if _fly_card != null and not pending_monster.is_empty() and fly_tip != null and fly_tip.edit_kind == "monster":
		s = pending_monster
		mouth = _fly_card.get_global_rect().position + Vector2(36, 28)
	elif hover_i >= 0 and hover_i < wheel.size() and str(wheel[hover_i].get("kind", "")) == "monster":
		s = wheel[hover_i]
		mouth = wheel_view.slice_portrait_global(hover_i)
	elif (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("kind", "")) == "monster":
		s = wheel[facing_index]
		mouth = wheel_view.slice_portrait_global(facing_index)
	if s.is_empty():
		speech_box.hide_speech()
		return
	var in_fight: bool = phase == "fighting" or phase == "slaying"
	var hover_other: bool = hover_i >= 0 and hover_i != facing_index
	if in_fight and not hover_other and combat_stage != null and combat_stage.visible:
		mouth = combat_stage.mouth_global()
	var rule: Dictionary = _monster_rule(s)
	var line: String = str(rule.get("speech", ""))
	if line == "":
		speech_box.hide_speech()
		return
	speech_box.present(mouth, line, _monster_look(s))


func _place_fight_art() -> void:
	if wheel_view == null:
		return
	var wr: Rect2 = wheel_view.get_global_rect().grow(8.0)
	var vp: Vector2 = get_viewport_rect().size
	var stack_w := 336.0
	var port_sz := Vector2(168, 128)
	var gap := 8.0
	var plaque_h := 0.0
	if face_box != null and face_box.visible:
		face_box.reset_size()
		plaque_h = face_box.get_combined_minimum_size().y
	var port_h: float = port_sz.y if combat_stage != null and combat_stage.visible else 0.0
	var total: float = port_h
	if port_h > 0.0 and plaque_h > 0.0:
		total += gap
	total += plaque_h
	var x: float = vp.x - stack_w - 32.0
	if x < wr.end.x + 12.0:
		x = wr.end.x + 12.0
	var y := 28.0
	if hotbar_box != null and hotbar_box.visible:
		var hand_top: float = hotbar_box.global_position.y
		if y + total > hand_top - 8.0:
			y = maxf(8.0, hand_top - total - 8.0)
	var bob: float = sin(float(Time.get_ticks_msec()) * 0.0032) * 3.0
	var shake := Vector2.ZERO
	if combat_stage != null and combat_stage.has_method("is_striking") and combat_stage.is_striking():
		shake = Vector2(randf_range(-5.0, 5.0), randf_range(-3.0, 3.0))
	if combat_stage != null and combat_stage.visible:
		combat_stage.size = port_sz
		combat_stage.global_position = Vector2(x + (stack_w - port_sz.x) * 0.5, y + bob) + shake
		y += port_sz.y + gap
	if face_box != null and face_box.visible:
		var psz: Vector2 = face_box.get_combined_minimum_size()
		psz.x = stack_w
		face_box.size = psz
		face_box.global_position = Vector2(x, y + bob * 0.5) + shake


func _speech_gutter() -> Rect2:
	if wheel_view == null:
		return Rect2()
	var wr: Rect2 = wheel_view.get_global_rect()
	var left: float = wr.end.x + 10.0
	var right: float = get_viewport_rect().size.x - 12.0
	if inspect != null:
		right = minf(right, inspect.global_position.x - 12.0)
	var top: float = wr.position.y
	var bottom: float = wr.end.y - 8.0
	if btn_spin != null and btn_spin.visible:
		bottom = minf(bottom, btn_spin.global_position.y - 12.0)
	if hotbar_box != null and hotbar_box.visible:
		bottom = minf(bottom, hotbar_box.global_position.y - 12.0)
	if combat_stage != null and combat_stage.visible:
		bottom = minf(bottom, combat_stage.global_position.y - 10.0)
	if face_box != null and face_box.visible and (combat_stage == null or not combat_stage.visible):
		bottom = minf(bottom, face_box.global_position.y - 10.0)
	var w: float = maxf(right - left, 168.0)
	var h: float = maxf(bottom - top, 72.0)
	return Rect2(left, top, w, h)


func _on_done_hover(on: bool) -> void:
	if not on or phase != "fighting":
		_ghost_hp = -1
		_refresh_hearts()
		return
	if sfx:
		sfx.hover()
	_ghost_hp = maxi(0, hp - _incoming_hit())
	_refresh_hearts()


func _refresh_hearts() -> void:
	if wheel_view:
		wheel_view.set_vitals(hp, HP_MAX, _ghost_hp, blk, _ghost_blk)
	if hearts_box == null:
		return
	hearts_box.visible = false
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		var live: bool = hi < hp
		var lost_soon: bool = _ghost_hp >= 0 and hi >= _ghost_hp and hi < hp
		if live:
			if lost_soon:
				tr.modulate = Color("e07a7a")
			elif hp <= 2:
				tr.modulate = Color("f0b0a8")
			else:
				tr.modulate = Color.WHITE
		else:
			tr.modulate = Color(1, 1, 1, 0.18)
		hi += 1
	_hp_shown = hp


func _punch_heart(tr: TextureRect) -> void:
	tr.pivot_offset = tr.size * 0.5
	var tw := create_tween()
	tw.tween_property(tr, "scale", Vector2(1.35, 1.35), 0.08)
	tw.tween_property(tr, "scale", Vector2.ONE, 0.16)
	tw.parallel().tween_property(tr, "modulate", Color(1, 1, 1, 0.18), 0.2)


func _glow_hearts_heal() -> void:
	if hearts_box == null:
		return
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		if hi < hp:
			tr.pivot_offset = tr.size * 0.5
			tr.modulate = Color("8fd18f")
			var tw := create_tween()
			tw.tween_property(tr, "scale", Vector2(1.22, 1.22), 0.08)
			tw.tween_property(tr, "scale", Vector2.ONE, 0.16)
			tw.parallel().tween_property(tr, "modulate", Color.WHITE, 0.22)
		hi += 1


func _tint_hearts_bleed() -> void:
	if hearts_box == null:
		return
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		if hi < hp:
			tr.modulate = Color("9b4dca")
			var tw := create_tween()
			tw.tween_property(tr, "modulate", Color.WHITE, 0.35)
		elif hi == hp:
			tr.modulate = Color("5c1a6a")
			var tw2 := create_tween()
			tw2.tween_property(tr, "modulate", Color(1, 1, 1, 0.18), 0.35)
		hi += 1


func _punch_label(lab: Label) -> void:
	if lab == null:
		return
	lab.pivot_offset = lab.size * 0.5
	var tw := create_tween()
	tw.tween_property(lab, "scale", Vector2(1.18, 1.18), 0.08)
	tw.tween_property(lab, "scale", Vector2.ONE, 0.14)


func _flash_screen(col: Color, a: float = 0.3) -> void:
	if fx_flash == null:
		return
	if col.r > 0.55 and col.g < 0.45 and col.b < 0.45:
		return
	fx_flash.color = col
	fx_flash.modulate.a = a
	var tw := create_tween()
	tw.tween_property(fx_flash, "modulate:a", 0.0, 0.32)


func _num_color(kind: String) -> Color:
	if kind == "BLK":
		return Color("6bb3d9")
	if kind == "ATK":
		return Color("e06c75")
	if kind == "HEAL":
		return Color("8fd18f")
	if kind == "DEFEAT" or kind == "FANGS":
		return Color("f0e6d8")
	return Color("f0e6d8")


func _kind_mark(kind: String) -> Texture2D:
	if kind == "BLK":
		return tex_shield
	if kind == "HEAL":
		return tex_heart
	if kind == "DEFEAT" or kind == "FANGS":
		var skull: Texture2D = load("res://assets/icons/skull.svg") as Texture2D
		if skull != null:
			return skull
		if tex_by_item.has("fangs"):
			return tex_by_item["fangs"]
		if art != null and art.tile("skull") != null:
			return art.tile("skull")
		return tex_heart
	if art != null and art.vfx.get("star", null) != null:
		return art.vfx["star"]
	return tex_sword


func _sync_hotbar_formulas() -> void:
	if hotbar_box == null:
		return
	for c in hotbar_box.get_children():
		if not c.has_method("show_formula"):
			continue
		var it: Dictionary = _find_item(int(c.uid))
		if it.is_empty():
			continue
		var rule: Dictionary = _item_rule(it)
		c.set_formula(str(rule.get("equation", "")))
		var ab: String = str(it.get("ability", ""))
		if ab != "" and ab != "---" and c.has_method("set_ability_bb"):
			c.set_ability_bb(_paint_item_text(ab, it, false))
		c.show_formula(_shift_held)
	_refresh_offer_card()
	if choice_box == null:
		return
	for c in choice_box.get_children():
		if not c.has_method("show_formula"):
			continue
		c.show_formula(_shift_held)


func _layout_play_field() -> void:
	if play_field == null or wheel_view == null:
		return
	if trophy:
		trophy.visible = false
	if tray != null and tray.visible:
		var tmin: Vector2 = tray.get_combined_minimum_size()
		tray.position = Vector2(32.0, 68.0)
		tray.size = tmin
	var vp: Vector2 = play_field.size if play_field.size.x > 8.0 else Vector2(1680, 1040)
	var ws := 686.0
	var cx: float = floor(vp.x * 0.5)
	var cy := 350.0
	wheel_view.custom_minimum_size = Vector2(ws, ws)
	wheel_view.position = Vector2(cx - ws * 0.5, cy - ws * 0.5)
	wheel_view.size = Vector2(ws, ws)
	if hud != null:
		if hud.has_method("layout_around_wheel"):
			hud.layout_around_wheel()
		if hud.has_method("layout_hand"):
			hud.layout_hand()


func _set_cue(t: String) -> void:
	_cue_shown = t
	if hud != null and hud.has_method("set_cue"):
		hud.set_cue(t)
		hud.set_cue_dim(phase == "spinning")
	elif cue_label != null:
		cue_label.text = t
		cue_label.visible = t != ""


func _refresh_face() -> void:
	var show: bool = (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size()
	if fight_ui:
		fight_ui.visible = false
	if not show:
		if face_box:
			face_box.hide_plate()
		if combat_stage:
			combat_stage.visible = false
		return
	var m: Dictionary = wheel[facing_index]
	var tex: Texture2D = null
	if art != null:
		tex = art.monster_still(str(m.get("card_id", "")))
	if combat_stage:
		if str(combat_stage.card_id) != str(m.get("card_id", "")) or not combat_stage.visible:
			combat_stage.show_monster(str(m.get("card_id", "")))
		combat_stage.visible = true
	if face_box:
		var rule: Dictionary = _monster_rule(m, false)
		var explainer: String = str(rule.get("speech", "")).strip_edges()
		if explainer == "":
			explainer = str(rule.get("reminder", "")).strip_edges()
		face_box.show_rule(
			str(rule.get("title", m.get("name", "?"))),
			"",
			"",
			explainer,
			str(rule.get("warn", "")),
			tex,
			"monster",
			str(m.get("card_id", "")),
			_monster_plate_look(m, rule)
		)
		face_box.visible = true
	if placement_ui:
		placement_ui.visible = false
	var atk_s: String = str(m.get("atk", 0))
	var hp_s: String = str(m.get("hp", 0))
	if face_box != null and ((atk_s != _face_atk_shown and _face_atk_shown != "") or (hp_s != _face_hp_shown and _face_hp_shown != "")):
		var tw := create_tween()
		tw.tween_property(face_box, "modulate", Color(1.15, 1.08, 0.95, 1), 0.08)
		tw.tween_property(face_box, "modulate", Color.WHITE, 0.12)
	_face_atk_shown = atk_s
	_face_hp_shown = hp_s
	_place_fight_art()


func _refresh() -> void:
	_sync_wheel_stats()
	_refresh_hearts()
	_refresh_blk(true)
	_refresh_face()
	_idle_inspect()
	if trophy:
		trophy.visible = false
		if mobs_defeated != _slain_shown and _slain_shown >= 0:
			trophy.set_count(mobs_defeated, mobs_defeated > _slain_shown)
			if sfx and mobs_defeated > _slain_shown:
				sfx.play("bong", -8.0, 0.85)
				sfx.play("pluck", -10.0, 1.35)
		else:
			trophy.set_count(mobs_defeated, false)
		_slain_shown = mobs_defeated

	var mode: String = "none"
	if not pending_mark.is_empty() and phase == "fighting":
		mode = "mark"
		var mk: String = str(pending_mark.get("kind", ""))
		for i in wheel.size():
			wheel[i]["markable"] = _can_mark(i, mk)
	else:
		for i2 in wheel.size():
			wheel[i2]["markable"] = false
		if (phase == "draft" and draft_action == "seat") or phase == "devtest":
			mode = "place"
	if wheel_view:
		wheel_view.set_slices(wheel, facing_index, mode)
		wheel_view.draft_glow = phase == "draft"

	_set_cue(_cue_text())
	if hud != null and hud.has_method("set_column_kind"):
		if phase == "victory":
			hud.set_column_kind("victory")
		elif phase == "defeat":
			hud.set_column_kind("defeat")
		elif phase == "devtest":
			hud.set_column_kind("devtest")
		else:
			hud.set_column_kind("draft")
	if hud != null and hud.has_method("set_side_column"):
		var need_col: bool = phase == "draft" or phase == "victory" or phase == "defeat" or phase == "devtest" or in_tutorial
		hud.set_side_column(need_col)
	_refresh_gate_item()
	_sync_placement()
	if wheel_view != null:
		wheel_view.seat_hover_on = phase == "ready" or (phase == "draft" and draft_action == "seat")
		wheel_view.dim_nonfacing = phase == "fighting" or phase == "slaying"
	_rebuild_tray()
	_sync_hotbar()
	_rebuild_choice()
	_sync_buttons()
	_sync_overlay()
	_sync_dev_panel()
	_sync_authoring_chrome()
	_place_speech()


func _cue_text() -> String:
	if in_tutorial:
		return ""
	if draft_gate != null and draft_gate.visible and phase == "draft" and draft_action == "ask":
		return ""
	match phase:
		"draft":
			if _mill_beat == "watch":
				return PLAYER_COPY.text("cue.starters", "Starters take north, east, south, and west.")
			if _mill_beat == "force":
				return PLAYER_COPY.text("cue.force", "Out of time")
			if draft_action == "ask":
				if refusals_left <= 0:
					return PLAYER_COPY.text("cue.steal", "Out of time")
				return PLAYER_COPY.text("cue.ask", "Take it or leave it?")
			if draft_action == "seat":
				return PLAYER_COPY.text("cue.seat", "A monster approaches. Select their location.")
			if draft_action == "busy":
				return ""
			return PLAYER_COPY.text("cue.filling", "The nest is filling.")
		"devtest":
			return PLAYER_COPY.text("cue.devtest", "Click a monster to seat it, an item to add it to your hand. Play when you have at least one monster.")
		"rest":
			return PLAYER_COPY.fill("title.rest_sub", {"n": dungeons_cleared}, "Dungeon %s is behind you." % dungeons_cleared)
		"ready":
			return PLAYER_COPY.need("cue.ready")
		"fighting":
			if not pending_feed.is_empty():
				return "Feed the cube one of those items."
			if not pending_chaos.is_empty():
				var need_n: int = int(pending_chaos.get("need", 1))
				if need_n <= 1:
					return "Click the other item to reroll it."
				return "Click two other items to reroll them."
			if not pending_mark.is_empty():
				return PLAYER_COPY.text("cue.mark", "Click a neighboring enemy")
			if facing_index >= 0 and _wick_waiting(facing_index):
				return "They are at 0 HP. Click Done."
			return ""
		"slaying":
			return ""
		"spinning":
			return PLAYER_COPY.need("cue.ready")
		_:
			return ""


func _sync_buttons() -> void:
	var busy: bool = phase == "spinning" or phase == "slaying" or (phase == "draft" and draft_action == "busy") or _wheel_busy() or _adventure_busy
	var enemy_up: bool = phase == "fighting" and facing_index >= 0 and (int(wheel[facing_index].get("hp", 0)) > 0 or _wick_waiting(facing_index))
	btn_spin.disabled = busy or phase != "ready"
	btn_done.disabled = busy or not enemy_up or not pending_feed.is_empty() or not pending_chaos.is_empty()
	btn_start.disabled = busy
	btn_place.visible = false
	btn_bribe.visible = false
	btn_spin.visible = phase == "ready" or phase == "spinning"
	btn_done.visible = enemy_up
	if phase == "devtest":
		btn_spin.visible = false
		btn_done.visible = false
	btn_start.visible = false
	btn_start.modulate = Color.WHITE
	if in_tutorial:
		btn_start.disabled = true
		btn_spin.disabled = busy or phase != "ready" or tut == null or tut.wait != "spin"
		btn_done.disabled = busy or not enemy_up or tut == null or not _tut_can_done()
	if hud != null and hud.has_method("set_spin_live"):
		hud.set_spin_live(btn_spin.visible and not btn_spin.disabled)
	if enemy_up:
		var hit: int = _incoming_hit()
		var lab: String = PLAYER_COPY.fill("combat.take_hit", {"n": hit}, "Take %s" % hit) if hit > 0 else PLAYER_COPY.text("combat.safe", "Safe")
		btn_done.text = lab
		if fight_ui != null and fight_ui.has_method("set_resolve"):
			fight_ui.set_resolve(lab, hit > 0, btn_done.disabled)


func _sync_overlay() -> void:
	if in_tutorial and tut != null and tut.visible:
		overlay.visible = false
		if title_ui:
			title_ui.visible = false
		if hud != null:
			hud.visible = true
			if hud.hotbar_box:
				hud.hotbar_box.visible = true
			if hud.has_method("layout_hand"):
				hud.layout_hand()
		return
	var on_title: bool = phase == "title"
	var on_win: bool = phase == "victory"
	var on_lose: bool = phase == "defeat"
	if title_ui:
		title_ui.visible = on_title
		if on_title:
			title_ui.grab_play()
	if victory_ui:
		victory_ui.visible = on_win
		if on_win:
			victory_ui.refresh_copy()
			var loot_n: int = 0
			for it in hotbar:
				if typeof(it) == TYPE_DICTIONARY:
					loot_n += 1
			if victory_ui.has_method("play_win_intro"):
				victory_ui.play_win_intro(loot_n)
			victory_ui.grab_again()
		elif victory_ui.has_method("reset_win_intro"):
			victory_ui.reset_win_intro()
	if defeat_ui:
		defeat_ui.visible = on_lose
		if on_lose:
			defeat_ui.refresh_copy()
			defeat_ui.grab_again()
	if fight_ui and (on_win or on_lose or on_title):
		fight_ui.visible = false
	if inspect and (on_win or on_lose or on_title):
		inspect.hide_plate()
	if draft_gate and (on_win or on_lose or on_title):
		draft_gate.hide_gate()
	if talk_ui and (on_win or on_lose or on_title):
		talk_ui.visible = false
	if wheel_view:
		if on_win:
			wheel_view.modulate = Color(1, 1, 1, 0.5)
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(true)
		elif on_lose:
			wheel_view.modulate = Color(Color("5A5048"), 0.22)
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(false)
		else:
			wheel_view.modulate = Color.WHITE
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(false)
	if hud != null:
		if hud.has_method("set_column_kind"):
			if on_win:
				hud.set_column_kind("victory")
			elif on_lose:
				hud.set_column_kind("defeat")
			elif phase == "devtest":
				hud.set_column_kind("devtest")
			else:
				hud.set_column_kind("draft")
		if hud.has_method("set_pointer_dim"):
			hud.set_pointer_dim("defeat" if on_lose else "")
		if hud.has_method("set_ghost_hand"):
			hud.set_ghost_hand(on_lose)
		if hud.hotbar_box:
			hud.hotbar_box.visible = not on_win and not on_lose and not (phase == "title")
		if on_win and hud.has_method("show_loot"):
			var loot: Array = []
			for it in hotbar:
				if typeof(it) != TYPE_DICTIONARY:
					continue
				var tex: Texture2D = null
				if art != null:
					tex = art.item_tex(str(it.get("card_id", "")))
				if tex != null:
					loot.append(tex)
			hud.show_loot(loot)
		elif hud.has_method("hide_loot"):
			hud.hide_loot()
	var show: bool = phase == "rest"
	overlay.visible = show
	if hud != null:
		hud.visible = not on_title
	if overlay_dive:
		overlay_dive.visible = on_title
	if overlay_tut:
		overlay_tut.visible = on_title
	if overlay_adventure:
		overlay_adventure.visible = on_title
	if overlay_dev:
		overlay_dev.visible = on_title and _authoring()
	if overlay_tools_row:
		overlay_tools_row.visible = on_title and _authoring()
	if overlay_rest_row:
		overlay_rest_row.visible = phase == "rest"
	if overlay_btn:
		overlay_btn.visible = phase != "rest"
	if overlay_score:
		overlay_score.visible = adventure and (phase == "victory" or phase == "defeat")
		if overlay_score.visible:
			overlay_score.text = PLAYER_COPY.fill("title.dungeons_cleared", {"n": dungeons_cleared}, "Dungeons cleared: %s" % dungeons_cleared)
	if phase == "title":
		overlay_title.text = PLAYER_COPY.text("title.overlay", "Swipe")
		overlay_sub.text = PLAYER_COPY.text("title.sub", "You just couldn't keep your grubby hands off their loot, could ya?")
		overlay_btn.text = PLAYER_COPY.text("title.begin", "Begin")
	elif phase == "rest":
		overlay_title.text = PLAYER_COPY.text("title.rest", "Another hall")
		overlay_sub.text = PLAYER_COPY.fill("title.rest_sub", {"n": dungeons_cleared}, "Dungeon %s is behind you. Leftover cards stay. Heal to full." % dungeons_cleared)
	elif phase == "victory":
		if adventure:
			overlay_title.text = PLAYER_COPY.text("title.adventure_win", "Victory")
			overlay_sub.text = ""
		else:
			overlay_title.text = PLAYER_COPY.text("title.win", "Kept it")
			overlay_sub.text = PLAYER_COPY.text("title.win_sub", "The pile is yours.")
		overlay_btn.text = PLAYER_COPY.text("title.again", "Again")
	elif phase == "defeat":
		overlay_title.text = PLAYER_COPY.text("title.lose", "Caught")
		if adventure:
			overlay_sub.text = ""
		else:
			overlay_sub.text = PLAYER_COPY.text("title.lose_sub", "They took it all back.")
		overlay_btn.text = PLAYER_COPY.text("title.again", "Again")


func _rebuild_tray() -> void:
	_clear_box(tray)
	tray.visible = false
	call_deferred("_layout_play_field")


func _monster_chip(s: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(220, 118)
	var look: Dictionary = _monster_look(s)
	var sb := StyleBoxFlat.new()
	sb.bg_color = look.get("fill", Color("241c18"))
	sb.border_color = look.get("metal", Color("c4a574"))
	var bw: int = 3
	var tier: int = int(look.get("tier", 1))
	if tier == 2:
		bw = 4
	elif tier >= 3:
		bw = 5
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(4 if tier >= 3 else (8 if tier == 2 else 12))
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	p.add_child(row)
	var ic := TextureRect.new()
	ic.texture = tex_by_monster.get(str(s.get("card_id", "")), null)
	if art != null:
		var port: Texture2D = art.monster_still(str(s.get("card_id", "")))
		if port != null:
			ic.texture = port
	ic.custom_minimum_size = Vector2(36, 36)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(ic)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	row.add_child(col)
	var n := Label.new()
	n.text = _title_case(str(s.get("name", "?")))
	UiPalette.apply_name(n, Color("f0e6d8"), UiPalette.SIZE_NAME)
	col.add_child(n)
	var stats := Label.new()
	stats.text = "%s / %s" % [s.get("atk", 0), s.get("hp", 0)]
	UiPalette.apply_number(stats, Color("ffffff"), UiPalette.SIZE_NUMBER)
	col.add_child(stats)
	var spec := Label.new()
	var chip_rule: Dictionary = _monster_rule(s)
	var st: String = str(chip_rule.get("reminder", ""))
	spec.text = st if st != "" else "No special"
	spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiPalette.apply_body(spec, Color("c9b9a8"), UiPalette.SIZE_BODY)
	spec.custom_minimum_size = Vector2(160, 0)
	col.add_child(spec)
	p.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_open_content_editor("monster", str(s.get("card_id", "")))
	)
	p.mouse_entered.connect(func() -> void:
		if fly_tip == null:
			return
		_fly_card = p
		var rule: Dictionary = _monster_rule(s)
		fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), "", str(rule.get("warn", "")), null, "monster", str(s.get("card_id", "")), _monster_plate_look(s, rule))
		_place_fly(p)
	)
	p.mouse_exited.connect(_on_item_unhovered)
	return p


func _sync_hotbar() -> void:
	var sig := PackedStringArray()
	for it in hotbar:
		var echo_id: String = ""
		if typeof(it.get("echo_copy", null)) == TYPE_DICTIONARY:
			echo_id = str((it["echo_copy"] as Dictionary).get("card_id", ""))
		sig.append("%s:%s:%s:%s" % [it.get("uid", 0), it.get("card_id", ""), echo_id, it.get("petrified", false)])
	var joined: String = ",".join(sig)
	if joined != _hotbar_sig:
		_hotbar_sig = joined
		for c in hotbar_box.get_children():
			hotbar_box.remove_child(c)
			c.queue_free()
		for it in hotbar:
			hotbar_box.add_child(_spawn_item_card(it, true))
	var n: int = hotbar_box.get_child_count()
	for c in hotbar_box.get_children():
		if c.has_method("set_compact"):
			c.set_compact(n >= 8)
	for c in hotbar_box.get_children():
		var card = c
		if not card.has_method("set_live"):
			continue
		var it: Dictionary = _find_item(int(card.uid))
		if it.is_empty():
			continue
		var view: Dictionary = _item_view(it)
		var dim: bool = phase == "fighting" and not bool(view["can_use"])
		card.spent = bool(it.get("spent", false))
		if card.has_method("set_kind"):
			card.set_kind(_item_display_kind(it))
		card.set_palette(view["fill"], view["rim"], _tier_of(it))
		card.set_live(str(view["number"]), str(view["note"]), not dim)
		if card.has_method("set_loss_icon"):
			card.set_loss_icon(tex_heart if bool(view.get("loss_icon", false)) else null)
		if card.has_method("set_playable"):
			card.set_playable(phase == "fighting" and bool(view["can_use"]) and not bool(it.get("spent", false)) and not bool(it.get("petrified", false)))
		if card.has_method("set_petrified"):
			card.set_petrified(bool(it.get("petrified", false)))
		if phase == "spinning":
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if card.has_method("set_playable"):
				card.set_playable(false)
		else:
			card.mouse_filter = Control.MOUSE_FILTER_STOP
	_sync_hotbar_formulas()
	if hud != null and hud.has_method("layout_hand"):
		hud.layout_hand()


func _spawn_item_card(it: Dictionary, usable: bool) -> PanelContainer:
	var view: Dictionary = _item_view(it)
	var card = HAND_CARD_SCN.instantiate()
	var show_id: String = str(it.get("card_id", ""))
	var show_name: String = str(it.get("name", "?"))
	if show_id == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			show_id = str(face.get("card_id", show_id))
			show_name = str(face.get("name", show_name))
	var icon: Texture2D = tex_by_item.get(show_id, tex_sword)
	if art != null:
		var pix: Texture2D = art.item_tex(show_id)
		if pix != null:
			icon = pix
	var k: String = _item_display_kind(it)
	card.setup(
		int(it.get("uid", 0)),
		str(it.get("card_id", "")),
		str(view["number"]),
		icon,
		view["fill"],
		view["rim"],
		_title_case(show_name),
		_num_color(k),
		k,
		_kind_mark(k)
	)
	if card.has_method("set_echo_mark") and str(it.get("card_id", "")) == "echo_bell" and art != null:
		card.set_echo_mark(art.item_tex("echo_bell"))
	if card.has_method("set_petrified"):
		card.set_petrified(bool(it.get("petrified", false)))
	card.set_palette(view["fill"], view["rim"], _tier_of(it))
	var rule: Dictionary = _item_rule(it)
	card.set_formula(str(rule.get("equation", "")))
	var dim: bool = phase == "fighting" and not bool(view.get("can_use", true))
	card.set_live(str(view["number"]), str(view.get("note", "")), not dim)
	if card.has_method("set_loss_icon"):
		card.set_loss_icon(tex_heart if bool(view.get("loss_icon", false)) else null)
	var ab: String = str(it.get("ability", ""))
	if ab != "" and ab != "---":
		card.set_ability_bb(_paint_item_text(ab, it, false))
	card.show_formula(_shift_held)
	card.hovered.connect(func() -> void:
		_on_item_hovered(it, card)
	)
	card.unhovered.connect(_on_item_unhovered)
	if _authoring():
		card.edit_wanted.connect(_open_content_editor.bind("item", str(it.get("card_id", ""))))
	if usable:
		var uid: int = int(it["uid"])
		# Bind on the live Main instance so game_state.gd's compile stub
		# cannot swallow the click. fight_flow._use_item is the real one.
		card.picked.connect(func() -> void:
			await _use_item(uid)
		)
	return card


func _refresh_gate_item() -> void:
	if draft_gate == null or not draft_gate.visible:
		return
	if phase != "draft" or draft_action != "ask":
		return
	if pending_item.is_empty():
		return
	if not draft_gate.has_method("show_item_callout"):
		return
	var rule: Dictionary = _item_rule(pending_item)
	var body: String = _item_inspect_body(pending_item, rule)
	var look: Dictionary = _item_inspect_look(pending_item)
	var port: Texture2D = null
	if has_method("_offer_tex"):
		port = _offer_tex()
	elif art != null:
		port = art.item_tex(str(pending_item.get("card_id", "")))
	draft_gate.show_item_callout(str(rule.get("title", pending_item.get("name", ""))), body, look, port)


func _on_gate_item_hovered() -> void:
	if pending_item.is_empty():
		return
	if draft_gate != null and draft_gate.has_method("show_item_callout"):
		return
	var host: Control = null
	if draft_gate != null and draft_gate.has_method("relic_host"):
		host = draft_gate.relic_host()
	_on_item_hovered(pending_item, host)


func _on_item_hovered(it: Dictionary, card: Control = null) -> void:
	_fly_card = card
	_hover_item = it
	if sfx:
		sfx.hover()
	if phase != "title":
		_show_item_inspect(it)
	_apply_preview(_preview_from_item(it))
	_refresh_blk(false)
	if in_tutorial and tut != null and tut.wait == "hover_item":
		_inspect_item(it, true)
	_tutorial_on_item_hover(str(it.get("card_id", "")))


func _on_item_unhovered() -> void:
	_fly_card = null
	_hover_item = {}
	_ghost_blk = -1
	_apply_preview({})
	if fly_tip:
		fly_tip.hide_plate()
	_idle_inspect()
	_sync_authoring_chrome()


func _rebuild_choice() -> void:
	_clear_box(choice_box)
	if not pending_feed.is_empty():
		for uid in pending_feed.get("uids", []):
			var it: Dictionary = _find_item(int(uid))
			if it.is_empty():
				continue
			var lab: String = "Feed  %s" % _title_case(str(it.get("name", "?")))
			var ob: Button = _pill(lab, Color("3a1c14"), Color("e8c36a"), _feed_cube.bind(int(uid)))
			choice_box.add_child(ob)
		return
	if pending_choice.is_empty():
		return
	for opt in pending_choice.get("options", []):
		var lab: String = str(opt.get("label", "?"))
		var oid: String = str(opt.get("id", ""))
		if oid == "throw":
			lab = PLAYER_COPY.text("combat.knife_throw", lab)
		elif oid == "nick":
			lab = PLAYER_COPY.text("combat.knife_nick", lab)
		var ob: Button = _pill(lab, Color("3a3220"), Color("e8c36a"), _choose_option.bind(opt))
		choice_box.add_child(ob)
