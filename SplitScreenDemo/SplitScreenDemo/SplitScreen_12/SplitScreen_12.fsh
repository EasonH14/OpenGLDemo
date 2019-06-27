
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const float r = 0.02;

void main() {
    
    vec2 uv = outTextureCoords;
    
    int row = int(uv.y / r);
    int column = int(uv.x / r);
    
    vec2 v1, v2, vn;
    
    bool evenR = row/2 * 2 == row;
    bool evenC = column/2 * 2 == column;
    
    if (evenR == evenC) {
        v1 = vec2(r * float(column), r * float(row));
        v2 = vec2(r * float(column + 1), r * float(row + 1));
    }
    else {
        v1 = vec2(r * float(column + 1), r * float(row));
        v2 = vec2(r * float(column), r * float(row + 1));
    }
    
    float s1 = sqrt(pow(v1.x - uv.x, 2.0) + pow(v1.y - uv.y, 2.0));
    float s2 = sqrt(pow(v2.x - uv.x, 2.0) + pow(v2.y - uv.y, 2.0));
    
    if (evenR == true) {
        if (s2 < r) {
            vn = v2;
        }
        else {
            vn = v1;
        }
    }
    else {
        if (s1 < r) {
            vn = v1;
        }
        else {
            vn = v2;
        }
    }
    
    
    gl_FragColor = texture2D(sampler, vn);
}
