uniform float iTime;
uniform vec2 iResolution;
uniform sampler2D iChannel0;

float Scale1 = 0.3;
float Scale2 = 3.5;
float Amp = 20.0;
float FreqX = 30.0;
float FreqY = 30.0;

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p ); 
    return f;
}
// --- End of: Created by inigo quilez --------------------
float mynoise ( vec3 p)
{
	 return noise(p);
	 //return .5+.5*sin(50.*noise(p));
}
float myfbm( vec3 p )
{
    float f;
    f  = 0.5000*mynoise( p ); p = m*p*2.02;
    f += 0.2500*mynoise( p ); p = m*p*2.03;
    f += 0.1250*mynoise( p ); p = m*p*2.01;
    f += 0.0625*mynoise( p ); p = m*p*2.05;
    f += 0.0625/2.*mynoise( p ); p = m*p*2.02;
    f += 0.0625/4.*mynoise( p );
    return f;
}
float myfbm2( vec3 p )
{
    float f;
    f  = 1. - 0.5000*mynoise( p ); p = m*p*2.02;
    f *= 1. - 0.2500*mynoise( p ); p = m*p*2.03;
    f *= 1. - 0.1250*mynoise( p ); p = m*p*2.01;
    f *= 1. - 0.0625*mynoise( p ); p = m*p*2.05;
    f *= 1. - 0.0625/2.*mynoise( p ); p = m*p*2.02;
    f *= 1. - 0.0625/4.*mynoise( p );
    return f;
}
  void main() {

    vec2 uv = gl_FragCoord.xy / iResolution.y;
    vec3 v;
    vec3 p = Scale2*vec3(uv,0.)-iTime*(1.0, 1.0, 1.0)*0.1;
    float x = myfbm(p);
    v = (.5+.5*sin(x*vec3(FreqX, FreqY, 1.0)*Scale1))/Scale1;
    v *= Amp;
    vec3 Ti = texture(iChannel0,.02*v.xy+gl_FragCoord.xy / iResolution.xy).rgb;
    gl_FragColor = vec4(Ti,1.0);
  }