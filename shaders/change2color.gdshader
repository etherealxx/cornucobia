// 0BSD
// Copyright (C) 2024 by Etherealxx
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

// modified from Zylann's shader from this post
// https://forum.godotengine.org/t/changing-a-specific-color-in-a-sprite-using-shaders-in-godot-3/29610/4
// revision 2, more accurate color

shader_type canvas_item;

// First color to change
uniform vec4 u_color_key1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// First color's replacement
uniform vec4 u_replacement_color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
// Second color to change
uniform vec4 u_color_key2 : source_color = vec4(0.75, 0.75, 0.75, 1.0);
// Second color's replacement
uniform vec4 u_replacement_color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float u_tolerance = 0.1; // tolerance for the replacement colors

uniform float u_interpolation_factor : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    vec3 col = original_color.rgb;

    // Euclidean distance calculation for color tolerance
    float distance1 = distance(col, u_color_key1.rgb);
    float distance2 = distance(col, u_color_key2.rgb);

    // Apply first color replacement based on tolerance
    vec3 new_color1 = mix(col, u_replacement_color1.rgb, step(distance1, u_tolerance) * u_interpolation_factor);

    // Apply second color replacement based on tolerance (after the first one)
    vec3 final_color = mix(new_color1, u_replacement_color2.rgb, step(distance2, u_tolerance) * u_interpolation_factor);

    // Preserve transparency and assign final color
    COLOR = vec4(final_color, original_color.a);
}