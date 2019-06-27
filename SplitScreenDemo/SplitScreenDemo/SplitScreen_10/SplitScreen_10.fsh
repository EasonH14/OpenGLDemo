
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const vec2 textSize = vec2(400.0, 400.0);
const vec2 mosaicSize = vec2(16.0, 16.0);

void main() {
    
    vec2 uv = outTextureCoords;
    uv = vec2(uv.s * textSize.x, uv.t * textSize.y);
    uv = vec2(floor(uv.s/mosaicSize.x) * mosaicSize.x, floor(uv.t/mosaicSize.y) * mosaicSize.y);
    uv = vec2(uv.s/textSize.x, uv.t/textSize.y);
    
    gl_FragColor = texture2D(sampler, uv);
}
