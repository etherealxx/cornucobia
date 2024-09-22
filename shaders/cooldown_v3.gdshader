// 0BSD
// Copyright (C) 2024 by Etherealxx
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

// actually chatgpt wrote most of this with some tweaks by me
// imma keep some of the comments since i'm also learning from it

shader_type canvas_item;

// 0.0 (full cooldown) to 1.0 (no cooldown)
uniform float cooldown_progress : hint_range(0.0, 1.0);

uniform float start_angle : hint_range(0.0, 360.0);

varying flat vec4 modulate;

bool in_cooldown(vec2 uv, float progress, float start_angle_offset) {
    // Convert UV coordinates to centered coordinates (-0.5 to 0.5)
    vec2 centered_uv = uv - vec2(0.5);

    // Calculate the angle of the UV coordinate in radians
    float angle = atan(centered_uv.y, centered_uv.x);

    // Convert the angle from radians to a range of 0.0 to 1.0 (normalized)
    angle = angle / (2.0 * PI) + 0.5;

    // Convert the start angle from degrees to normalized range (0.0 to 1.0)
    float start_angle_norm = start_angle_offset / 360.0;

    // Shift the angle by the start angle
    angle = mod(angle - start_angle_norm + 1.0, 1.0);

    // Check if the point is within the cooldown arc
    return (angle <= progress);
}

void vertex() {
     // so that self modulate also have effect
	modulate = COLOR;
}

void fragment() {
    // Sample the texture at the given UV coordinates
    vec4 tex_color = texture(TEXTURE, UV) * modulate;

    // If the fragment is within the cooldown arc, overlay the darker version
    if (in_cooldown(UV, cooldown_progress, start_angle)) {
        // Darken the texture color by reducing its brightness
        vec4 darkened_color = tex_color * vec4(0.4, 0.4, 0.4, 1.0); // Adjust the darkening factor as needed
        COLOR = darkened_color;
    } else {
        // Outside the cooldown arc, show the regular texture color
        COLOR = tex_color;
    }
}
