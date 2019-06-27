
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

void main() {
    
    highp vec2 uv = outTextureCoords;
    
    highp float oneDivideThree = 1.0/3.0;
    highp float twoDivideThree = 2.0/3.0;
    
    if (uv.s <= oneDivideThree) {
        uv.s *= 3.0;
    }
    else if (uv.s > twoDivideThree) {
        uv.s = uv.s * 3.0 - 2.0;
    }
    else {
        uv.s = uv.s * 3.0 - 1.0;
    }
    
    if (uv.t <= oneDivideThree) {
        uv.t *= 3.0;
    }
    else if (uv.t > twoDivideThree) {
        uv.t = uv.t * 3.0 - 2.0;
    }
    else {
        uv.t = uv.t * 3.0 - 1.0;
    }
    
    gl_FragColor = texture2D(sampler, uv);
}
