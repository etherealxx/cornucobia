// https://godotshaders.com/shader/radial-blur-2/
// with modification
shader_type canvas_item;

// --- Functions --- //
void fragment() {
	COLOR.rgb = (texture(TEXTURE, UV) +
			texture(TEXTURE, UV * 0.99 + 0.5*0.01) +
			texture(TEXTURE, UV * 0.98 + 0.5*0.02) +
			texture(TEXTURE, UV * 0.97 + 0.5*0.03) +
			texture(TEXTURE, UV * 0.96 + 0.5*0.04) +
			texture(TEXTURE, UV * 0.95 + 0.5*0.05) +
			texture(TEXTURE, UV * 0.94 + 0.5*0.06) +
			texture(TEXTURE, UV * 0.93 + 0.5*0.07) +
			texture(TEXTURE, UV * 0.92 + 0.5*0.08) +
			texture(TEXTURE, UV * 0.91 + 0.5*0.09)).rgb / 10.0;
}