extends Label
## Journey A — quiet in-run banked / provisional summary (not a side ledger).
## Pattern + text; mouse-ignore. Spin owns final wording (placeholder until authored).


const PLAYER_COPY := preload("res://scripts/player_copy.gd")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	autowrap_mode = TextServer.AUTOWRAP_OFF
	add_theme_font_size_override("font_size", 16)
	add_theme_color_override("font_color", Color("c4b48a"))
	visible = false
	text = ""


## `summary` from CollectionJourney.quiet_run_summary.
func apply_summary(summary: Dictionary, show: bool) -> void:
	if not show or summary.is_empty():
		visible = false
		text = ""
		return
	var banked: int = int(summary.get("banked", 0))
	var quota: int = int(summary.get("quota", 5))
	var prov: int = int(summary.get("provisional_count", 0))
	var pool_name := str(summary.get("focus_pool", ""))
	## COPY GAP — Spin: run.collection.quiet_summary
	var line: String = PLAYER_COPY.fill(
		"run.collection.quiet_summary",
		{
			"pool": pool_name,
			"banked": str(banked),
			"quota": str(quota),
			"provisional": str(prov),
		},
		"[Spin copy: {pool} banked {banked}/{quota} · held new {provisional}]"
	)
	if bool(summary.get("would_cross_on_bank", false)):
		## Emphasize risk without inventing a modal — append existing gate cue intent.
		line = PLAYER_COPY.fill(
			"run.collection.quiet_summary_threshold",
			{
				"line": line,
			},
			"{line} · [Spin copy: banks home to open route]"
		)
	text = line
	visible = text.strip_edges() != ""
