shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float width : hint_range(0.0, 64) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float pixel_size : hint_range(1, 15) = 4;
uniform float zoom = 1.0;

void fragment()
{
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	COLOR *= c;
	
    float _width = width;
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
    vec2 unit = ((1.0 * float(pixel_size) ) / tex_size) * zoom;
	
    vec4 pixel_color = texture(screen_texture, SCREEN_UV);
    if (pixel_color.a <= 0.45) {
        pixel_color = outline_color;
        pixel_color.a = 0.0;
        for (float x = -ceil(_width); x <= ceil(_width); x++) {
            for (float y = -ceil(_width); y <= ceil(_width); y++) {
                if (texture(screen_texture, SCREEN_UV + vec2(x*unit.x, y*unit.y)).a <= 0.3) {
                    continue;
                }
                pixel_color.a += outline_color.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -_width));
                pixel_color.a = min(pixel_color.a, 1.0);
            }
        }
   		COLOR = pixel_color;	
    }
}