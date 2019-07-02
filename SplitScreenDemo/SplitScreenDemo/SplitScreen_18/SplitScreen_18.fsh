
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

uniform float time;

const float PI = 3.1415926;

void main() {
    
    float duration = 0.6;
    
    float progress = mod(time, duration) / duration;
    
    float alpha = abs(sin(PI * progress));
    
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0) * alpha + texture2D(sampler, outTextureCoords) * (1.0 - alpha);
}
