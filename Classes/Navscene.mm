//#import "Slide.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import <float.h>
#import "mathutil.h"
//#import "SDL.h"
//#import "SDL_Opengl.h"
//#import "font.h"
#import "nanosvg.h"
#import "navmesh.h"
#import "Navscene.h"
//#import "Slide.h"
//#import "image.h"
#import <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES1/glext.h>
#import <CCDrawingPrimitives.h>
#import "cocos2d.h"


static void reversePoly(float* poly, const int npoly)
{
	int i = 0;
	int j = npoly-1;
	while (i < j)
	{
		swap(poly[i*2+0], poly[j*2+0]);
		swap(poly[i*2+1], poly[j*2+1]);
		i++;
		--j;
	}
}

static void convertPoint(float* dst, const float* src,
						 const float s, const float* bmin, const float* bmax)
{
	dst[0] = (src[0] - bmin[0])*s;
	dst[1] = (bmax[1] - src[1])*s;
}

static void storePath(float* dst, const float* src, const int npts,
					  const float s, const float* bmin, const float* bmax)
{
	for (int i = 0; i < npts; ++i)
		convertPoint(&dst[i*2], &src[i*2], s, bmin, bmax);
	if (polyarea(dst, npts) < 0.0f)
		reversePoly(dst, npts);
}


bool navsceneInit(NavScene* scene, SVGPath* plist)
{
    /*
	SVGPath* plist = 0;
	plist = svgParseFromFile(path);
	if (!plist)
	{
		printf("navsceneLoad: Could not load '%s'\n", path);
		return false;
	}
     */
	
	// Calc bounds.
	float bmin[2] = {FLT_MAX,FLT_MAX}, bmax[2] = {-FLT_MAX,-FLT_MAX};
	for (SVGPath* it = plist; it; it = it->next)
	{
		for (int i = 0; i < it->npts; ++i)
		{
			const float* p = &it->pts[i*2];
			bmin[0] = min(bmin[0], p[0]);
			bmin[1] = min(bmin[1], p[1]);
			bmax[0] = max(bmax[0], p[0]);
			bmax[1] = max(bmax[1], p[1]);
		}
	}
	
	
	
	CCLOG(@"topLeft x=%f y=%f", bmin[0], bmin[1]);
	CCLOG(@"bottomRight x=%f y=%f", bmax[0], bmax[1]);

	
	SVGPath* walkablePath = 0;
	SVGPath* boundaryPath = 0;
	SVGPath* agentPaths[MAX_NAV_AGENTS];
	int nagentPaths = 0;
	for (SVGPath* it = plist; it; it = it->next)
	{
		if (it->strokeColor == 0xff000000)
			boundaryPath = it;
		else if (it->strokeColor == 0xff0000ff)
			walkablePath = it;
		else if (it->strokeColor == 0xffff0000 && !it->closed)
		{
			if (it->npts > 1 && nagentPaths < MAX_NAV_AGENTS)
				agentPaths[nagentPaths++] = it;
		}
	}
	
	
	if (!boundaryPath)
	{
		printf("navsceneLoad: No boundary!\n");
		//return false;
	}
	if (!walkablePath)
	{
		printf("navsceneLoad: No walkable!\n");
		//return false;
	}
	if (!nagentPaths)
	{
		printf("navsceneLoad: No agents!\n");
		//return false;
	}
	
	// Scale and flip
	//const float s = AGENT_RAD / 16.0f;
	const float s = 1;
	
	scene->nwalkable = walkablePath->npts;
	scene->walkable = new float [scene->nwalkable*2];
	if (!scene->walkable)
	{
		printf("navsceneLoad: Out of mem 'walkable' (%d).\n", scene->nwalkable);
		return false;
	}
	
	scene->nboundary = boundaryPath->npts;
	scene->boundary = new float [scene->nboundary*2];
	if (!scene->boundary)
	{
		printf("navsceneLoad: Out of mem 'boundary' (%d).\n", scene->nboundary);
		return false;
	}
	
	storePath(scene->walkable, walkablePath->pts, scene->nwalkable, s, bmin, bmax);
	storePath(scene->boundary, boundaryPath->pts, scene->nboundary, s, bmin, bmax);
	
	scene->nagents = nagentPaths;
	for (int i = 0; i < nagentPaths; ++i)
	{
		NavmeshAgent* ag = &scene->agents[i];
		agentInit(ag, AGENT_RAD);
		
		const float* pa = &agentPaths[i]->pts[0];
		const float* pb = &agentPaths[i]->pts[(agentPaths[i]->npts-1)*2];
		
		convertPoint(ag->pos, pa, s, bmin, bmax);
		vcpy(ag->oldpos, ag->pos);
		convertPoint(ag->target, pb, s, bmin, bmax);

		vcpy(ag->opos, ag->pos);
		vcpy(ag->otarget, ag->target);
	}
	
	if (plist)
		svgDelete(plist);
	
	scene->dim[0] = (bmax[0]-bmin[0])*s;
	scene->dim[1] = (bmax[1]-bmin[1])*s;
	
	//	m_dim[0] = (bmax[0]-bmin[0])*s + PADDING_SIZE*2;
	//	m_dim[1] = (bmax[1]-bmin[1])*s + PADDING_SIZE*2;
	
	scene->nav = navmeshCreate(scene->walkable, scene->nwalkable);
	if (!scene->nav)
	{
		printf("navsceneLoad: failed to create navmesh\n");
		return false;
	}

	
	return true;
}

void navsceneDelete(NavScene* scene)
{
	if (!scene) return;
	delete scene->nav;
	delete [] scene->boundary;
	delete [] scene->walkable;
}



void agentTrailDraw(NavmeshAgent* agent, Navmesh* nav, const float zoom)
{
}

void agentDraw(NavmeshAgent* agent, Navmesh* nav, int flags, const float zoom)
{
}


CGPoint convertVertToCGPoint(float *v)
{
	
	//CCLOG(@"x:%f y:%f", v[0], v[1]);
	return ccp(v[0], v[1]);
	
}


void navmeshDraw(Navmesh* nav, const float zoom)
{
	if (!nav) return;

	glColor4f(0.8, 1.0, 0.76, 1.0);  
	glLineWidth(1.0f);
	//glEnable(GL_LINE_SMOOTH);

	//	glColor4ub(0,192,255,64);
	//setcolor(ctrans(clerp(COL_SEC,COL_BACK,32),96));
	//glBegin(GL_TRIANGLES);
	CGPoint vertices[3];
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		//CCLOG(@"%f", v1[0]);
		vertices[0] = ccpMult(convertVertToCGPoint(&nav->verts[t[0]*2]), 1);
		vertices[1] = ccpMult(convertVertToCGPoint(&nav->verts[t[1]*2]), 1);
		vertices[2] = ccpMult(convertVertToCGPoint(&nav->verts[t[2]*2]), 1);
		//vertices[2] = &nav->verts[t[2]*2];
		ccDrawPoly(vertices, 3, YES);
		
		//glVertex2fv(&nav->verts[t[0]*2]);
		//glVertex2fv(&nav->verts[t[1]*2]);
		//glVertex2fv(&nav->verts[t[2]*2]);
	}
	//glEnd();
	
	/*
	setcolor(ctrans(clerp(COL_SEC,COL_DARK,128),220));
	//	glColor4ub(255,255,255,96);
	//	glColor4ub(0,96,128,64);
	
	glLineStipple(1,0xf0f0);
	glEnable(GL_LINE_STIPPLE);
	glLineWidth(1.5f*zoom);
	
	glBegin(GL_LINES);
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		for (int j = 0; j < 3; ++j)
		{
			if (t[3+j] < (unsigned short)i)
			{
				glVertex2fv(&nav->verts[t[j]*2]);
				glVertex2fv(&nav->verts[t[(j+1)%3]*2]);
			}
		}
	}
	glEnd();
	
	glDisable(GL_LINE_STIPPLE);
	
	glPointSize(5.0f*zoom);
	glBegin(GL_POINTS);
	for (int i = 0; i < nav->nverts; ++i)
		glVertex2fv(&nav->verts[i*2]);
	glEnd();
	glPointSize(1.0f);	
	 */
	
	// Draw boundary lines
	//
	//glLineWidth(3.0f*zoom);
	//glBegin(GL_LINES);
	/*
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		for (int j = 0; j < 3; ++j)
		{
			if (t[3+j] == 0xffff)
			{
				//glVertex2fv(&nav->verts[t[j]*2]);
				//glVertex2fv(&nav->verts[t[(j+1)%3]*2]);
			}
		}
	}
	 */
	 
	/*
	glEnd();
	glLineWidth(1.0f);
	
	
	glColor4ub(255,0,0,255);
	glBegin(GL_LINES);
	for (int i = 0; i < getDebugLineCount(); ++i)
	{
		const float* line = getDebugLine(i);
		glVertex2fv(line);
		glVertex2fv(line+2);
	}
	glEnd();
	
	*/
}

/*

struct BoundaryData
{
	BoundaryData() :
		initialized(false), cap(0), edirs(0), elens(0), eflags(0)
	{
	}
	
	~BoundaryData()
	{
		delete [] edirs;
		delete [] elens;
		delete [] eflags;
	}
	
	void init()
	{
		if (initialized)
			return;
		initialized = true;
		
		//tapeTex.load("tape.png",IMG_REPEAT);
	}
	
	void reserve(int n)
	{
		if (n <= cap)
			return;
			
		delete [] edirs;
		delete [] elens;
		delete [] eflags;
		
		edirs = new float[n*2];
		elens = new float[n];
		eflags = new char[n];
		cap = n;
	}

	bool initialized;
	//Image tapeTex;
	int cap;
	float* edirs;
	float* elens;
	char* eflags;
};

BoundaryData g_bdata;
*/

void drawBoundary(const float* verts, const int nverts, const float zoom)
{
	
}

void drawBoundaryWire(const float* verts, const int nverts, const float zoom)
{
	
}

