uniform float light_radius = 5.0;
uniform vec2 image_size = vec2(10, 10);

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
  float new_x, new_y;
  if (VertexTexCoord.x == 0.0) {
    new_x = vertex_position.x - light_radius;
  } else {
    new_x = vertex_position.x + light_radius;
  }
  if (VertexTexCoord.y == 0.0) {
    new_y = vertex_position.y - light_radius;
  } else {
    new_y = vertex_position.y + light_radius;
  }
  return transform_projection * vec4(new_x, new_y, vertex_position.z, vertex_position.w);
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec2 total_size = vec2(image_size.x + 2 * light_radius, image_size.y + 2 * light_radius);
  vec2 texture_pos = vec2(texture_coords.x * total_size.x, texture_coords.y * total_size.y);
  if (texture_pos.x < light_radius ||
      texture_pos.y < light_radius ||
      texture_pos.x >= light_radius + image_size.x ||
      texture_pos.y >= light_radius + image_size.y) {
    return vec4(0, 0, 0, 1);
  }

  texture_coords = vec2((texture_pos.x - light_radius) / image_size.x, (texture_pos.y - light_radius) / image_size.y);
  return Texel(texture, texture_coords);
}
#endif
