
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

uniform float time;

void main() {
    
    float duration = 0.7;
    float amplitude = 0.1;
    float offset = 0.02;
    
    float progress = mod(time, duration) / duration;
    
    vec2 offsetCoords = vec2(offset, offset) * progress;
    
    float scale = 1.0 + amplitude * progress;
    
    vec2 uv = 0.5 + (outTextureCoords - 0.5) / scale;
    
    vec4 maskR = texture2D(sampler, uv + offsetCoords);
    vec4 maskB = texture2D(sampler, uv - offsetCoords);
    vec4 mask = texture2D(sampler, uv);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
