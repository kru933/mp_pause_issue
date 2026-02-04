shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always, fog_disabled;

uniform sampler2D noise;

uniform vec4 WATER_COL : source_color = vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 WATER2_COL : source_color = vec4(0.04, 0.35, 0.78, 1.0);

uniform float wave_amplitude = 0.5;
uniform float wave_frequency = 1.5;
uniform float transparency = 0.8; // Adjust this to control overall water transparency

// Distance gradient
uniform float distance_min = 0.0;
uniform float distance_max = 1.0;

// Vertex shader (unchanged)
varying float vert_height;
void vertex() {
	VERTEX = normalize(VERTEX) * (length(VERTEX) + (length(texture(noise, VERTEX.xy + (TIME * wave_frequency))) * wave_amplitude));
	vert_height = length(VERTEX);
}

void fragment() {
    ALBEDO = mix(WATER_COL, WATER2_COL, clamp(smoothstep(distance_min, distance_max, vert_height), 0.0, 1.0)).rgb;
	ALPHA = transparency;
}
