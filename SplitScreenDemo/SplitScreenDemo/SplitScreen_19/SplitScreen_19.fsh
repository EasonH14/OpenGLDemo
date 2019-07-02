
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

uniform float time;

const float PI = 3.1415926;

float rand(float n) {
    return fract(sin(n) * 45345.23435423);
}

void main() {
    
    float maxJitter = 0.06;
    
    float duration = 0.3;
    
    float colorRedOffset = 0.01;
    
    float colorBlueOffset = -0.025;
    
    float t = mod(time, duration * 2.0);
    
    float amplitude = max(sin(t * (PI/duration)), 0.0);
    
    float jitter = rand(outTextureCoords.y) * 2.0 - 1.0;
    
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = outTextureCoords.x + (needOffset ? jitter : jitter * amplitude * 0.006);
    
    vec2 uv = vec2(textureX, outTextureCoords.y);
    
    vec4 mask = texture2D(sampler, uv);
    
    vec4 maskRed = texture2D(sampler, uv + vec2(colorRedOffset * amplitude, 0.0));
    
    vec4 maskBlue = texture2D(sampler, uv + vec2(colorBlueOffset * amplitude, 0.0));
    
    gl_FragColor = vec4(maskRed.r, mask.g, maskBlue.b, mask.a);
}
