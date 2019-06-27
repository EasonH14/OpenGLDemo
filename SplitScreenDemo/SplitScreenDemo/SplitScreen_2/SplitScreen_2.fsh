
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    
    highp vec2 uv = outTextureCoords;
    if (uv.s < 0.5) {
        uv.s += 0.25;
    }
    else {
        uv.s -= 0.25;
    }
    
    gl_FragColor = texture2D(sampler, uv);
}
