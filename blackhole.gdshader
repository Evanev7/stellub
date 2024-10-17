shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_enable, filter_nearest;
uniform sampler2D curve;
uniform float activator;

void fragment() {
	vec2 offset = UV - vec2(0.5);
	float radius = 2.*length(offset);

	float scale = texture(curve, vec2(radius)).x;
	offset *= scale*activator;
	COLOR = texture(screen_texture, SCREEN_UV + offset);
	//COLOR = vec4(offset,0.,1.);
}
