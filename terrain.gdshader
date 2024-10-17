shader_type canvas_item;
render_mode blend_mix;

global uniform vec2 player_position;
global uniform vec2 circle_position;


uniform float value : hint_range(0,1);
uniform sampler2D noise_texture;

void fragment() {
	vec2 diff = SCREEN_UV - player_position;
	diff / TEXTURE_PIXEL_SIZE;
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y);
	float smoothed = smoothstep(0.05, 0.1, dist);
	COLOR.a = min(smoothed*0.5+0.5, COLOR.a);
	
	vec4 color = texture(TEXTURE, UV);
	vec4 noise_pixel = texture(noise_texture,UV);
	
	if(noise_pixel.r > value)
	{
		COLOR.a -= 1.f;
	}
	
	vec2 new_diff = SCREEN_UV - circle_position;
	new_diff / TEXTURE_PIXEL_SIZE;
	float new_dist = sqrt(new_diff.x * new_diff.x + new_diff.y * new_diff.y);
	float new_smoothed = smoothstep(0.05, 0.3, new_dist);
	COLOR.a = min(new_smoothed*0.5+0.5, COLOR.a);
	
	vec4 new_color = texture(TEXTURE, UV);
	
	vec4 new_noise_pixel = texture(noise_texture,UV);
	
	if(new_noise_pixel.r > value)
	{
		COLOR.a -= 1.f;
	}
}