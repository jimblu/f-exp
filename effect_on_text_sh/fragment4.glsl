uniform float iTime;
uniform vec2 iResolution;
uniform sampler2D iChannel0;
uniform vec2 iMouse;


  void main() {
    vec2 st = (gl_FragCoord.xy * 2. - iResolution.xy) / min(iResolution.x, iResolution.y);
    
    st *= 2.5;

    vec2 coord = st;
    float len;
    for (int i = 0; i < 3; i++) {
        len = length(coord);
        coord.x +=  sin(coord.y + iTime * 0.3)*1.;
        coord.y +=  cos(coord.x + iTime * 0.1 + cos(len * 1.0))*6.;
    }
         
    vec3 col = vec3(0.);

    col = mix(col, vec3(cos(len)), 1.0);
    
    gl_FragColor = vec4(0.7*col,1.); 
  }