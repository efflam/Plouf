#import "navmesh.h"
#import <math.h>
#import <float.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <cocos2d.h>
#import <tesselator.h>

#ifdef WIN32
// HACK!!
#define inline static
#endif

inline float lerp(float a, float b, float t) { return a + (b-a)*t; }
inline float mini(int a, int b) { return a < b ? a : b; }
inline float maxi(int a, int b) { return a > b ? a : b; }
inline float minf(float a, float b) { return a < b ? a : b; }
inline float maxf(float a, float b) { return a > b ? a : b; }
inline float clamp(float a, float mn, float mx) { return a < mn ? mn : (a > mx ? mx : a); }
inline float sqr(float x) { return x*x; }
inline void vscale(float* v, const float* a, const float s) { v[0] = a[0]*s; v[1] = a[1]*s; }
inline void vset(float* a, const float x, const float y) { a[0]=x; a[1]=y; }
inline void vcpy(float* a, const float* b) { a[0]=b[0]; a[1]=b[1]; }
inline float vdot(const float* a, const float* b) { return a[0]*b[0] + a[1]*b[1]; }
inline float vperp(const float* a, const float* b) { return a[0]*b[1] - a[1]*b[0]; }
inline void vsub(float* v, const float* a, const float* b) { v[0] = a[0]-b[0]; v[1] = a[1]-b[1]; }
inline void vadd(float* v, const float* a, const float* b) { v[0] = a[0]+b[0]; v[1] = a[1]+b[1]; }

inline float vdistsqr(const float* a, const float* b)
{
	const float dx = b[0]-a[0];
	const float dy = b[1]-a[1];
	return dx*dx + dy*dy;
}

inline void vlerp(float* v, const float* a, const float* b, const float t)
{
	v[0] = a[0] + (b[0]-a[0])*t;
	v[1] = a[1] + (b[1]-a[1])*t;
}


inline int next(int i, int n) { return i+1 < n ? i+1 : 0; }

inline float triarea(const float* a, const float* b, const float* c)
{
	return (b[0]*a[1] - a[0]*b[1]) + (c[0]*b[1] - b[0]*c[1]) + (a[0]*c[1] - c[0]*a[1]);
}

inline int left(const float* a, const float* b, const float* c)
{
	const float EPS = 0.00001f;
	return triarea(a,b,c) < EPS;
}

inline int pntri(const float* a, const float* b, const float* c, const float* pt)
{
	return left(a, b, pt) && left(b, c, pt) && left(c, a, pt);
}


inline float distpt(const float* a, const float* b)
{
	const float dx = b[0] - a[0];
	const float dy = b[1] - a[1];
	return dx*dx + dy*dy;
}

void* poolAlloc( void* userData, unsigned int size )
{
	struct MemPool* pool = (struct MemPool*)userData;
	if (pool->size + size < pool->cap)
	{
		unsigned char* ptr = pool->buf + pool->size;
		pool->size += size;
		return ptr;
	}
	return 0;
}


static int triangulate(int n, const float* verts, unsigned short* indices, unsigned short* tris)
{
    int ntris = 0;
	unsigned short* dst;
	int i, i1, i2, k;
	float dmin = -1, d;
	int imin = -1;
	int empty;
	const float *p0, *p1, *p2, *pk;	
	
	while (n > 3)
	{
		dmin = FLT_MAX;
		imin = -1;
		
		for (i = 0; i < n; i++)
		{
			i1 = next(i, n);
			i2 = next(i1, n);
			
			p0 = &verts[indices[i] * 2];
			p1 = &verts[indices[i1] * 2];
			p2 = &verts[indices[i2] * 2];
			
			//CCLOG(@"x:%f y:%f", p0[0], p0[1]);

			if (left(p0,p1,p2))
			{
				empty = 1;
				for (k = 0; k < n; ++k)
				{
					if (k == i || k == i1 || k == i2)
						continue;
					pk = &verts[indices[k] * 2];
					if (pntri(p0,p1,p2,pk))
					{
						empty = 0;
						break;
					}
				}
				if (empty)
				{
					d = distpt(p2,p0) / (distpt(p0,p1) + distpt(p1,p2));
					if (d < dmin)
					{
						imin = i;
						dmin = d;
					}
				}
			}
		}
		
		if (imin == -1)
		{
			// Should not happen.
			return -ntris;
		}
		
		i = imin;
		i1 = next(i, n);
		i2 = next(i1, n);
		
		dst = &tris[ntris*6];
		dst[0] = indices[i];
		dst[1] = indices[i1];
		dst[2] = indices[i2];
		ntris++;
		
		n--;
		for (k = i1; k < n; k++)
			indices[k] = indices[k+1];
	}
	
	// Append the remaining triangle.
	dst = &tris[ntris*6];
	dst[0] = indices[0];
	dst[1] = indices[1];
	dst[2] = indices[2];
	ntris++;
	
	return ntris;
}

struct Edge
{
	unsigned short vert[2];
	unsigned short polyEdge[2];
	unsigned short poly[2];
};

static int buildadj(unsigned short* tris, const int ntris, const int nverts)
{
	int maxEdgeCount = ntris*3;
	unsigned short* firstEdge = 0;
	unsigned short* nextEdge = 0;
	struct Edge* edges = 0;
	int edgeCount = 0;
	int i,j;
	
	firstEdge = (unsigned short*)malloc(sizeof(unsigned short)*(nverts + maxEdgeCount));
	if (!firstEdge)
		goto cleanup;
	nextEdge = firstEdge + nverts;
	
	edges = (struct Edge*)malloc(sizeof(struct Edge)*maxEdgeCount);
	if (!edges)
		goto cleanup;
	
	for (i = 0; i < nverts; i++)
		firstEdge[i] = 0xffff;
	
	for (i = 0; i < ntris; ++i)
	{
		unsigned short* t = &tris[i*6];
		for (j = 0; j < 3; ++j)
		{
			unsigned short v0 = t[j];
			unsigned short v1 = t[(j+1) % 3];
			if (v0 < v1)
			{
				struct Edge* edge = &edges[edgeCount];
				edge->vert[0] = v0;
				edge->vert[1] = v1;
				edge->poly[0] = (unsigned short)i;
				edge->polyEdge[0] = (unsigned short)j;
				edge->poly[1] = (unsigned short)i;
				edge->polyEdge[1] = 0;
				// Insert edge
				nextEdge[edgeCount] = firstEdge[v0];
				firstEdge[v0] = (unsigned short)edgeCount;
				edgeCount++;
			}
		}
	}
	
	for (i = 0; i < ntris; ++i)
	{
		unsigned short* t = &tris[i*6];
		for (j = 0; j < 3; ++j)
		{
			unsigned short v0 = t[j];
			unsigned short v1 = t[(j+1) % 3];
			if (v0 > v1)
			{
				unsigned short e;
				for (e = firstEdge[v1]; e != 0xffff; e = nextEdge[e])
				{
					struct Edge* edge = &edges[e];
					if (edge->vert[1] == v0 && edge->poly[0] == edge->poly[1])
					{
						edge->poly[1] = (unsigned short)i;
						edge->polyEdge[1] = (unsigned short)j;
						break;
					}
				}
			}
		}
	}
	
	// Store adjacency

	for (i = 0; i < ntris; ++i)
	{
		unsigned short* t = &tris[i*6];
		t[3] = 0xffff;
		t[4] = 0xffff;
		t[5] = 0xffff;
	}

	for (i = 0; i < edgeCount; ++i)
	{
		struct Edge* e = &edges[i];
		if (e->poly[0] != e->poly[1])
		{
			unsigned short* t0 = &tris[e->poly[0]*6];
			unsigned short* t1 = &tris[e->poly[1]*6];
			t0[3+e->polyEdge[0]] = e->poly[1];
			t1[3+e->polyEdge[1]] = e->poly[0];
		}
	}

	free(firstEdge);
	free(edges);
	return 1;
	
cleanup:
	if (firstEdge)
		free(firstEdge);
	if (edges)
		free(edges);
	return 0;
}


static int isectSegSeg(const float* ap, const float* aq, const float* bp, const float* bq, float* s, float* t)
{
	float u[2], v[2], w[2], d;
	vsub(u,aq,ap);
	vsub(v,bq,bp);
	vsub(w,ap,bp);
	d = vperp(u,v);
	*s = 0; *t = 0;
	if (fabsf(d) < 1e-6f) return 0;
	*s = vperp(v,w) / d;
	if (*s < 0 || *s > 1) return 0;
	*t = vperp(u,w) / d;
	if (*t < 0 || *t > 1) return 0;
	return 1;
}

static float closestPtPtSeg(const float* pt, const float* sp, const float* sq)
{
	float dir[2],diff[3],t,d;
	vsub(dir,sq,sp);
	vsub(diff,pt,sp);
	t = vdot(diff,dir);
	if (t <= 0.0f) return 0;
	d = vdot(dir,dir);
	if (t >= d) return 1;
	return t/d;
}

// Creates navmesh from a polygon.
struct Navmesh* navmeshCreate(const float* pts, const int npts)
{
	int i;
	struct Navmesh* nav = 0;
	unsigned short* indices = 0;
	
	nav = (struct Navmesh*)malloc(sizeof(struct Navmesh));
	if (!nav)
		goto cleanup;
	memset(nav, 0, sizeof(struct Navmesh));

	indices = (unsigned short*)malloc(sizeof(unsigned short)*npts);
	if (!indices)
		goto cleanup;

	nav->verts = (float*)malloc(sizeof(float)*npts*2);
	if (!nav->verts)
		goto cleanup;
	memcpy(nav->verts, pts, sizeof(float)*2*npts);
	nav->nverts = npts;

	nav->tris = (unsigned short*)malloc(sizeof(unsigned short)*(npts-2)*6);
	if (!nav->tris)
		goto cleanup;
	
	for (i = 0; i < npts; ++i)
		indices[i] = (unsigned short)i;

	nav->ntris = triangulate(nav->nverts, nav->verts, indices, nav->tris);
	if (nav->ntris < 0) nav->ntris = -nav->ntris;
	if (!nav->ntris)
		goto cleanup;

	if (indices)
		free(indices);

	if (!buildadj(nav->tris, nav->ntris, nav->nverts))
		goto cleanup;

	return nav;
	
cleanup:
	if (nav)
	{
		if (nav->verts)
			free(nav->verts);
		if (nav->tris)
			free(nav->tris);
		free(nav);
        
	}
	if (indices)
		free(indices);

	return 0;
}

// Find nearest triangle
int navmeshFindNearestTri(struct Navmesh* nav, const float* pos, float* nearest)
{
	int i, j, besti = -1;
	float t, d, p[2], bestd = FLT_MAX;

	if (nearest)
		vcpy(nearest, pos);

	for (i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* tri = &nav->tris[i*6];
		const float* va = &nav->verts[tri[0]*2];
		const float* vb = &nav->verts[tri[1]*2];
		const float* vc = &nav->verts[tri[2]*2];
		if (pntri(va,vb,vc,pos))
			return i;
	}

	for (i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* tri = &nav->tris[i*6];
		for (j = 0; j < 3; ++j)
		{
			const float* va = &nav->verts[tri[j]*2];
			const float* vb = &nav->verts[tri[(j+1)%3]*2];
			if (tri[3+j] != 0xffff)
				continue;
			t = closestPtPtSeg(pos,va,vb);
			vlerp(p,va,vb,t);
			d = distpt(p,pos);
			if (d < bestd)
			{
				if (nearest)
					vcpy(nearest, p);
				bestd = d;
				besti = i;
			}
		}
	}
	
	return besti;
}

int navmeshFindPath(struct Navmesh* nav, const float* start, const float* end, unsigned short* path, const int maxpath)
{
#define MAX_STACK 128
#define MAX_PARENT 128
	int i, starti, endi, stack[MAX_STACK], nstack;
	unsigned short parent[MAX_PARENT];
	
	starti = navmeshFindNearestTri(nav, start, NULL);
	endi = navmeshFindNearestTri(nav, end, NULL);
	if (starti == -1 || endi == -1)
		return 0;
		
	if (starti == endi)
	{
		path[0] = (unsigned short)starti;
		return 1;
	}

	memset(parent, 0xff, sizeof(unsigned short)*MAX_PARENT);
		
	nstack = 0;
	stack[nstack++] = endi;
	parent[endi] = endi;
	
	while (nstack)
	{
		unsigned short* tri;
		unsigned short cur;
		
		// Pop front.
		cur = stack[0];
		nstack--;
		for (i = 0; i < nstack; ++i)
			stack[i] = stack[i+1];

		if (cur == starti)
		{
			// Trace and store back.
			int npath = 0;
			for (;;)
			{
				path[npath++] = cur;
				if (npath >= maxpath) break;
				if (parent[cur] == cur) break;
				cur = parent[cur];
			}
			return npath;
		}
		
		tri = &nav->tris[cur*6];
		for (i = 0; i < 3; ++i)
		{
			const unsigned short nei = tri[3+i];
			if (nei == 0xffff) continue;
			if (parent[nei] != 0xffff) continue;
			parent[nei] = cur;
			if (nstack < MAX_STACK)
				stack[nstack++] = nei;
		}
	}
	
	return 0;
}


inline int vequal(const float* a, const float* b)
{
	static const float eq = 0.001f*0.001f;
	return distpt(a, b) < eq;
}

inline int pushPoint(float* pts, int npts, const int maxpts, const float* pt)
{
	if (npts >= maxpts) return npts;
	if (vequal(pt, &pts[(npts-1)*2])) return npts;
	vcpy(&pts[npts*2], pt);
	return npts+1;
}

static int stringPull(const float* portals, int nportals, float* pts, const int maxpts)
{
	int npts = 0, i;
	float portalApex[2], portalLeft[2], portalRight[2];
	int apexIndex = 0, leftIndex = 0, rightIndex = 0;
	vcpy(portalApex, &portals[0]);
	vcpy(portalLeft, &portals[0]);
	vcpy(portalRight, &portals[2]);
	
	// Add start point.
	vcpy(&pts[npts*2], portalApex);
	npts++;
	
	for (i = 1; i < nportals && npts < maxpts; ++i)
	{
		const float* left = &portals[i*4+0];
		const float* right = &portals[i*4+2];
		
		// Update right vertex.
        if (triarea(portalApex, portalRight, right) <= 0.0f)
		{
			if (vequal(portalApex, portalRight) || triarea(portalApex, portalLeft, right) > 0.0f)
			{
				// Tighten the funnel.
				vcpy(portalRight, right);
				rightIndex = i;
			}
			else
			{
				// Right over left, insert left to path and restart scan from portal left point.
				npts = pushPoint(pts, npts, maxpts, portalLeft);
				// Make current left the new apex.
				vcpy(portalApex, portalLeft);
				apexIndex = leftIndex;
				// Reset portal
				vcpy(portalLeft, portalApex);
				vcpy(portalRight, portalApex);
				leftIndex = apexIndex;
				rightIndex = apexIndex;
				// Restart scan
				i = apexIndex;
				continue;
			}
		}
		
		// Update left vertex.
        if (triarea(portalApex, portalLeft, left) >= 0.0f)
		{
			if (vequal(portalApex, portalLeft) || triarea(portalApex, portalRight, left) < 0.0f)
			{
				// Tighten the funnel.
				vcpy(portalLeft, left);
				leftIndex = i;
			}
			else
			{
				// Left over right, insert right to path and restart scan from portal right point.
				npts = pushPoint(pts, npts, maxpts, portalRight);
				// Make current right the new apex.
				vcpy(portalApex, portalRight);
				apexIndex = rightIndex;
				// Reset portal
				vcpy(portalLeft, portalApex);
				vcpy(portalRight, portalApex);
				leftIndex = apexIndex;
				rightIndex = apexIndex;
				// Restart scan
				i = apexIndex;
				continue;
			}
		}
	}
	// Append last point to path.
	npts = pushPoint(pts, npts, maxpts, &portals[(nportals-1)*4+0]);
	
	return npts;
}

static void getPortalPoints(struct Navmesh* nav, const unsigned short a, const unsigned short b,
							float* left, float* right)
{
	const unsigned short* ta = &nav->tris[a*6];
	int i;
	for (i = 0; i < 3; ++i)
	{
		if (ta[3+i] == b)
		{
			const float* va = &nav->verts[ta[i]*2];
			const float* vb = &nav->verts[ta[(i+1)%3]*2];
			vcpy(right, va);
			vcpy(left, vb);
		}
	}
}

int navmeshStringPull(struct Navmesh* nav, const float* start, const float* end,
					  const unsigned short* path, const int npath,
					  float* pts, const int maxpts)
{
#define MAX_PORTALS 128
	float portals[MAX_PORTALS*4];
	int nportals = 0, i;
	
	// Start portal
	vcpy(&portals[nportals*4+0], start);
	vcpy(&portals[nportals*4+2], start);
	nportals++;
	// Portal between navmesh polygons
	for (i = 0; i < npath-1; ++i)
	{
		getPortalPoints(nav, path[i], path[i+1], &portals[nportals*4+0], &portals[nportals*4+2]);
		nportals++;
	}
	// End portal
	vcpy(&portals[nportals*4+0], end);
	vcpy(&portals[nportals*4+2], end);
	nportals++;
	
	return stringPull(portals, nportals, pts, maxpts);
}

static int getBestEdge(const float* pa, const float* pb, const float* poly, const int npoly)
{
	const float EPS = 0.0001f;
	int i, j;
	for (i = 0, j = npoly-1; i < npoly; j = i++)
	{
		const float* sp = &poly[j*2];
		const float* sq = &poly[i*2];
		const float a0 = triarea(pa, pb, sp);
		const float a1 = triarea(pa, pb, sq);
		if (a0 >= -EPS && a1 <= EPS)
			return j;
	}
	return -1;
}

static int pointInsidePoly(const float* pt, const float* poly, const int npoly,
						   float* nearest, int* nearesti, float* nearestt)
{
	const float EPS = 0.00001f;
	float dmin = FLT_MAX;
	int res = 1, i, j;
	if (nearest)
		vcpy(nearest, pt);
	if (nearesti)
		*nearesti = 0;
	if (nearestt)
		*nearestt = 0;
		
	for (i = 0, j = npoly-1; i < npoly; j = i++)
	{
		const float* sp = &poly[j*2];
		const float* sq = &poly[i*2];
		const float area = triarea(pt, sp, sq);
		if (area >= -EPS)
		{
			res = 0;
		}
		if (nearest)
		{
			float p[2], t, d;
			t = closestPtPtSeg(pt, sp,sq);
			vlerp(p,sp,sq,t);
			d = distpt(pt,p);
			if (d < dmin)
			{
				dmin = d;
				vcpy(nearest,p);
				if (nearesti)
					*nearesti = j;
				if (nearestt)
					*nearestt = t;
			}
		}
	}
	return res;
}

static void getTriVerts(struct Navmesh* nav, unsigned short idx, float* verts)
{
	const unsigned short* tri = &nav->tris[idx*6];
	vcpy(verts+0, &nav->verts[tri[0]*2]);
	vcpy(verts+2, &nav->verts[tri[1]*2]);
	vcpy(verts+4, &nav->verts[tri[2]*2]);
}

#define MAX_DBG_LINES 512
float g_dlines[MAX_DBG_LINES*4];
int g_ndlines = 0;

static void dbgline(const float* a, const float* b)
{
	float* line;
	if (g_ndlines >= MAX_DBG_LINES) return;
	line = &g_dlines[g_ndlines*4];
	g_ndlines++;
	line[0] = a[0];
	line[1] = a[1];
	line[2] = b[0];
	line[3] = b[1];
}

static void dbgcross(const float* p, const float s)
{
	float a[2],b[2];
	a[0] = p[0]-s;
	a[1] = p[1];
	b[0] = p[0]+s;
	b[1] = p[1];
	dbgline(a,b);
	a[0] = p[0];
	a[1] = p[1]-s;
	b[0] = p[0];
	b[1] = p[1]+s;
	dbgline(a,b);
}

int getDebugLineCount()
{
	return g_ndlines;
}

const float* getDebugLine(int i)
{
	return &g_dlines[i*4];
}


int navmeshMoveAlong(struct Navmesh* nav, float* start, const unsigned short idx, const float* target,
					 unsigned short* visited, const int maxvisited)
{
	static const float EPS = 0.001f;
	float poly[3*2];
	float pos[2];
	unsigned short cur = idx;
	unsigned short prev = 0xffff;
	int nvisited = 0;


//	g_ndlines = 0;


	vcpy(pos, start);

	for (;;)
	{
		unsigned short next, nei;
		const unsigned short* tri = &nav->tris[cur*6];
		int edge;
		float t, p[2];

		if (nvisited < maxvisited)
			visited[nvisited++] = cur;

		getTriVerts(nav, cur, poly);

		// If target is inside current polygon, goto target location and end.
		if (pointInsidePoly(target, poly, 3, p, &edge, &t))
		{
			vcpy(start, target);
			return nvisited;
		}
		
//		dbgline(pos, p);
//		dbgcross(p,0.1f);
		
		// Move to clamped point.
		vcpy(pos, p);

		// Find best edge to move to.
		next = tri[3+edge];

		if (next == 0xffff || next == prev)
		{
			if (t < EPS)
			{
				// Hit left vertex, check if previous valid to move to.
				nei = tri[3+(edge+2)%3];
				if (nei != 0xffff && nei != prev)
					next = nei;
			}
		}
			
		// TODO: There are some rare cases, where this code chooses wrong edge.
		// It happens when the start position is at a vertex, and both edges can be
		// traversed. In that case the edge direction in relation to the 'target'
		// should be checked to choose the best alternative.
		// This bad case will be resolved in the next update, but it might clamp
		// the movement for one frame.
		
		if (next == 0xffff || next == prev)
		{
			if (t > 1-EPS)
			{
				// Hit right vertex, check if next valid to move to.
				nei = tri[3+(edge+1)%3];
				if (nei != 0xffff && nei != prev)
					next = nei;
			}
		}
			
		if (next == 0xffff || next == prev)
		{
			vcpy(start, pos);
			return nvisited;
		}

		prev = cur;
		cur = next;

	}
	
	return 0;
}

// Deletes navmesh.
void navmeshDelete(struct Navmesh* nav)
{
	if (!nav)
		return;
	if (nav->verts)
		free(nav->verts);
	if (nav->tris)
		free(nav->tris);
	free(nav);
}


int posValid(const float* p)
{
	return p[0] < FLT_MAX && p[1] < FLT_MAX;
}

void agentInit(struct NavmeshAgent* agent, const float rad)
{
	vset(agent->pos, FLT_MAX, FLT_MAX);
	vset(agent->oldpos, FLT_MAX, FLT_MAX);
	vset(agent->target, FLT_MAX, FLT_MAX);
	vset(agent->delta, 0,0);
	vset(agent->corner, FLT_MAX, FLT_MAX);
	vset(agent->npos, FLT_MAX, FLT_MAX);
	vset(agent->disp, 0, 0);
	vset(agent->vel, 0,0);
	vset(agent->pvel, 0,0);
	vset(agent->dvel, 0,0);
	vset(agent->nvel, 0,0);
	agent->npath = 0;
	agent->nvisited = 0;
	agent->rad = rad;
	agent->t = 0;
	agent->ntrail = 0;
	agent->htrail = 0;
	agent->hhead = 0;
}


static int findNextCorner(const float* pos,
						  const float* corners, const int ncorners,
						  const float slop, float* res)
{
	int i;
	for (i = 0; i < ncorners; ++i)
	{
		const float* cor = &corners[i*2];
		if (vdistsqr(pos, cor) > sqr(slop))
		{
			vcpy(res, cor);
			return (i == ncorners-1) ? 1 : 0;
		}
	}
	vcpy(res, &corners[(ncorners-1)*2]);
	return 1;
}

static int findNextSmoothCorner(const float* pos, const float* dir,
								const float* corners, const int ncorners,
								const float slop, float* res)
{
	int i, c0, c1, last;
	float blend, strength, delta0[2], delta1[2];
	float len0, len1, s;
	const float *cor0, *cor1;
	
	c0 = ncorners-1;
	
	for (i = 0; i < ncorners; ++i)
	{
		const float* cor = &corners[i*2];
		if (vdistsqr(pos, cor) > sqr(slop))
		{
			c0 = i;
			break;
		}
	}
	
	c1 = c0+2;
	if (c1 >= ncorners) c1 = ncorners-1;
	
	// Weirdo spline hack!
	
	cor0 = &corners[c0*2];
	cor1 = &corners[c1*2];
	
	vsub(delta0, cor0, pos);
	vsub(delta1, cor1, pos);
	
	last = c0 == (ncorners-1);
	
	blend = 0.2f;
	strength = mini(last?1.0f:10.0f, 2.0f);
	
	len0 = sqrtf(vdot(delta0,delta0));
	len1 = sqrtf(vdot(delta1,delta1));
	s = -strength*len0/len1;
	res[0] = pos[0] + delta0[0] + delta1[0]*s*blend + dir[0]*len0*strength*(1-blend);
	res[1] = pos[1] + delta0[1] + delta1[1]*s*blend + dir[1]*len0*strength*(1-blend);
	
	return last;
}

static int fixupCorridor(unsigned short* path, int npath, const unsigned short* visited, const int nvisited)
{
	unsigned short tmp[AGENT_MAX_PATH];
	int furthestPath = -1;
	int furthestVisited = -1;
	int i, j, n;
	
	// Find furthest common triangle.
	for (i = npath-1; i >= 0; --i)
	{
		int found = 0;
		for (j = nvisited-1; j >= 0; --j)
		{
			if (path[i] == visited[j])
			{
				furthestPath = i;
				furthestVisited = j;
				found = 1;
			}
		}
		if (found)
			break;
	}
	
	if (furthestPath == -1 || furthestVisited == -1)
	{
		return npath;
	}
	
	// Concatenate paths.	
	memcpy(tmp, path, sizeof(unsigned short)*npath);
	
	n = 0;
	for (i = nvisited-1; i >= furthestVisited; --i) 
		path[n++] = visited[i];
	
	for (i = furthestPath+1; i < npath; ++i) 
		path[n++] = tmp[i];
	
	return n;
}

void agentFindPath(struct NavmeshAgent* agent, struct Navmesh* nav)
{
	agent->npath = 0;

	if (posValid(agent->target))
		agent->npath = navmeshFindPath(nav, agent->pos, agent->target, agent->path, AGENT_MAX_PATH);
}


int agentFindNextCorner(struct NavmeshAgent* agent, struct Navmesh* nav, float* corner)
{
	const float EPS = 0.02f;
	float corners[3*2];
	int ncorners = 0, last = 1;
	
	// Find next few corners points, and handle special cases like
	// when the next corner is too close to current location or
	// handle miss-match of epsilon values used in different functions.
	vcpy(corner, agent->pos);
	if (agent->npath)
		ncorners = navmeshStringPull(nav, agent->pos, agent->target, agent->path, agent->npath, corners, 3);
	if (!ncorners)
		return 1;
		
	last = findNextCorner(agent->pos, corners, ncorners, EPS, agent->corner);
	vcpy(corner, agent->corner);
	
	return last;
}

int agentFindNextCornerSmooth(struct NavmeshAgent* agent, const float* dir, struct Navmesh* nav, float* corner)
{
	const float EPS = 0.02f;
	float corners[2*4];
	int ncorners = 0;

	// Find next few corners points, and handle special cases like
	// when the next corner is too close to current location.
	vcpy(corner, agent->pos);
	if (agent->npath)
		ncorners = navmeshStringPull(nav, agent->pos, agent->target, agent->path, agent->npath, corners, 4);
	if (!ncorners)
		return 1;
		
	findNextCorner(agent->pos, corners, ncorners, EPS, agent->corner);

	return findNextSmoothCorner(agent->pos, dir, corners, ncorners, EPS, corner);
}

int agentCalcSmoothSteerVel(struct NavmeshAgent* agent, struct Navmesh* nav, const float maxSpeed, const float dt)
{
	float corner[2];
	float len, distToGoalSqr = 100.0f, clampedSpeed = 0.0f;
	int last = 1;
	const float dir[2] = {0,0};
	
	// Find next corner to steer to.
	vcpy(corner, agent->pos);
	last = agentFindNextCornerSmooth(agent, dir, nav, corner);

	distToGoalSqr = vdistsqr(agent->pos, agent->target);

	if (last && distToGoalSqr < sqr(0.02f))
	{
		// Reached goal
		vcpy(agent->oldpos, agent->pos);
		vset(agent->dvel, 0,0);
		vcpy(agent->vel, agent->dvel);
		return 1;
	}
	
	vsub(agent->dvel, corner, agent->pos);
	
	// Limit desired velocity to max speed.
	clampedSpeed = maxSpeed * minf(1.0f, sqrtf(distToGoalSqr)/(agent->rad*2));
	len = sqrtf(vdot(agent->dvel,agent->dvel));
	if (len > 0.001f)
		clampedSpeed /= len;
	vscale(agent->dvel, agent->dvel, clampedSpeed);
	
	return 0;
}

void agentMoveAndAdjustCorridor(struct NavmeshAgent* agent, const float* target, struct Navmesh* nav)
{
	vcpy(agent->oldpos, agent->pos);
	
	agent->nvisited = navmeshMoveAlong(nav, agent->pos, agent->path[0], target, agent->visited, AGENT_MAX_PATH);
	agent->npath = fixupCorridor(agent->path, agent->npath, agent->visited, agent->nvisited);
	
	// Update trail
	agent->htrail = (agent->htrail+1) % AGENT_MAX_TRAIL;
	vcpy(&agent->trail[agent->htrail*2], agent->pos);
	if (agent->ntrail < AGENT_MAX_TRAIL)
		agent->ntrail++;
}


