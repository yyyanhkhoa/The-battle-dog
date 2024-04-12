// NOTICE: only works for CanvasGroup!
// taken from https://godotshaders.com/shader/animated-and-gradient-outlines/
// with some modifications to work with CanvasGroup

shader_type canvas_item;
render_mode unshaded;
uniform float zoom;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float max_line_width = 10.0;
uniform float min_line_width = 5.0;
uniform float intensity = 1.0;
uniform float line_blur = 0.125;
uniform float block_size = 20.0;
uniform float freq = 1.0;
uniform vec4 line_color: source_color;

const float pi = 3.1415;
const int ang_res = 16;
const int grad_res = 8;

float hash(vec2 p, float s) {
	return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

float noise(vec2 p, float s) {
	vec2 d = vec2(0, 1);
	vec2 b = floor(p);
	vec2 f = fract(p);
	return mix(
		mix(hash(b + d.xx, s), hash(b + d.yx, s), f.x),
		mix(hash(b + d.xy, s), hash(b + d.yy, s), f.x), f.y
	);
}

float getLineWidth(vec2 p, float s) {
	p /= block_size * 0.001;
	float w = 0.0;
	for (int i = 0; i < 3; i++) {
		w = mix(w, noise(p, s), intensity);
	}
	
	return mix(max_line_width, min_line_width, w);
}

bool pixelInRange(sampler2D text, vec2 uv, vec2 dist) {
	float alpha = 0.0;
	for (int i = 0; i < ang_res; i++) {
		float angle = 2.0 * pi * float(i) / float(ang_res);
		vec2 disp = dist * vec2(cos(angle), sin(angle));
		if (texture(text, uv + disp).a > 0.0) return true;
	}
	return false;
}

float getClosestDistance(sampler2D text, vec2 uv, vec2 maxDist) {
	if (!pixelInRange(text, uv, maxDist)) return -1.0;
	
	float hi = 1.0; float lo = 0.0;
	
	for (int i = 1; i <= grad_res; i++) {
		float curr = (hi + lo) / 2.0;
		if (pixelInRange(text, uv, curr * maxDist)) {
			hi = curr;
		}
		else {
			lo = curr;
		}
	}
	return hi;
}

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	float timeStep = floor(freq * TIME);
	vec2 scaledDist = SCREEN_PIXEL_SIZE;
	scaledDist *= getLineWidth((UV / TEXTURE_PIXEL_SIZE), timeStep) * zoom;
	float w = getClosestDistance(screen_texture, SCREEN_UV, scaledDist);
	
	if (max_line_width > 0.0 && w > 0.0 && c.a < 1.0) {
		vec4 new_color = mix(line_color, c, c.a);
		COLOR *= new_color;
		
		COLOR.a *= smoothstep(0, line_blur, 1.0 - w);
	}
	else {
		COLOR *= c;
	}
	
}
