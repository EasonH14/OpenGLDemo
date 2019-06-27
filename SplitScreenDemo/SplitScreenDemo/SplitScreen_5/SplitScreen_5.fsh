
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    
    highp vec2 uv = outTextureCoords;
    
    highp float oneDivideThree = 1.0/3.0;
    highp float twoDivideThree = 2.0/3.0;
    
    if (uv.s <= oneDivideThree) {
        uv.s += oneDivideThree;
    }
    else if (uv.s > twoDivideThree) {
        uv.s -= oneDivideThree;
    }
    
    if (uv.t <= 0.5) {
        uv.t += 0.25;
    } else {
        uv.t -= 0.25;
    }
    
    gl_FragColor = texture2D(sampler, uv);
}
