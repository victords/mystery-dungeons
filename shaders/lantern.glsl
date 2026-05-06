uniform vec2 image_size;
uniform vec3 light_color = vec3(1, 1, 1);
uniform float light_min_radius = 16.0;
uniform float light_max_radius = 20.0;
uniform float light_min_alpha = 0.6;
uniform float light_max_alpha = 0.8;
uniform float time = 0.0;

float factor = 0.5 * (1 - cos(time));
float current_radius = light_min_radius + factor * (light_max_radius - light_min_radius);
float current_alpha = light_min_alpha + factor * (light_max_alpha - light_min_alpha);

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
  float new_x, new_y;
  if (VertexTexCoord.x == 0.0) {
    new_x = vertex_position.x + 0.5 * image_size.x - current_radius;
  } else {
    new_x = vertex_position.x - 0.5 * image_size.x + current_radius;
  }
  if (VertexTexCoord.y == 0.0) {
    new_y = vertex_position.y + 0.5 * image_size.y - current_radius;
  } else {
    new_y = vertex_position.y - 0.5 * image_size.y + current_radius;
  }
  return transform_projection * vec4(new_x, new_y, vertex_position.z, vertex_position.w);
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec2 texture_pos = vec2(texture_coords.x * 2 * current_radius, texture_coords.y * 2 * current_radius);
  float distance = sqrt(pow(texture_pos.x - current_radius, 2) + pow(texture_pos.y - current_radius, 2));
  float alpha =
    distance <= current_radius * 0.5 ? current_alpha :
    distance <= current_radius * 0.8 ? 0.5 * current_alpha :
    distance <= current_radius ? 0.25 * current_alpha : 0.0;
  vec2 image_offset = vec2(current_radius - 0.5 * image_size.x, current_radius - 0.5 * image_size.y);
  if (texture_pos.x < image_offset.x ||
      texture_pos.y < image_offset.y ||
      texture_pos.x >= image_offset.x + image_size.x ||
      texture_pos.y >= image_offset.y + image_size.y) {
    return vec4(light_color, alpha);
  } else {
    texture_coords = vec2((texture_pos.x - image_offset.x) / image_size.x, (texture_pos.y - image_offset.y) / image_size.y);
    vec4 color_from_image = Texel(texture, texture_coords);
    return vec4(light_color, alpha) + color_from_image * (1 - alpha);
  }
}
#endif
