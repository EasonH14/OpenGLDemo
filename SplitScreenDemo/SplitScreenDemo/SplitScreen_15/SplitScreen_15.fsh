
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

uniform float time;

const float PI = 3.1415926;

void main() {
    
    float duration = 0.8;
    
    float maxAmplitude = 0.3;
    
    float mt = mod(time, duration);
    
    float scale = 1.0 + maxAmplitude * abs(sin(PI * mt / duration));
    
    vec2 uv = 0.5 + (outTextureCoords - 0.5) / scale;
    
    gl_FragColor = texture2D(sampler, uv);
    
}
