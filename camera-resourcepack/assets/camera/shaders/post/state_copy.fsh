#version 330
#extension GL_ARB_separate_shader_objects : require

// same ping-pong as sim_copy, for the 2x1 clock register
uniform sampler2D InSampler;

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = texelFetch(InSampler, ivec2(int(gl_FragCoord.x), 0), 0);
}
