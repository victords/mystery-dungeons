#define MAX_LIGHT_SOURCES 20

uniform vec3 light_sources[MAX_LIGHT_SOURCES];
uniform int light_source_count;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float alpha = 0.0;
  for (int i = 0; i < light_source_count; i++) {
    float d_x = screen_coords.x - light_sources[i].x;
    float d_y = screen_coords.y - light_sources[i].y;
    float distance = sqrt(pow(d_x, 2) + pow(d_y, 2));
    float light_source_radius = light_sources[i].z;
    if (distance < 0.75 * light_source_radius) {
      alpha = 1.0;
      break;
    } else if (distance < light_source_radius) {
      alpha = 0.5;
    }
  }

  vec4 pixel = Texel(texture, texture_coords);
  return vec4(alpha * pixel.r, alpha * pixel.g, alpha * pixel.b, 1.0);
}
