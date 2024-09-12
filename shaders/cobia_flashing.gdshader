// from https://godotshaders.com/shader/hit-flash-effect
// with modifications
shader_type canvas_item;

uniform bool active = false;
uniform vec4 tint : source_color = vec4(1., 1., 1., 1);
uniform float flash_interval = 1.0; // Time interval for the flash effect (in seconds)

void fragment() {
    vec4 tint_copy = tint;
    vec4 previous_color = texture(TEXTURE, UV);
    
    if (active == true) {
        // Flash logic based on time and interval
        float time_in_flash_cycle = mod(TIME, flash_interval * 2.0); // *2.0 for flash on and off
        bool flash_on = time_in_flash_cycle < flash_interval; // Flash for the first half of the cycle
        
        if (flash_on) {
            tint_copy.a = previous_color.a;
            COLOR = tint_copy;
        } else {
            COLOR = previous_color; // No flash, use original texture color
        }
    } else {
        COLOR = previous_color; // Not active, use original texture color
    }
}
