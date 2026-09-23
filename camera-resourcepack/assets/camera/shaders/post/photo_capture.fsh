#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D StateSampler;
uniform sampler2D PrevSampler;
uniform sampler2D SceneSampler;

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

const float DAY_SECONDS = 1200.0; // GameTime is a fraction of a day, not seconds
const float CAPTURE_WINDOW = 0.05;

float unpackFloat(vec4 texel) {
    uvec4 b = uvec4(round(texel * 255.0));
    return uintBitsToFloat((b.r << 24) | (b.g << 16) | (b.b << 8) | b.a);
}

void main() {
    float startTime = unpackFloat(texelFetch(StateSampler, ivec2(0, 0), 0)) - 1.0;
    float elapsed = GameTime - startTime;
    if (elapsed < 0.0) elapsed += 1.0; // wrapped past midnight
    float seconds = elapsed * DAY_SECONDS;

    vec4 held = texture(PrevSampler, texCoord);

    bool idle = texelFetch(StateSampler, ivec2(1, 0), 0).g > 0.5;
    if (idle) {
        fragColor = held;
        return;
    }

    // a fresh target reads all zero, so without this the first frame holds black
    bool uninitialised = (held.a == 0.0);

    if (seconds < CAPTURE_WINDOW || uninitialised) {
        fragColor = vec4(texture(SceneSampler, texCoord).rgb, 1.0);
        return;
    }

    fragColor = held;
}
