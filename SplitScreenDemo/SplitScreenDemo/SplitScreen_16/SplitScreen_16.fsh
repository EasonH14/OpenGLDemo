
precision highp float;

varying highp vec2 outTextureCoords;

uniform sampler2D sampler;

uniform float time;

void main() {
    
    float duration = 0.6;
    float maxAlpha = 0.5;
    float maxAmplitude = 0.3;
    
    float mt = mod(time, duration);
    float alpha = maxAlpha * (1.0 - mt / duration);
    float scale = 1.0 + maxAmplitude * mt / duration;
    
    vec2 uv = 0.5 + (outTextureCoords - 0.5) / scale;

    vec3 sourceColor = texture2D(sampler, outTextureCoords).rgb;
    vec3 destinateColor = texture2D(sampler, uv).rgb;
    
    gl_FragColor = vec4(sourceColor * (1.0 - alpha) + destinateColor * alpha, 1.0);
}
