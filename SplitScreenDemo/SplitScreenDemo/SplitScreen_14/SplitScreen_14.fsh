
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

void main() {
    gl_FragColor = texture2D(sampler, outTextureCoords);
}
