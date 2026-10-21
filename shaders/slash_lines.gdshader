shader_type canvas_item;

/// Speed lines along the band axis, plus a split fade for slash-out.
uniform float speed : hint_range(0.0, 8.0) = 2.2;
uniform float split : hint_range(0.0, 1.0) = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 fill_color : source_color = vec4(0.039, 0.027, 0.024, 0.92);
uniform vec4 line_color : source_color = vec4(0.94, 0.90, 0.82, 0.70);
uniform float line_count : hint_range(20.0, 120.0) = 78.0;

void fragment() {
	float scroll = TIME * speed;
	float stripe = fract(UV.x * line_count - scroll);
	float line = smoothstep(0.0, 0.02, stripe) * (1.0 - smoothstep(0.02, 0.07, stripe));
	float stripe2 = fract(UV.x * (line_count * 0.62) - scroll * 1.4 + 0.27);
	float line2 = smoothstep(0.0, 0.015, stripe2) * (1.0 - smoothstep(0.015, 0.05, stripe2));
	float stripe3 = fract(UV.x * (line_count * 1.35) - scroll * 2.1 + 0.11);
	float line3 = smoothstep(0.0, 0.01, stripe3) * (1.0 - smoothstep(0.01, 0.035, stripe3));
	vec3 col = fill_color.rgb;
	float ink = (line * 0.75 + line2 * 0.45 + line3 * 0.30) * (1.0 - split * 0.35);
	col = mix(col, line_color.rgb, clamp(ink, 0.0, 1.0));
	float a = fill_color.a * alpha * (1.0 - split * 0.85);
	float edge = smoothstep(0.0, 0.04, UV.y) * smoothstep(1.0, 0.96, UV.y);
	COLOR = vec4(col, a * mix(0.9, 1.0, edge));
}
