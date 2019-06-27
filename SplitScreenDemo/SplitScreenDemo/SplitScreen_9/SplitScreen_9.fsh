
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const float uD = 80.0;
const float uR = 0.16;


void main() {
    
    highp vec2 uv = outTextureCoords;
    
    vec2 center = vec2(uR, uR);
    float dia = uR * 2.0;
    
    if (uv.s <= dia && uv.t >= 1.0 - dia) {
        center = vec2(uR, 1.0 - uR);
    }
    else if (uv.s >= 1.0 - dia && uv.t <= dia) {
        center = vec2(1.0 - uR, uR);
    }
    else if (uv.s >= 1.0 - dia && uv.t >= 1.0 - dia) {
        center = vec2(1.0 - uR, 1.0 - uR);
    }
    
    vec2 duv = uv - center;
    float r = length(duv);
    
    float beta = atan(duv.t, duv.s) + radians(uD) * 2.0 * (1.0 - (r/uR) * (r/uR));
    
    if (r <= uR) {
        uv = center + r * vec2(cos(beta), sin(beta));
    }
    
    gl_FragColor = texture2D(sampler, uv);
    
}
