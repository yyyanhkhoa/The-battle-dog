shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 scale;
uniform float y_zoom;

uniform vec4 water_color: source_color;

uniform float wave_amplitude;
uniform float wave_speed;
uniform float wave_period;

void fragment() {
	float waves = UV.y * scale.y + sin(UV.x	* scale.x / wave_period + TIME * wave_speed) * cos(0.2 * UV.x * scale.x / wave_period + TIME-wave_speed) * wave_amplitude - wave_amplitude;
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screen_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - uv_height * UV.y * scale.y * y_zoom * 2.0);	
	
	vec4 reflection = texture(SCREEN_TEXTURE, reflected_screen_uv); 
	
	vec4 r_color = mix(reflection, water_color, clamp(water_color.a - UV.y, 0.0, 1.0));
	COLOR = mix(texture(SCREEN_TEXTURE, SCREEN_UV), r_color, smoothstep(0.0, 0.1, waves) );
}