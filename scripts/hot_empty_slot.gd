extends Control
## Empty challenge-hand seat. Pixel-art socket (9-slice) with a dim empty-pouch mark so the 5x2 grid still reads.

const CARD_W := 118.0
const CARD_H := 120.0
const SOCKET := preload("res://assets/ui/slot/hot_slot_empty_9.png")
const POUCH := preload("res://assets/ui/slot/hot_slot_pouch.png")
## 5 native px at 4x on each side of the 16x16 source.
const MARGIN := 20.0

var _sb: StyleBoxTexture


func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sb = StyleBoxTexture.new()
	_sb.texture = SOCKET
	_sb.texture_margin_left = MARGIN
	_sb.texture_margin_top = MARGIN
	_sb.texture_margin_right = MARGIN
	_sb.texture_margin_bottom = MARGIN
	_sb.draw_center = true
	resized.connect(queue_redraw)


func _draw() -> void:
	var r := Rect2(Vector2(5, 5), size - Vector2(10, 10))
	if _sb == null or r.size.x < MARGIN * 2.0 or r.size.y < MARGIN * 2.0:
		return
	draw_style_box(_sb, r)
	var ps: Vector2 = POUCH.get_size()
	if r.size.x >= ps.x + MARGIN * 2.0 and r.size.y >= ps.y + MARGIN * 2.0:
		var at: Vector2 = (r.position + (r.size - ps) * 0.5).floor()
		draw_texture(POUCH, at)
