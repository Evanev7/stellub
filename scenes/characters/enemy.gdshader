shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

uniform float value : hint_range(0,1);
uniform sampler2D noise_texture;


const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1),
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

uniform vec3 hsv_offset;

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline_weight = 0.0;
	
	// gets a positive value for any point with nearby opaque-ness.
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline_weight += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline_weight = min(outline_weight, 1.0);
	outline_weight -= COLOR.a;
	
	vec3 input_color;
	vec4 texture_color = texture(TEXTURE, UV);
	input_color = texture_color.rgb;
	
	vec3 color_hsv = rgb_to_hsv(input_color);
	
	color_hsv += hsv_offset;
	
	vec3 color_rgb = hsv_to_rgb(color_hsv);
	
	texture_color = vec4(color_rgb.rgb,texture_color.a);
	COLOR.rgba = texture_color;
	
	if (line_thickness > 0.05)
	{
		COLOR = mix(COLOR, line_color, outline_weight);
	}
	
	vec4 noise_pixel = texture(noise_texture,UV);
	if (noise_pixel.r > value)
	{
		COLOR.a -= 1.;
	}
}
