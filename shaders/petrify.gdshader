shader_type canvas_item;

/// Top-down stone creep on the item art. UV.y < creep mixes toward stone
/// while keeping the silhouette (alpha) so the named object still reads.
uniform float creep : hint_range(0.0, 1.0) = 0.0;
uniform float mix_amt : hint_range(0.0, 1.0) = 0.88;
uniform sampler2D stone_tex : source_color, filter_nearest;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec3 grain = texture(stone_tex, UV * 7.0).rgb;
	float grey = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 litho = vec3(grey) * vec3(0.78, 0.74, 0.66);
	vec3 stone_col = mix(litho, grain * vec3(0.86, 0.82, 0.74), 0.58);
	// Keep a little original hue so Throwing Knife still reads as a knife.
	stone_col = mix(base.rgb * vec3(0.42, 0.40, 0.36), stone_col, 0.78);
	float edge = abs(UV.y - creep);
	float crack = 1.0 - smoothstep(0.0, 0.030, edge);
	float stoned = step(UV.y, creep);
	vec3 col = mix(base.rgb, stone_col, stoned * mix_amt);
	col = mix(col, vec3(0.38, 0.36, 0.32), crack * stoned * 0.9);
	COLOR = vec4(col, base.a);
}
