shader_type canvas_item;

/// Fine stone grain over the whole plate. Samples petrify_stone as noise,
/// never as a stretched/tiled sprite (that reads as a transparency checker).
uniform sampler2D stone_tex : source_color, filter_nearest;
uniform float amount : hint_range(0.0, 1.0) = 0.52;

void fragment() {
	vec3 gtex = texture(stone_tex, UV * 13.0).rgb;
	float g = dot(gtex, vec3(0.30, 0.50, 0.20));
	vec3 col = vec3(0.50, 0.47, 0.41) * mix(0.78, 1.16, g);
	float a = amount * mix(0.38, 0.78, g);
	COLOR = vec4(col, a);
}
