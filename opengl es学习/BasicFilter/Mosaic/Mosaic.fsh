precision highp float;
uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main (void) {
    vec2  MosaicXY = vec2(ceil(TextureCoordsVarying.x*400.0/19.0)*19.0,ceil(TextureCoordsVarying.y*400.0/19.0)*19.0);
    vec2  MosaicMask = vec2(MosaicXY.x/400.0,MosaicXY.y/400.0);
    vec4 mask = texture2D(Texture, MosaicMask);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
