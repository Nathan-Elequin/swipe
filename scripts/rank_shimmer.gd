extends RefCounted
class_name RankShimmer
## Shared Weak / Tough / Deadly glint. Clock is seconds of Engine time.

const SHADER := preload("res://shaders/rank_shimmer.gdshader")

static var shown: bool = true


static func shine(tier: int) -> Color:
	if tier >= 3:
		return Color("ffe6a8")
	if tier == 2:
		return Color("f4f7fb")
	return Color("d4894e")


static func sweep_s(tier: int) -> float:
	if tier >= 3:
		return 0.50
	if tier == 2:
		return 0.70
	return 0.90


static func rest_s(tier: int) -> float:
	if tier >= 3:
		return 1.6
	if tier == 2:
		return 2.6
	return 4.0


static func phase_of(uid: int, tier: int) -> float:
	var rest: float = rest_s(tier)
	var span: int = maxi(1, int(rest * 1000.0))
	return float(absi(uid) % span) / 1000.0


static func make_mat(tier: int, uid: int = 0, px: Vector2 = Vector2(118, 120)) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	apply(mat, tier, uid, 0.0, 0.0, 0.0, px)
	return mat


static func apply(mat: ShaderMaterial, tier: int, uid: int, desat: float, armed: float, clock: float, px: Vector2 = Vector2(118, 120)) -> void:
	if mat == null:
		return
	mat.set_shader_parameter("shine_col", shine(tier))
	mat.set_shader_parameter("speed", sweep_s(tier))
	mat.set_shader_parameter("rest", rest_s(tier))
	mat.set_shader_parameter("phase", phase_of(uid, tier))
	mat.set_shader_parameter("desat", desat)
	mat.set_shader_parameter("armed", armed)
	mat.set_shader_parameter("clock", clock)
	mat.set_shader_parameter("card_px", px)
	mat.set_shader_parameter("amount", 0.42 if shown else 0.0)
