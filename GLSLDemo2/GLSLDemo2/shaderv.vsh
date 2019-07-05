attribute vec4 position;
attribute vec4 color;
attribute vec2 textureCoord;

uniform mat4 rotateMatrix;
uniform mat4 projectionMatrix;

varying lowp vec4 varyColor;
varying lowp vec2 varyTextureCoord;

void main() {
    
    varyColor = color;
    varyTextureCoord = textureCoord;
    
    gl_Position = projectionMatrix * rotateMatrix * position;
}
