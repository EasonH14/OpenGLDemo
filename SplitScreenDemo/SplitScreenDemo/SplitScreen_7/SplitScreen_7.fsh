
precision highp float;

uniform sampler2D sampler;

varying highp vec2 outTextureCoords;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main() {
    
    highp vec4 color = texture2D(sampler, outTextureCoords);
    
    highp float luminance = dot(color.rgb, W);
    
    gl_FragColor = vec4(vec3(luminance), 1.0);
}
