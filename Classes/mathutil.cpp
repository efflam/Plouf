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

#include "mathutil.h"
#include <float.h>


int sweepCircleCircle(const float* c0, const float r0, const float* v,
					  const float* c1, const float r1,
					  float& tmin, float& tmax)
{
	static const float EPS = 0.0001f;
	float s[2];
	vsub(s,c1,c0);
	float r = r0+r1;
	float c = vdot(s,s) - r*r;
	float a = vdot(v,v);
	if (a < EPS) return 0;	// not moving
	
	// Overlap, calc time to exit.
	float b = vdot(v,s);
	float d = b*b - a*c;
	if (d < 0.0f) return 0; // no intersection.
	tmin = (b - sqrtf(d)) / a;
	tmax = (b + sqrtf(d)) / a;
	return 1;
}

int sweepCircleSegment(const float* c0, const float r0, const float* v,
					   const float* sa, const float* sb, const float sr,
					   float& tmin, float &tmax)
{
	// equation parameters
	float L[2], H[2];
	vsub(L, sb, sa);
	vsub(H, c0, sa);
	const float radius = r0+sr;
	const float l2 = vdot(L, L);
	const float r2 = radius * radius;
	const float dl = vperp(v, L);
	const float hl = vperp(H, L);
	const float a = dl * dl;
	const float b = 2.0f * hl * dl;
	const float c = hl * hl - (r2 * l2);
	float d = (b*b) - (4.0f * a * c);
	
	// infinite line missed by infinite ray.
	if (d < 0.0f)
		return 0;
	
	const float i2a = 1.0f/(2*a);
	d = sqrt(d);
	tmin = (-b - d) * i2a;
	tmax = (-b + d) * i2a;
	
	// line missed by ray range.
/*	if (tmax < 0.0f || tmin > 1.0f)
		return 0;*/
	
	// find what part of the ray was collided.
	const float il2 = 1.0f / l2;
	float Pedge[2];
	vmad(Pedge, c0, v, tmin);
	vsub(H, Pedge, sa);
	const float e0 = vdot(H, L) * il2;
	vmad(Pedge, c0, v, tmax);
	vsub(H, Pedge, sa);
	const float e1 = vdot(H, L) * il2;
	
	if (e0 < 0.0f || e1 < 0.0f)
	{
		float ctmin, ctmax;
		if (sweepCircleCircle(c0, r0, v, sa, sr, ctmin, ctmax))
		{
			if (e0 < 0.0f && ctmin > tmin)
				tmin = ctmin;
			if (e1 < 0.0f && ctmax < tmax)
				tmax = ctmax;
		}
		else
		{
			return 0;
		}
	}
	
	if (e0 > 1.0f || e1 > 1.0f)
	{
		float ctmin, ctmax;
		if (sweepCircleCircle(c0, r0, v, sb, sr, ctmin, ctmax))
		{
			if (e0 > 1.0f && ctmin > tmin)
				tmin = ctmin;
			if (e1 > 1.0f && ctmax < tmax)
				tmax = ctmax;
		}
		else
		{
			return 0;
		}
	}
	
	return 1;
}


int isectRayCircle(const float* p, const float* d,
				   const float* sc, const float sr,
				   float& t)
{
	float m[2];
	vsub(m, p, sc);
    float b = vdot(m, d);
    float c = vdot(m, m) - sr*sr;
    if (c > 0.0f && b > 0.0f) return 0;
    float discr = b*b - c;
    if (discr < 0.0f) return 0;
    t = -b - sqrtf(discr);
    if (t < 0.0f) return 0;
    return 1;
}

void closestPtPtSeg(const float* pt,
					const float* sp, const float* sq,
					float& t)
{
	float dir[2],diff[3];
	vsub(dir,sq,sp);
	vsub(diff,pt,sp);
	t = vdot(diff,dir);
	if (t <= 0.0f) { t = 0; return; }
	float d = vdot(dir,dir);
	if (t >= d) { t = 1; return; }
	t /= d;
}

void closestPtSegSeg(const float* ap, const float* aq,
					 const float* bp, const float* bq,
					 float& s, float& t)
{
	const float EPSILON = 1e-6f;
	float d1[2], d2[2], r[2];
	vsub(d1, aq,ap);
	vsub(d2, bq,bp);
	vsub(r, ap,bp);
	const float a = vdot(d1,d1); // Squared length of segment S1, always nonnegative
	const float e = vdot(d2,d2); // Squared length of segment S2, always nonnegative
	const float f = vdot(d2,r);
	
	// Check if either or both segments degenerate into points
	if (a <= EPSILON && e <= EPSILON)
	{
		// Both segments degenerate into points
		s = t = 0.0f;
		return;
	}
	if (a <= EPSILON)
	{
		s = 0.0f;
		t = f / e;
		t = clamp(t, 0.0f, 1.0f);
	}
	else
	{
		const float c = vdot(d1,r);
		if (e <= EPSILON)
		{
			// Second segment degenerates into a point
			t = 0.0f;
			s = clamp(-c / a, 0.0f, 1.0f); // t = 0 => s = (b*t - c) / a = -c / a
		}
		else
		{
			// The general nondegenerate case starts here
			const float b = vdot(d1,d2);
			const float denom = a*e-b*b; // Always nonnegative
			
			// If segments not parallel, compute closest point on L1 to L2, and
			// clamp to segment S1. Else pick arbitrary s (here 0)
			if (denom != 0.0f)
				s = clamp((b*f - c*e) / denom, 0.0f, 1.0f);
			else
				s = 0.0f;
			
			// Compute point on L2 closest to S1(s) using
			// t = Dot((p.start+D1*s)-q.start,D2) / Dot(D2,D2) = (b*s + f) / e
			t = (b*s + f) / e;
			
			// If t in [0,1] done. Else clamp t, recompute s for the new value
			// of t using s = Dot((q.start+D2*t)-p.start,D1) / Dot(D1,D1)= (t*b - c) / a
			// and clamp s to [0, 1]
			if (t < 0.0f)
			{
				t = 0.0f;
				s = clamp(-c / a, 0.0f, 1.0f);
			}
			else if (t > 1.0f)
			{
				t = 1.0f;
				s = clamp((b - c) / a, 0.0f, 1.0f);
			}
		}
	}
}

float distSegSegSqr(const float* ap, const float * aq,
					const float* bp, const float* bq)
{
	float s,t;
	closestPtSegSeg(ap,aq, bp,bq, s,t);
	float anp[2], bnp[2];
	vlerp(anp, ap,aq, s);
	vlerp(bnp, bp,bq, t);
	return vdistsqr(anp,bnp);
}


float distPtSegSqr(const float* pt, const float* sp, const float* sq)
{
	float t;
	closestPtPtSeg(pt, sp,sq, t);
	float np[2];
	vlerp(np, sp,sq, t);
	return vdistsqr(pt,np);
}

int isectSegSeg(const float* ap, const float* aq,
				const float* bp, const float* bq,
				float& s, float& t)
{
	float u[2], v[2], w[2];
	vsub(u,aq,ap);
	vsub(v,bq,bp);
	vsub(w,ap,bp);
	float d = vperp(u,v);
	if (fabsf(d) < 1e-6f) return 0;
	s = vperp(v,w) / d;
	//	if (s < 0 || s > 1) return 0;
	t = vperp(u,w) / d;
	//	if (t < 0 || t > 1) return 0;
	return 1;
}

int isectSegCircle(const float* p1, const float* p2, const float* sc, float r, float* t)
{
	float dp[2], cp[2];
	vsub(dp,p2,p1);
	vsub(cp,p1,sc);
	const float a = vdot(dp,dp);
	const float b = 2 * vdot(dp,cp);
	const float c = vdot(sc,sc) + vdot(p1,p1) - 2*vdot(sc,p1) - r*r;
	const float bb4ac = b * b - 4 * a * c;
	const float EPS = 1e-6f;
	if (fabsf(a) < EPS || bb4ac < 0.0f)
		return 0;
	
	const float sbb4ac = sqrtf(bb4ac);
	const float d = 1.0f / (2 * a);
	const float t0 = (-b - sbb4ac) * d;
	const float t1 = (-b + sbb4ac) * d;
	
	int hits = 0;
	if (t0 >= 0.0f && t0 <= 1.0f)
		t[hits++] = t0;
	if (t1 >= 0.0f && t1 <= 1.0f)
		t[hits++] = t1;
	
	return hits;
}

bool intersectSegmentPoly(const float* p0, const float* p1,
						  const float* verts, int nverts,
						  float& tmin, float& tmax,
						  int& segMin, int& segMax)
{
	static const float EPS = 0.00000001f;
	
	tmin = -FLT_MAX; //0;
	tmax = FLT_MAX; //1;
	segMin = -1;
	segMax = -1;
	
	float dir[2];
	vsub(dir, p1, p0);
	
	for (int i = 0, j = nverts-1; i < nverts; j=i++)
	{
		float edge[2], diff[2];
		vsub(edge, &verts[i*2], &verts[j*2]);
		vsub(diff, p0, &verts[j*2]);
		float n = vperp(edge, diff);
		float d = -vperp(edge, dir);
		if (fabs(d) < EPS)
		{
			// S is nearly parallel to this edge
			if (n < 0)
				return false;
			else
				continue;
		}
		float t = n / d;
		if (d < 0)
		{
			// segment S is entering across this edge
			if (t > tmin)
			{
				tmin = t;
				segMin = j;
				// S enters after leaving polygon
				if (tmin > tmax)
					return false;
			}
		}
		else
		{
			// segment S is leaving across this edge
			if (t < tmax)
			{
				tmax = t;
				segMax = j;
				// S leaves before entering polygon
				if (tmax < tmin)
					return false;
			}
		}
	}
	
	return true;
}


// Returns true if 'c' is left of line 'a'-'b'.  
inline bool left(const float* a, const float* b, const float* c) 
{  
	const float u1 = b[0] - a[0]; 
	const float v1 = b[1] - a[1]; 
	const float u2 = c[0] - a[0]; 
	const float v2 = c[1] - a[1]; 
	return u1 * v2 - v1 * u2 < 0; 
} 
// Returns true if 'a' is more lower-left than 'b'.  
inline bool cmppt(const float* a, const float* b) 
{ 
	if (a[0] < b[0]) return true; 
	if (a[0] > b[0]) return false; 
	if (a[1] < b[1]) return true; 
	if (a[1] > b[1]) return false; 
	return false; 
} 

int convexhull(const float* pts, int npts, int* out) 
{ 
	// Find lower-leftmost point. 
	int hull = 0; 
	for (int i = 1; i < npts; ++i) 
		if (cmppt(&pts[i*2], &pts[hull*2])) 
			hull = i; 
	// Gift wrap hull.  
	int endpt = 0; 
	int i = 0; 
	do 
	{ 
		out[i++] = hull; 
		endpt = 0; 
		for (int j = 1; j < npts; ++j) 
			if (hull == endpt || left(&pts[hull*2], &pts[endpt*2], &pts[j*2])) 
				endpt = j; 
		hull = endpt; 
	} 
	while (endpt != out[0]); 
	return i; 
} 

int pnpoly(int nvert, const float* verts, const float* p)
{
	int i, j, c = 0;
	for (i = 0, j = nvert-1; i < nvert; j = i++)
	{
		const float* vi = &verts[i*2];
		const float* vj = &verts[j*2];
		if (((vi[1] > p[1]) != (vj[1] > p[1])) &&
			(p[0] < (vj[0]-vi[0]) * (p[1]-vi[1]) / (vj[1]-vi[1]) + vi[0]) )
			c = !c;
	}
	return c;
}

float polyarea(const float* verts, const int nverts)
{
	if (nverts < 3)
		return 0.0f;
	// Move the polygon closer to the origin when doing the calculations
	// to avoid loosing precision (the results are unusable past around 2000.0f).
	const float* orig = &verts[0];
	float area = 0.0f;
	for (int i = 0, j = nverts-1; i < nverts; j = i++)
	{
		const float* vj = &verts[j*2];
		const float* vi = &verts[i*2];
		area += (vj[0] - orig[0]) * (vi[1] - orig[1]);
		area -= (vj[1] - orig[1]) * (vi[0] - orig[0]);
	}
	return area * 0.5f;
}

