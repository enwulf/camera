#version 330
#extension GL_ARB_separate_shader_objects : require

// copies the working target back into the persistent one. looks pointless but a pass
// can't read a foreign texel of the target it writes, so the two have to ping-pong
uniform sampler2D InSampler;

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = texelFetch(InSampler, ivec2(gl_FragCoord.xy), 0);
}
