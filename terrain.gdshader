shader_type canvas_item;
render_mode blend_mix;

global uniform vec2 player_position;

void fragment() {
	vec2 diff = SCREEN_UV - player_position;
	diff / TEXTURE_PIXEL_SIZE;
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y);
	float smoothed = smoothstep(0.05, 0.1, dist);
	COLOR.a = min(smoothed*0.5+0.5, COLOR.a);
}