#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec2 textureCoords;

out vec2 outTextureCoords;

void main() {
    gl_Position = position;
    outTextureCoords = textureCoords;
}
