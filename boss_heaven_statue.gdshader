shader_type canvas_item;
render_mode blend_mix;


global uniform vec2 player_position;

uniform float value : hint_range(0,1);

void fragment() {
	vec2 diff = vec2(0.5,0.5) - UV;
	diff / TEXTURE_PIXEL_SIZE;
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y);
	float smoothed = 1.-smoothstep(0.5* value, 1. * value, dist);
	COLOR.a = min(smoothed*0.5+0.5, COLOR.a);
}
