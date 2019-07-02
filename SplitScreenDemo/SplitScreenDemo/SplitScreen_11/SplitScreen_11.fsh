
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const float mosaicSize = 0.02;

void main() {
    
    float len = mosaicSize;
    float TR = 0.866025;
    float TC = 1.5;
    
    float x = outTextureCoords.x;
    float y = outTextureCoords.y;
    
    int column = int(x / (len * TC));
    int row = int(y / (len * TR));
    
    vec2 v1, v2, vn;
    
    bool r = mod(float(row), 2.0) == 0.0;
    bool c = mod(float(column), 2.0) == 0.0;
    
    if (r == c) {
        v1 = vec2(len * TC * float(column), len * TR * float(row));
        v2 = vec2(len * TC * float(column + 1), len * TR * float(row + 1));
    }
    else {
        v1 = vec2(len * TC * float(column + 1), len * TR * float(row));
        v2 = vec2(len * TC * float(column), len * TR * float(row + 1));
    }
    
    float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    
    if (s1 < s2) {
        vn = v1;
    }
    else {
        vn = v2;
    }
    
    gl_FragColor = texture2D(sampler, vn);
    
}
