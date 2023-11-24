//shader_type canvas_item;
//
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//
//// The output color for the outline
//uniform vec4 line_color : source_color = vec4(1.0);
//uniform float line_thickness : hint_range(0, 10) = 1.0;
//
//const vec2 OFFSETS[8] = {
//	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
//	vec2(1, -1), vec2(1, 0), vec2(1, 1)
//};
//
//void fragment() {
//	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
//	vec4 tex_color = texture(TEXTURE, UV);
//	COLOR = tex_color;
//
//	if (screen_color.r < 10.0){
//		COLOR.rgb = line_color.rgb;
//
//		// We convert the pixel width we want for our outline in decimal texel size.
//		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
//
//		// We sample and offset the texture 8 times to draw an outline.
//		float alpha = tex_color.a;
//
//		for (int i = 0; i < OFFSETS.length(); i++) {
//			alpha += texture(TEXTURE, UV + size * OFFSETS[i]).a;
//		}
//
//		// If the summed alpha is too high, it means we're over the original texture
//		// and we don't want to draw this pixel; it's not part of the outline.
//		if (alpha >= 8.5) {
//			alpha = 0.0;
//		}
//
//		// We then override the texture's color with the calculated outline.
//		COLOR = vec4(line_color.rgb, min(alpha, 1.0) * tex_color.a);
//	}
//}

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
// Allows you to control the output color in the Shader Params in the Inspector.
uniform vec4 silhouette_color : source_color = vec4(0.0, 0.8, 0.8, 1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;
const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};
void fragment() {
	// We sample the screen texture at this point, which has the Mask node's pixels
	// rendered on it.
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color;

	// If the pixel's value is lower than the Mask's output color, it means the
	// mask is being occluded, so we draw the silhouette instead.
	if (screen_color.r < 1.0){
		//COLOR.rgb = silhouette_color.rgb;
		COLOR.rgb = silhouette_color.rgb;

		// We convert the pixel width we want for our outline in decimal texel size.
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;

		// We sample and offset the texture 8 times to draw an outline.
		float alpha = tex_color.a;

		for (int i = 0; i < OFFSETS.length(); i++) {
			alpha = texture(TEXTURE, UV + size * OFFSETS[i]).a;
		}

		// If the summed alpha is too high, it means we're over the original texture
		// and we don't want to draw this pixel; it's not part of the outline.
//		if (alpha >= 8.5) {
//			alpha = 0.0;
//		}

		// We then override the texture's color with the calculated outline.
		COLOR = vec4(silhouette_color.rgb, min(alpha, 1.0) * tex_color.a);
	}
}