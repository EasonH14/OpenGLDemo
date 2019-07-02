
attribute vec4 position;
attribute vec2 textureCoords;

varying highp vec2 outTextureCoords;

uniform float time;

const float PI = 3.1415926;

void main() {
    outTextureCoords = textureCoords;
    
    float duration = 0.8;
    
    float maxAmplitude = 0.3;
    
    float ct = mod(time, duration);
    
    float scale = 1.0 + maxAmplitude * abs(sin(PI * ct / duration));
    
    gl_Position = vec4(position.xy * scale, position.zw);
}
