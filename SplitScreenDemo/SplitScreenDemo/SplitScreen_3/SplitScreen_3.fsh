
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    
    highp vec2 uv = outTextureCoords;
    
    if (uv.x <= 0.5 && uv.y > 0.5) {
        uv.x *= 2.0;
        uv.y = (uv.y - 0.5) * 2.0;
    }
    else if (uv.x > 0.5 && uv.y > 0.5) {
        uv.x = (uv.x - 0.5) * 2.0;
        uv.y = (uv.y - 0.5) * 2.0;
    }
    else {
        uv.y += 0.25;
    }
    
    gl_FragColor = texture2D(sampler, uv);
}
