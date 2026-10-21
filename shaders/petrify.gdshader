shader_type canvas_item;

/// Top-down stone creep on the card icon. UV.y < creep mixes the art toward
/// petrify_stone.png (1:1 over the icon — never tiled as a transparency grid).
uniform float creep : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D stone_tex : source_color, filter_nearest;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	// Sample stone as fine luminance only (high-frequency). Never stretch the
	// 2-tone dither as a large overlay — that reads as a transparency checker.
	float grain = texture(stone_tex, UV * 18.0).r;
	float grey = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 stone_col = vec3(grey * mix(0.72, 0.98, grain));
	stone_col *= vec3(0.90, 0.86, 0.78);
	float edge = abs(UV.y - creep);
	float crack = 1.0 - smoothstep(0.0, 0.022, edge);
	float stoned = step(UV.y, creep);
	vec3 col = mix(base.rgb, stone_col, stoned * 0.92);
	col = mix(col, vec3(0.55, 0.52, 0.46), crack * stoned * 0.9);
	COLOR = vec4(col, base.a);
}
