
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const float sideLen_2 = 0.015;

void main() {
    
    vec2 uv = outTextureCoords;
    
    int column = int(uv.x / sideLen_2);
    int row = int(uv.y / sideLen_2);
    
    bool evenC = column/2 * 2 == column;
    
    vec2 v1, v2, vn;
    
    if (evenC) {
        v1 = vec2(float(column) * sideLen_2, float(row) * sideLen_2);
        v2 = vec2(float(column + 1) * side_len_2, float(row + 1) * sideLen_2);
    }
    else {
        v1 = vec2(float(column + 1) * sideLen_2, float(row) * sideLen_2);
        v2 = vec2(float(column) * sideLen_2, float(row + 1) * sideLen_2);
    }
    
    
    
}
