#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D InSampler;

layout(std140) uniform BusConfig {
    vec4 Value;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

const vec2 BUS_MARK = vec2(90.0, 195.0) / 255.0;

void main() {
    if (gl_FragCoord.x < 1.0 && gl_FragCoord.y < 1.0) {
        fragColor = vec4(Value.x, BUS_MARK, 1.0);
        return;
    }
    fragColor = texture(InSampler, texCoord);
}
