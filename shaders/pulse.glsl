uniform vec3 base_color = vec3(1, 1, 1);
uniform float time = 0.0;
uniform float duration = 2.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 pixel = Texel(texture, texture_coords);
  if (pixel.r == base_color.r && pixel.g == base_color.g && pixel.b == base_color.b) {
    return vec4(base_color, clamp(abs(time) / duration, 0, 1));
  }

  return pixel;
}
