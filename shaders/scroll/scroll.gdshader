shader_type canvas_item;

uniform vec2 velocity;
uniform float speed_scale = 0.025;

void fragment() {
	vec2 new_uv = vec2(UV.x, UV.y) + (velocity * TIME * speed_scale);
    vec4 c = texture(TEXTURE, new_uv);
    COLOR = c;
}
