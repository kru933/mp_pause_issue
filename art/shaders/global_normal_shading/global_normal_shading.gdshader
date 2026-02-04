shader_type spatial;
render_mode unshaded, cull_disabled, world_vertex_coords;

uniform vec3 base_color : source_color;

vec3 hsv_adjustment(vec3 col, float hue_offset, float sat_offset, float val_offset) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(col.bg, K.wz), vec4(col.gb, K.xy), step(col.b, col.g));
	vec4 q = mix(vec4(p.xyw, col.r), vec4(col.r, p.yzx), step(p.x, col.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	//hsv.x += hue_offset / 360.0;
	//hsv.y += sat_offset;
	hsv.z += val_offset;
	return hsv;
}

vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float grayscale(vec3 color) {
	float max1 = max(color.r, color.g);
	float max2 = max(max1, color.b);
	return max2;
}

varying vec3 vert_normal;
void vertex(){
	vert_normal = normalize(NORMAL);
}

void fragment() {
    vec3 world_normal = vert_normal;

	vec3 hsv_base_color = rgb_to_hsv(base_color);

	// Down
	if (dot(world_normal, vec3(0, -1, 0)) > 0.75)
	{
		hsv_base_color.b -= 0.5;
	}
	// Left
	if (dot(world_normal, vec3(1, 0, 0)) > 0.75)
	{
		hsv_base_color.b -= 0.1;
	}
	// Right
	if (dot(world_normal, vec3(-1, 0, 0)) > 0.75)
	{
		hsv_base_color.b -= 0.1;
	}
	// Forward
	if (dot(world_normal, vec3(0, 0, 1)) > 0.75)
	{
		hsv_base_color.b -= 0.1;
	}
	// Backward
	if (dot(world_normal, vec3(0, 0, -1)) > 0.75)
	{
		hsv_base_color.b -= 0.1;
	}

	vec3 base_color_mod = hsv_to_rgb(hsv_base_color);
    ALBEDO = base_color_mod;
}