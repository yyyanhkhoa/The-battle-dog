// heavily modified version of https://godotshaders.com/shader/simple-circle-transition-2/
	
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform float circle_size = 0.0;
uniform vec2 position = vec2(0.5, 0.5);
uniform float ratio = 1.77777777778;
uniform float zoom = 1.0;

uniform float invert: hint_range(0.0, 1.0) = 1.0;
uniform vec4 subtract: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 add: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 difference: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 exclusion: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 multiply: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float hue_shift = 0.0;

void fragment() {
	float dist = distance(vec2(position.x * ratio, position.y), vec2(SCREEN_UV.x * ratio, SCREEN_UV.y));
	
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

	float radius = circle_size * zoom;
	color = vec4(abs(invert - color.rgb), 1.0 - smoothstep(radius - 0.005, radius,  dist));

	//subtract blending mode
	color.rgb = color.rgb - subtract.rgb * subtract.a;

	//add
	color.rgb = color.rgb + add.rgb * add.a;
	
	// difference
	color.rgb = abs(color.rgb - difference.rgb * difference.a);
	
	// exclusion
	color.rgb = color.rgb + exclusion.rgb * exclusion.a - 2.0 * (color.rgb * exclusion.rgb * exclusion.a);
	
	// multiply
	vec4 mul_color = vec4(color.rgb * multiply.rgb, color.a);
	color = mix(color, mul_color, multiply.a);
	
	// hue shift
	// VectorFunc:2
	vec3 color_hsv;
	{
		vec3 c = color.rgb;
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	color_hsv.x = mod((color_hsv.x + hue_shift), 1.0f);

	// VectorFunc:5
	vec3 color_rgb;
	{
		vec3 c = color_hsv;
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
	
	color.rgb = color_rgb;
	COLOR.rgb = color.rgb;
	COLOR.a *= color.a;
}


