//
// Copyright (c) 2009 Mikko Mononen memon@inside.org
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
//

#ifndef MATHUTIL_H
#define MATHUTIL_H

#define _USE_MATH_DEFINES
#include <math.h>

inline float lerp(float a, float b, float t) { return a + (b-a)*t; }
inline float min(float a, float b) { return a < b ? a : b; }
inline float max(float a, float b) { return a > b ? a : b; }
inline float clamp(float a, float mn, float mx) { return a < mn ? mn : (a > mx ? mx : a); }
inline float sqr(float x) { return x*x; }
inline float saturate(float x) { return x<0 ? 0 : (x>1 ? 1 : x); }
inline float smoothstep(float e0, float e1, float x)
{
    x = saturate((x-e0) / (e1-e0)); 
    return x*x*(3-2*x);
}

template<class T> inline void swap(T& a, T& b) { T t = a; a = b; b = t; }

inline float awrap(float a)
{
	while (a < -M_PI) a += M_PI*2;
	while (a > M_PI) a -= M_PI*2;
	return a;
}


inline float vdistsqr(const float* a, const float* b) { return sqr(b[0]-a[0]) + sqr(b[1]-a[1]); }
inline float vdist(const float* a, const float* b) { return sqrtf(vdistsqr(a,b)); }
inline void vcpy(float* a, const float* b) { a[0]=b[0]; a[1]=b[1]; }
inline float vdot(const float* a, const float* b) { return a[0]*b[0] + a[1]*b[1]; }
inline float vperp(const float* a, const float* b) { return a[0]*b[1] - a[1]*b[0]; }
inline void vsub(float* v, const float* a, const float* b) { v[0] = a[0]-b[0]; v[1] = a[1]-b[1]; }
inline void vadd(float* v, const float* a, const float* b) { v[0] = a[0]+b[0]; v[1] = a[1]+b[1]; }
inline void vscale(float* v, const float* a, const float s) { v[0] = a[0]*s; v[1] = a[1]*s; }
inline void vset(float* v, float x, float y) { v[0]=x; v[1]=y; }
inline float vlensqr(const float* v) { return vdot(v,v); }
inline float vlen(const float* v) { return sqrtf(vlensqr(v)); }
inline void vlerp(float* v, const float* a, const float* b, float t) { v[0] = lerp(a[0], b[0], t); v[1] = lerp(a[1], b[1], t); }
inline void vmad(float* v, const float* a, const float* b, float s) { v[0] = a[0] + b[0]*s; v[1] = a[1] + b[1]*s; }
inline void vnorm(float* v)
{
	float d = vlen(v);
	if (d > 0.0001f)
	{
		d = 1.0f/d;
		v[0] *= d;
		v[1] *= d;
	}
}
inline void vsetlen(float* v, const float len)
{
	float d = vlen(v);
	if (d > 0.0001f)
	{
		d = len/d;
		v[0] *= d;
		v[1] *= d;
	}
}


inline float triarea(const float* a, const float* b, const float* c)
{
	return (b[0]*a[1] - a[0]*b[1]) + (c[0]*b[1] - b[0]*c[1]) + (a[0]*c[1] - c[0]*a[1]);
}

int sweepCircleCircle(const float* c0, const float r0, const float* v,
					  const float* c1, const float r1,
					  float& tmin, float& tmax);

int sweepCircleSegment(const float* c0, const float r0, const float* v,
					   const float* sa, const float* sb, const float sr,
					   float& tmin, float &tmax);

int isectRayCircle(const float* p, const float* d,
				   const float* sc, const float sr,
				   float& t);

void closestPtPtSeg(const float* pt,
					const float* sp, const float* sq,
					float& t);

void closestPtSegSeg(const float* ap, const float* aq,
					 const float* bp, const float* bq,
					 float& s, float& t);

float distSegSegSqr(const float* ap, const float * aq,
					const float* bp, const float* bq);

float distPtSegSqr(const float* pt, const float* sp, const float* sq);

int isectSegSeg(const float* ap, const float* aq,
				const float* bp, const float* bq,
				float& s, float& t);

int isectSegCircle(const float* p1, const float* p2,
				   const float* sc, float r, float* t);

bool intersectSegmentPoly(const float* p0, const float* p1,
						  const float* verts, int nverts,
						  float& tmin, float& tmax,
						  int& segMin, int& segMax);

int convexhull(const float* pts, int npts, int* out);

int pnpoly(int nvert, const float* verts, const float* p);

float polyarea(const float* verts, const int nverts);

inline bool pointInBounds(const float* p, const float* bmin, const float* bmax)
{
	return	p[0] >= bmin[0] && p[0] <= bmax[0] &&
			p[1] >= bmin[1] && p[1] <= bmax[1];
}

inline bool overlapBounds(const float* amin, const float* amax, const float* bmin, const float* bmax)
{
	bool overlap = true;
	overlap = (amin[0] > bmax[0] || amax[0] < bmin[0]) ? false : overlap;
	overlap = (amin[1] > bmax[1] || amax[1] < bmin[1]) ? false : overlap;
	return overlap;
}


#endif // MATHUTIL_H