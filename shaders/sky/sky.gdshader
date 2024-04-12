shader_type canvas_item;

uniform float sky_wiggle = 10;

uniform sampler2D noise_texture: repeat_enable;
uniform sampler2D noise_texture_2: repeat_enable;
uniform float noise_speed_scale = 0.075;
uniform float noise_wiggle = 70;
uniform float intensity = 0.08;

uniform vec4 modulate: source_color = vec4(1.0);
uniform float speed_scale = 0.025;

vec4 overlay(vec4 base, vec4 blend) {
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment() {
	vec2 new_uv = vec2(UV.x + TIME * speed_scale * 0.5, UV.y);
	
	vec2 w_uv = UV + TIME * 0.005;
	vec2 noise_value = TEXTURE_PIXEL_SIZE * texture(noise_texture, w_uv).r;
	vec2 n_uv = UV + TIME * noise_speed_scale * 0.1 + noise_value * noise_wiggle;
	vec2 n_uv_2 = UV + vec2(TIME * noise_speed_scale * 0.5, TIME * noise_speed_scale * 0.5) + noise_value * noise_wiggle;
	
    vec4 c = texture(TEXTURE, new_uv + noise_value * sky_wiggle) * modulate;
	vec4 n_color = 0.5 + (-intensity + (texture(noise_texture, n_uv) + texture(noise_texture_2, n_uv_2)) * intensity * 2.0);
	
	COLOR = overlay(c, n_color);
}

