#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D PrevSampler;
uniform sampler2D SceneSampler;

layout(location = 0) out vec4 fragColor;

// g/b carry a fixed mark. without it you can't tell a byte from whatever colour the
// world happened to draw in that corner
const vec2 BUS_MARK = vec2(90.0, 195.0) / 255.0;

vec4 packFloat(float v) {
    uint bits = floatBitsToUint(v);
    return vec4(uvec4(bits >> 24, bits >> 16, bits >> 8, bits) & 0xFFu) / 255.0;
}

float unpackFloat(vec4 texel) {
    uvec4 b = uvec4(round(texel * 255.0));
    return uintBitsToFloat((b.r << 24) | (b.g << 16) | (b.b << 8) | b.a);
}

// texel 0 = start time, texel 1 = last bus byte we saw
// +1 so a live register isn't all-zero. all-zero = never initialised
void main() {
    vec4 rawStart = texelFetch(PrevSampler, ivec2(0, 0), 0);
    vec4 rawMark = texelFetch(PrevSampler, ivec2(1, 0), 0);

    vec4 bus = texelFetch(SceneSampler, ivec2(0, 0), 0);
    bool marked = all(lessThan(abs(bus.gb - BUS_MARK) * 255.0, vec2(1.5)));
    float marker = marked ? floor(bus.r * 255.0 + 0.5) : 0.0;

    bool fresh = (rawMark.a == 0.0);
    float lastMarker = floor(rawMark.r * 255.0 + 0.5);
    bool restarted = fresh || abs(marker - lastMarker) > 0.5;

    float startTime = restarted ? GameTime : (unpackFloat(rawStart) - 1.0);

    fragColor = (gl_FragCoord.x < 1.0)
        ? packFloat(startTime + 1.0)
        : vec4(marker / 255.0, 0.0, 0.0, 1.0);
}
