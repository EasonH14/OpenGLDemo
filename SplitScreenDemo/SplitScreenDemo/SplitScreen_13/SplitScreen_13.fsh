
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const float mosaicSize = 0.09;

void main() {
    
    float len = mosaicSize;
    const float PI6 = 0.523599;
    const float PI = 3.1415926;
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
    
    float a = atan((y - vn.y)/(x - vn.x));
    if (a > 0.0 && x < vn.x) {
        a += PI;
    }
    else if (a < 0.0 && y < vn.y) {
        a += PI;
    }
    
    float theta = atan(TR * 2.0);
    
    vec2 area1 = vec2(vn.x + mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
    vec2 area2 = vec2(vn.x, vn.y + mosaicSize * TR / 2.0);
    vec2 area3 = vec2(vn.x - mosaicSize / 2.0, vn.y + mosaicSize * TR / 2.0);
    vec2 area4 = vec2(vn.x - mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);
    vec2 area5 = vec2(vn.x, vn.y - mosaicSize * TR / 2.0);
    vec2 area6 = vec2(vn.x + mosaicSize / 2.0, vn.y - mosaicSize * TR / 2.0);
    
    
    if (a >= 0.0 && a < theta) {
        vn = area1;
    } else if (a >= theta && a < PI - theta) {
        vn = area2;
    } else if (a >= PI - theta && a < PI) {
        vn = area3;
    } else if (a >= PI && a < PI + theta) {
        vn = area4;
    } else if(a >= PI + theta && a < 2.0 * PI - theta) {
        vn = area5;
    } else {
        vn = area6;
    }
    
    gl_FragColor = texture2D(sampler, vn);
    
}
