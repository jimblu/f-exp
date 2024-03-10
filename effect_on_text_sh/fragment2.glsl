uniform float iTime;
uniform vec2 iResolution;
uniform sampler2D iChannel0;

#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926538

// uniform float time;
// uniform vec2 resolution;

//	Classic Perlin 3D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

// https://math.stackexchange.com/questions/100655/cosine-esque-function-with-flat-peaks-and-valleys
// ranges from 0.0 to 1.0
float flatSin(float x, float b) {
  float num = 1.0 + b*b;
  float den = 1.0 + b*b*cos(x)*cos(x);
  float y = sqrt(num / den) * cos(x);

  return y * 0.5 + 0.5;
}

// https://gist.github.com/983/e170a24ae8eba2cd174f#file-frag-glsl-L19
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float rand(vec2 co){
  return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 randomize(vec2 uv, vec4 color) {
  float noiseLevel = 0.2;

  vec2 center = vec2(0.5, 0.5);
  vec2 delta = uv - center;
  float value = length(delta) / 0.70710678;

  float r = rand(uv);

  return color * (1.0 - noiseLevel) + r * noiseLevel;
}

vec4 colorGradient2(vec2 coord) {
  
  vec2 center = vec2(0.5, 0.5);
  vec2 delta = coord - center;

  // float hue = (atan(delta.y, delta.x) + 0.5 * PI) / (2 * PI);
  // float sat = length(delta) / 0.70710678;
  float value = 1.0 - length(delta) / 0.70710678; // 1.0; // sin(time) * 0.5 + 0.5;

  // float value2 = step(0.0, sin(value * 100.0));
  float value2 = flatSin(0.4 * 100.0 * value, 4.0);
  vec4 col = vec4(vec3(value2), 1.0);

  vec4 rCol = randomize(coord, col);

  return rCol;
  


  // return vec4(hsv2rgb(vec3(hue, sat, value2)), 1.0);
}


vec4 boundedTextureColor(vec2 coord) {
  vec2 newCoord;
  newCoord.x = max(min(coord.x, 1.0), 0.0);
  newCoord.y = max(min(coord.y, 1.0), 0.0);

  return colorGradient2(newCoord);
}



vec4 liquify(vec2 fragCoord, float currTime) {
  float timeScale = 0.1;

  vec2 uv = fragCoord / (1.0 * iResolution.xy);
  float dx = cnoise(vec3(0.9 * 2.0 * uv, currTime * timeScale));
  float dy = cnoise(vec3(0.9 * 3.0 * uv, 134.0 + currTime * timeScale));
  uv.x += dx * 0.8;
  // uv.y += dy * 0.08;

  vec4 col = colorGradient2(uv);
  

  return col;
}
  void main() {

    float timeDelay = 0.08;
    
    vec4 r = liquify(gl_FragCoord.xy, iTime);
    vec4 g = liquify(gl_FragCoord.xy, iTime + timeDelay);
    vec4 b = liquify(gl_FragCoord.xy, iTime + 2.0*timeDelay);
    
    vec4 color = vec4(r.x, g.y, b.z, 1.0);
    
    gl_FragColor = color;
    
    

    // Normalized pixel coordinates (from 0 to 1)
    // vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    // vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    // fragColor = vec4(col,1.0);
  }