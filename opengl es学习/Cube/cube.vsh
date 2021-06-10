
attribute lowp vec4 position;
attribute lowp vec2 coordPosition;
attribute lowp  vec3 normal;
varying lowp vec2 varyingCoordPosition;
varying lowp vec4 varyingPosition;
varying lowp vec3 varyingFragNormal;
uniform mat4 modalMat;
void main() {
    varyingCoordPosition = coordPosition;
    varyingPosition = position;
    varyingFragNormal = normal;
    gl_Position = modalMat * position;
}
