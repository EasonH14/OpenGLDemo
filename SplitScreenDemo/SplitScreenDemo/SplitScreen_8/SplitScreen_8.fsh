
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    gl_FragColor = texture2D(sampler, 1.0 - outTextureCoords);
}
