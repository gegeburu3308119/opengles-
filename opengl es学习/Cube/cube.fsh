precision highp float;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;
uniform sampler2D texture5;

varying  lowp  vec3 varyingFragNormal;
varying lowp vec2 varyingCoordPosition;
varying lowp vec4 varyingPosition;

uniform mat4 normalMatrix;
uniform vec3 lightDirection;

void main() {
    
    vec3 normalizedLightDirection = normalize(-lightDirection);
    vec3 transformedNormal = normalize((normalMatrix*vec4(varyingFragNormal,1.0)).xyz);
    float diffuseStrength = dot(normalizedLightDirection,transformedNormal);
    diffuseStrength = clamp(diffuseStrength,0.0,1.0);
    vec3 diffuse = vec3(diffuseStrength);
    vec3 ambient = vec3(0.3);
    
    vec4 color;
    if(varyingPosition.z == 0.5)
        color = texture2D(texture0,varyingCoordPosition);//front
       if(varyingPosition.x == 0.5)
           color = texture2D(texture1,varyingCoordPosition);//right
       if(varyingPosition.z == -0.5)
           color = texture2D(texture2,varyingCoordPosition);//back
       if(varyingPosition.x == -0.5)
           color = texture2D(texture3,varyingCoordPosition);//left
       if(varyingPosition.y == 0.5)
           color = texture2D(texture4,varyingCoordPosition);//top
       if(varyingPosition.y == -0.5)
           color = texture2D(texture5,varyingCoordPosition);//bottom
    
       vec4 finalLightStrength = vec4(ambient+diffuse,1.0);
       gl_FragColor = finalLightStrength * color;
}
