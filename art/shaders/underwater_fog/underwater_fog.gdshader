shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled, cull_disabled, world_vertex_coords;

uniform float water_radius;
uniform vec4 fog_color : source_color;

uniform float wave_speed = 2;
uniform float wave_amplitude = 0.5;
uniform float wave_frequency = 1.5;
uniform float cpu_time = 0.0;

varying vec3 vert_pos;
void vertex() {
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	vert_pos = VERTEX.xyz;
}

float calculate_wave_height(vec2 position, float time) {
    float wave_x = sin(position.x * wave_frequency + time * wave_speed);
    float wave_y = cos(position.y * wave_frequency + time * wave_speed);
    return (wave_x + wave_y) * 0.5 * wave_amplitude;
}

void fragment() {
	ALBEDO = fog_color.rgb;
	ALPHA = 0.0;
	
    float wave = calculate_wave_height(vert_pos.xz, cpu_time);
	float height = dot(vert_pos.xyz, normalize(vert_pos.xyz));
	
	if (height < water_radius + wave)
	{
		ALPHA = fog_color.a;
	}
}