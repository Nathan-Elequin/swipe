shader_type canvas_item;

/// Top-down stone creep. UV.y < creep becomes greyscale stone with a crack edge.
uniform float creep : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D stone_tex : source_color, filter_nearest;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec4 stone = texture(stone_tex, UV);
	float grey = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 stone_col = mix(vec3(grey), stone.rgb, 0.72);
	float edge = abs(UV.y - creep);
	float crack = 1.0 - smoothstep(0.0, 0.02, edge);
	float stoned = step(UV.y, creep);
	vec3 col = mix(base.rgb, stone_col, stoned);
	col = mix(col, vec3(0.78, 0.74, 0.68), crack * stoned * 0.85);
	float a = mix(base.a, max(base.a, stone.a * 0.9), stoned);
	COLOR = vec4(col, a);
}
