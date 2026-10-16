shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.753, 0.502, 0.314, 1.0);
uniform float outline_size : hint_range(0.0, 3.0) = 1.5;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_size;
	float glow = 0.0;
	glow = max(glow, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(-px.x, 0.0)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(0.0, -px.y)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(px.x, px.y)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(-px.x, px.y)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(px.x, -px.y)).a);
	glow = max(glow, texture(TEXTURE, UV + vec2(-px.x, -px.y)).a);
	vec4 ring = vec4(outline_color.rgb, outline_color.a * glow);
	COLOR = mix(ring, col, col.a);
}
