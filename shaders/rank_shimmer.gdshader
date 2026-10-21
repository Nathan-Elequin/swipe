shader_type canvas_item;
// Rank glint on ItemCard / draft gate / Dungeon Deck.
// Clock is driven from GDScript so Engine.time_scale (0.675 / 2.025) is respected.

uniform vec4 shine_col : source_color = vec4(0.831, 0.537, 0.306, 1.0);
uniform float speed = 0.9;
uniform float rest = 4.0;
uniform float phase = 0.0;
uniform float desat = 0.0;
uniform float armed = 0.0;
uniform float clock = 0.0;
uniform vec2 card_px = vec2(118.0, 120.0);

void fragment() {
	vec4 col = COLOR;
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	col.rgb = mix(col.rgb, vec3(grey), clamp(desat, 0.0, 1.0));

	float period = max(speed + rest, 0.001);
	float t = fract((clock + phase) / period);
	float sweep_ratio = clamp(speed / period, 0.02, 0.98);
	vec2 px = UV * card_px;
	vec2 edge = min(UV, vec2(1.0) - UV) * card_px;
	float round_m = smoothstep(0.0, 6.0, min(edge.x, edge.y));

	if (t < sweep_ratio) {
		float u = t / sweep_ratio;
		float ang = 1.04719755; // 60 degrees
		float diag = px.x * cos(ang) + px.y * sin(ang);
		float span = card_px.x + card_px.y;
		float pos = (u * 1.35 - 0.18) * span;
		float d1 = abs(diag - pos);
		float d2 = abs(diag - (pos + 21.0));
		float band1 = 1.0 - smoothstep(0.0, 13.0, d1);
		float band2 = 1.0 - smoothstep(0.0, 4.0, d2);
		float mask = max(band1 * 0.45, band2 * 0.28) * round_m;
		col.rgb += shine_col.rgb * mask;
	}

	if (armed > 0.5) {
		float ang = (clock / 2.4) * 6.2831853;
		vec2 c = UV - vec2(0.5);
		float a = atan(c.y, c.x);
		float rim = min(edge.x, edge.y);
		float on_rim = 1.0 - smoothstep(1.0, 4.5, abs(rim - 3.0));
		float d_ang = abs(atan(sin(a - ang), cos(a - ang)));
		float glint = (1.0 - smoothstep(0.0, 0.32, d_ang)) * on_rim * 0.72;
		col.rgb += shine_col.rgb * glint * armed;
	}

	COLOR = col;
}
