
attribute vec4 position;
attribute vec2 textureCoords;

varying highp vec2 outTextureCoords;

void main() {
    
    gl_Position = position;
    outTextureCoords = textureCoords;
}
