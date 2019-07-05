varying lowp vec4 varyColor;
varying lowp vec2 varyTextureCoord;
uniform sampler2D sampler;

void main() {
    gl_FragColor = varyColor;
}
