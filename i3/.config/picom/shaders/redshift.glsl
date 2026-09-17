#version 330

in vec2 texcoord;            // texture coordinate of the fragment
uniform sampler2D tex;       // texture of the window

// Forward-declare the helper that picom provides internally.
// Do NOT give it a body — picom links in its own definition.
vec4 default_post_processing(vec4 c);

// This is the ONLY function you are allowed to define.
vec4 window_shader() {
    vec2 texsize = textureSize(tex, 0);
    vec4 c = texture2D(tex, texcoord / texsize, 0);

    // Warm the screen: cut green a bit, cut blue more.
    c.g *= 0.85;
    c.b *= 0.65;

    // Hand off to picom so dim/invert/opacity/rounded-corners still work.
    return default_post_processing(c);
}
