shader_type canvas_item;
render_mode unshaded;
// https://godotshaders.com/shader/noise-offset-wiggle/
// with modifications

uniform sampler2D NOISE_TEXTURE: repeat_enable;
uniform float strength = 3.0;
uniform float uv_scaling: hint_range (0.0, 1.0, 0.05) = 0.5;
uniform vec2 movement_direction = vec2(-1, 0);
uniform float movement_speed = 0.5;
const float SPEED_DOWN_SCALE = 0.01;

void fragment() {
	vec2 uv = UV;
	vec2 movement_factor = movement_direction * movement_speed * TIME * SPEED_DOWN_SCALE;
	float noise_value = texture(NOISE_TEXTURE, uv*uv_scaling + movement_factor).r - 0.5;
	uv += noise_value * TEXTURE_PIXEL_SIZE * strength;
	COLOR = texture(TEXTURE, uv);
}