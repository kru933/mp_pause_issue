shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_back;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001);
instance uniform vec3 uv1_scale = vec3(1, 1, 1);
uniform vec3 uv1_offset;

uniform sampler2D noise_1 : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_2 : source_color, filter_linear_mipmap, repeat_enable;

instance uniform float value_difference = 0.1;
uniform float mixer_mult = 0.1;

varying vec3 uv1_power_normal;
varying vec3 uv1_triplanar_pos;

void vertex() {
	// UV1 Triplanar: Enabled
	uv1_power_normal = pow(abs(NORMAL), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
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

void fragment() {
	vec3 albedo_tex = texture(texture_albedo, UV).rgb * albedo.rgb;
	
	vec4 noise_1_sample = triplanar_texture(noise_1, uv1_power_normal, uv1_triplanar_pos);
	vec4 noise_2_sample = triplanar_texture(noise_2, uv1_power_normal, uv1_triplanar_pos);
	
	float mixer = noise_1_sample.r + (1.0 - noise_2_sample.r);
	
	vec3 color_hsv = rgb_to_hsv(albedo_tex.rgb);
	color_hsv.b -= value_difference;
	vec3 color_rgb = hsv_to_rgb(color_hsv);
	
	ALBEDO = mix(albedo_tex.rgb, color_rgb, (mixer * mixer_mult));
}
