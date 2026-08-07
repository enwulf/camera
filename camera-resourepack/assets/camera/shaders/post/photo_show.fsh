#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D SceneSampler;
uniform sampler2D ShotSampler;
uniform sampler2D StateSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 SceneSize;
    vec2 ShotSize;
    vec2 StateSize;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

const float DAY_SECONDS = 1200.0; // GameTime is a fraction of a day, not seconds

const float FLASH_DECAY = 16.0;
const float SHRINK_START = 0.10;
const float SHRINK_TIME = 0.75;
const float FINAL_SCALE = 0.30;
const float FINAL_TILT = -0.055;
const float HOLD_UNTIL = 5.0;
const float FADE_TIME = 0.6;

float unpackFloat(vec4 texel) {
    uvec4 b = uvec4(round(texel * 255.0));
    return uintBitsToFloat((b.r << 24) | (b.g << 16) | (b.b << 8) | b.a);
}

void main() {
    float startTime = unpackFloat(texelFetch(StateSampler, ivec2(0, 0), 0)) - 1.0;
    float elapsed = GameTime - startTime;
    if (elapsed < 0.0) elapsed += 1.0;
    float t = elapsed * DAY_SECONDS;

    vec3 color = texture(SceneSampler, texCoord).rgb;

    float shrink = clamp((t - SHRINK_START) / SHRINK_TIME, 0.0, 1.0);
    shrink = 1.0 - pow(1.0 - shrink, 3.0);
    float fade = 1.0 - smoothstep(HOLD_UNTIL, HOLD_UNTIL + FADE_TIME, t);

    if (fade > 0.0) {

        float aspect = OutSize.x / max(OutSize.y, 1.0);
        vec2 q = vec2(texCoord.x, 1.0 - texCoord.y) * vec2(aspect, 1.0);

        vec2 fullHalf = vec2(aspect, 1.0) * 0.5;
        vec2 halfSize = fullHalf * mix(1.0, FINAL_SCALE, shrink);

        vec2 fullCentre = fullHalf;
        vec2 restCentre = vec2(aspect - halfSize.x - 0.035 * aspect, 1.0 - halfSize.y - 0.05);
        vec2 centre = mix(fullCentre, restCentre, shrink);

        float angle = mix(0.0, FINAL_TILT, shrink);
        float ca = cos(angle);
        float sa = sin(angle);

        vec2 rel = q - centre;
        vec2 rotated = vec2(rel.x * ca - rel.y * sa, rel.x * sa + rel.y * ca);
        vec2 local = rotated / halfSize;

        float border = mix(0.0, 0.045, shrink);
        float edge = max(abs(local.x), abs(local.y));

        vec2 shadowRel = q - (centre + vec2(0.012, 0.016) * shrink);
        vec2 shadowRot = vec2(shadowRel.x * ca - shadowRel.y * sa,
                              shadowRel.x * sa + shadowRel.y * ca);
        float shadowEdge = max(abs(shadowRot.x / halfSize.x), abs(shadowRot.y / halfSize.y));
        float shadow = (1.0 - smoothstep(1.0 + border, 1.0 + border + 0.09, shadowEdge))
                     * 0.45 * shrink;
        color = mix(color, vec3(0.0), shadow);

        if (edge <= 1.0 + border) {

            vec2 shotUv = local * 0.5 + 0.5;
            vec3 photo = texture(ShotSampler, vec2(shotUv.x, 1.0 - shotUv.y)).rgb;

            vec3 card = edge <= 1.0 ? photo : vec3(0.93, 0.93, 0.90);

            card = mix(card, vec3(0.75, 0.75, 0.72), smoothstep(0.985, 1.0, edge) * step(edge, 1.0));

            color = mix(color, card, fade);
        }
    }

    color = mix(color, vec3(1.0), clamp(exp(-t * FLASH_DECAY), 0.0, 1.0));

    fragColor = vec4(color, 1.0);
}
