#vesion 300 es

precision highp float;

uniform sampler2D sampler;

in vec2 outTextureCoords;

void main() {
    gl_FragColor = texture(sampler, outTextureCoords);
}
