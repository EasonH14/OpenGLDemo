
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    
    highp vec2 uv = outTextureCoords;
    
    if (uv.s <= 0.5) {
        uv.s *= 2.0;
    }
    else {
        uv.s = (uv.s - 0.5) * 2.0;
    }
    
    if (uv.t <= 0.5) {
        uv.t *= 2.0;
    } else {
        uv.t = (uv.t - 0.5) * 2.0;
    }
    
    gl_FragColor = texture2D(sampler, uv);
}
