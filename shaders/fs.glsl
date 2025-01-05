#ifdef GL_ES
precision mediump float;
#endif
 
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_propratio;
 
#define SEED 1234.1234
#define CAMERADIST 4.5

// craters based on the following examples
// https://www.shadertoy.com/view/MtjGRD


#define PI 3.14159265359

// https://www.shadertoy.com/view/XdBGzd
// The MIT License
// Copyright © 2014 Inigo Quilez
float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}


#define ITERATIONS 4


// *** Change these to suit your range of random numbers..

// *** Use this for integer stepped ranges, ie Value-Noise/Perlin noise functions.
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(.1031, .1030, .0973, .1099)

float hash( in vec2 p ) 
{
    return fract(sin(dot(p, vec2(39.786792357-SEED, 59.4583127+SEED))) * 43758.236237153);
}

float hash13(vec3 p3)
{
    p3  = fract(p3 * HASHSCALE1);
    p3 += dot(p3, p3.yzx + SEED);
    return fract((p3.x + p3.y) * p3.z);
}

///  3 out, 3 in...
vec3 hash33(vec3 p3)
{
        p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz + SEED);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}


// By David Hoskins, May 2014. @ https://www.shadertoy.com/view/4dsXWn
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float Noise(in vec3 p)
{
    vec3 i = floor(p);
        vec3 f = fract(p); 
        f *= f * (3.0-2.0*f);

    return mix(
                mix(mix(hash13(i + vec3(0.,0.,0.)), hash13(i + vec3(1.,0.,0.)),f.x),
                        mix(hash13(i + vec3(0.,1.,0.)), hash13(i + vec3(1.,1.,0.)),f.x),
                        f.y),
                mix(mix(hash13(i + vec3(0.,0.,1.)), hash13(i + vec3(1.,0.,1.)),f.x),
                        mix(hash13(i + vec3(0.,1.,1.)), hash13(i + vec3(1.,1.,1.)),f.x),
                        f.y),
                f.z);
}

const mat3 m = mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 ) * 1.7;

float FBM( vec3 p )
{
    float f;

        f = 0.5000 * Noise(p); p = m*p;
        f += 0.2500 * Noise(p); p = m*p;
        f += 0.1250 * Noise(p); p = m*p;
        f += 0.0625   * Noise(p); p = m*p;
        f += 0.03125  * Noise(p); p = m*p;
        f += 0.015625 * Noise(p);
    return f;
}

float craters(in vec3 x) {
	// craters based off of
	// https://www.shadertoy.com/view/ldtXWf
	// https://www.shadertoy.com/view/XsGBDt

	// 3d "fourier series" noise map

    vec3 p = floor(x);
    vec3 f = fract(x);
    float fourier = 0.0;
    float ampTotal = 0.0;

	const float condense = -4.0;

	// Drawing a 2 by 2 cube and iterating the vertices / points
    for (int i = -2; i <= 2; i++) 
	for (int j = -2; j <= 2; j++)
	for (int k = -2; k <= 2; k++) {
        vec3 cubeVec = vec3(i,j,k);
        vec3 rand = 0.8 * hash33(p + cubeVec);

		// the more distance (f - cubeVec) away from what is assigned "random" at cubeVec point
		// 3d noise cube
		// smoothly interpolate the points on cube
		// means exponential decay

        float d = distance(f - cubeVec, rand);
        float amp = exp(condense * d);

		// frequency at sqrt(x) creates a different sine wave
		// mimics the shape of a crater
        fourier += amp * sin(2.0*PI * sqrt(d));
        ampTotal += amp;
	}
    return abs(fourier / ampTotal);
}

float surface(in vec2 uv) {
	float lat = 180. * uv.y - 90.;
    float lon = 360. * uv.x;

	// mapping 2d cartesian longitude v. latitude onto a sphere
	float roughness = 3.5;
	vec3 p = roughness * vec3(sin(lon*PI/180.0) * cos(lat*PI/180.0), sin(lat*PI/180.0), cos(lon*PI/180.0) * cos(lat*PI/180.0));

	float res = 0.0;
	const float spacing = 3.2;
	for (float i = 0.0; i < 5.0; i++) {
		// less spaced out for i increases exponentially
        float c = craters(0.5 * pow(spacing, i) * p);

		// add crater noise. Decays 
        float noise = 0.4 * exp(-4.0 * c) * FBM(10. * p);

		// higher amplitude at higher frequencies
        float w = clamp(3.0 * pow(0.4, i), 0.0, 1.0);
		res += w * (c + noise);
	}

	return res;
}

float map(vec3 p) {
	// convert 3d vector into 2d vector for height value.

	// map(p) -> map(lon, lat) -> height

	// 90 - arccos( y / R) * 180 / PI
    float lat = 90.0 - acos(p.y / length(p)) * 180./PI;
    float lon = atan(p.x, p.z) * 180./PI;
    vec2 uv = vec2(lon/360., lat/180.) + 0.5;

    return surface(uv);
}


vec3 nMoon(vec3 p) {
	vec2 e = vec2(1.0,0.0)/1e3;
	// ((f + dx) - (f - dx)) / (2 dx) 
	
    p += 0.01 * vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx))/ (2.0 * length(e));
	return normalize(p);
}

float iStars(in vec3 ro, in vec3 rd) {
	// pseudorandom in 2d

	// ro.z + rd.z * t = 0
	float t = -ro.z / rd.z;

	vec3 R = rd * t;
	float phi_x = acos(ro.z/R.x);
	float theta_y = acos(ro.z/R.y);

	if (hash(vec2(phi_x, theta_y)) > 0.99) {
		return 1.0;
	}

	return -1.0;
}

vec4 sphere = vec4(0.0, 0.0, 0.0, 1.0);

int intersect( in vec3 ro, in vec3 rd, out float t)
{
    t = 1000.0;
    int id = -1; // by default, it will be a miss
    float tsph = iSphere(ro, rd, sphere);
    
    // reports hits and update t
    if (tsph > 0.0) {
        // report hit, you set the order
        id = 1;
        t = tsph;
    }
	else {
		// too slow rn
    	// float tstars = iStars(ro, rd);
		// if (tstars > 0.0) {
		// 	id = 2;
		// 	t = tstars; // not relevant information
		// }
	}
    
    return id;
}


void main() {

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = gl_FragCoord.xy / u_resolution.y;
    uv += vec2(-0.4, -0.4);
    
    float time = 0.2 * u_time;
    mat3 rotate = mat3( vec3(cos(time), 0.0, sin(time)),
                        vec3(0.0, 1.0, 0.0),
                        vec3(-sin(time), 0.0, cos(time))
                      );
    vec3 ro = vec3(0.0, 0.0, CAMERADIST);
    vec3 rd = normalize( vec3( uv, -2.0) );
    vec3 light = vec3(1.0, 1.0, 1.0);

    ro *= rotate;
    rd *= rotate;
	light *= rotate;
    
    float t = -1.0;
    int id = intersect(ro, rd, t);
    
    
    vec3 col = vec3(0.0);
    
    if ( id == 1 )
    {
        // if we hit sphere
        vec3 pos = ro + t*rd;

		float height = map(pos - sphere.xyz);
        vec3 norm = nMoon(pos);
		
        float intensity = 0.4 * dot(light, norm);
        
        // inverse square law
        float r = length(light - pos);
        intensity = intensity / (r*r);

		col = intensity * mix(vec3(0.58, 0.57, 0.55), vec3(0.15, 0.13, 0.1), smoothstep(0.0, 3.0, height));
    }
    
    gl_FragColor = vec4(col,1.0);
}