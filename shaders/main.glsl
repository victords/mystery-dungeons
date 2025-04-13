#define MAX_LIGHT_SOURCES 20

extern vec3 light_sources[MAX_LIGHT_SOURCES];
extern int light_source_count;
extern number screen_scale = 4.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  number alpha = 0.0;
  vec2 scaled_screen_coords = vec2(floor(screen_coords.x / screen_scale), floor(screen_coords.y / screen_scale));
  for (int i = 0; i < light_source_count; i++) {
    number d_x = scaled_screen_coords.x - light_sources[i].x;
    number d_y = scaled_screen_coords.y - light_sources[i].y;
    number distance = sqrt(pow(d_x, 2) + pow(d_y, 2));
    number light_source_radius = light_sources[i].z;
    if (distance < 0.75 * light_source_radius) {
      alpha += 1.0;
    } else if (distance < light_source_radius) {
      alpha += 0.5;
    }

    if (alpha >= 1.0) {
      alpha = 1.0;
      break;
    }
  }

  vec4 pixel = Texel(texture, texture_coords);
  return vec4(alpha * pixel.r, alpha * pixel.g, alpha * pixel.b, 1.0);
}
