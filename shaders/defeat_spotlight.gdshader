shader_type canvas_item;

/// Soft warm cone + floor pool for the defeat blackout.
/// UV: (0,0) top-left → (1,1) bottom-right of the full viewport rect.

uniform vec4 warm : source_color = vec4(1.0, 0.925, 0.745, 1.0);
uniform float cone_strength : hint_range(0.0, 1.0) = 0.22;
uniform float pool_strength : hint_range(0.0, 1.0) = 0.34;
uniform float soft : hint_range(0.01, 0.5) = 0.12;
uniform float apex_y : hint_range(-0.2, 0.4) = -0.02;
uniform float floor_y : hint_range(0.5, 1.2) = 0.78;
uniform float apex_half : hint_range(0.01, 0.2) = 0.06;
uniform float floor_half : hint_range(0.1, 0.6) = 0.32;
uniform float pool_rx : hint_range(0.05, 0.6) = 0.18;
uniform float pool_ry : hint_range(0.02, 0.25) = 0.055;

void fragment() {
	vec2 uv = UV;
	float t = clamp((uv.y - apex_y) / max(0.001, floor_y - apex_y), 0.0, 1.0);
	float half_w = mix(apex_half, floor_half, t);
	float dx = abs(uv.x - 0.5);
	// Soft edge of the cone walls (feathered, not hard clip).
	float wall = 1.0 - smoothstep(half_w - soft, half_w + soft * 0.55, dx);
	float along = smoothstep(apex_y - 0.02, apex_y + 0.08, uv.y)
		* (1.0 - smoothstep(floor_y + 0.02, floor_y + 0.18, uv.y));
	float cone = wall * along * cone_strength;

	// Soft elliptical pool on the floor under Sprout.
	vec2 p = (uv - vec2(0.5, floor_y)) / vec2(max(0.001, pool_rx), max(0.001, pool_ry));
	float pool = (1.0 - smoothstep(0.55, 1.15, length(p))) * pool_strength;

	float a = clamp(cone + pool, 0.0, 1.0);
	COLOR = vec4(warm.rgb, a * warm.a);
}
