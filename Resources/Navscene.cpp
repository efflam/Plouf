#include "Slide.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <float.h>
#include "mathutil.h"
#include "SDL.h"
#include "SDL_Opengl.h"
#include "font.h"
#include "nanosvg.h"
#include "navmesh.h"
#include "Navscene.h"
#include "Slide.h"
#include "image.h"

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


bool navsceneLoad(NavScene* scene, const char* path)
{
	SVGPath* plist = 0;
	plist = svgParseFromFile(path);
	if (!plist)
	{
		printf("navsceneLoad: Could not load '%s'\n", path);
		return false;
	}
	
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
		return false;
	}
	if (!walkablePath)
	{
		printf("navsceneLoad: No walkable!\n");
		return false;
	}
	if (!nagentPaths)
	{
		printf("navsceneLoad: No agents!\n");
		return false;
	}
	
	// Scale and flip
	const float s = AGENT_RAD / 16.0f;
	
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
	if (agent->ntrail > 1)
	{
		glLineWidth(4.0f*zoom);
		//		glBegin(GL_LINE_STRIP);
		glPointSize(3.0f*zoom);
		glBegin(GL_POINTS);
		int head = agent->htrail;
		for (int i = 0; i < agent->ntrail; ++i)
		{
			const float u = (float)i / (float)agent->ntrail;
			int a = (int)(230*(1-u*u));
//			setcolor(ctrans(COL_DIM,a));
			setcolor(ctrans(COL_DARK,a));
			//glColor4ub(192,32,0,a);
			glVertex2fv(&agent->trail[head*2]);
			head = (head+AGENT_MAX_TRAIL-1) % AGENT_MAX_TRAIL;
		}
		glEnd();
	}
	
	if (posValid(agent->target))
	{
		glLineWidth(2.0f*zoom);
		const float s = 0.15f;
		setcolor(COL_DARK);
		glBegin(GL_LINES);
		glVertex2f(agent->target[0]-s,agent->target[1]);
		glVertex2f(agent->target[0]+s,agent->target[1]);
		glVertex2f(agent->target[0],agent->target[1]-s);
		glVertex2f(agent->target[0],agent->target[1]+s);
		glEnd();
		glLineWidth(1.0f);
	}
	
}

void agentDraw(NavmeshAgent* agent, Navmesh* nav, int flags, const float zoom)
{
	
	if (flags & AGENTDRAW_CORRIDOR)
	{
		if (agent->npath)
		{
			setcolor(ctrans(COL_DARK,96));
			glBegin(GL_TRIANGLES);
			for (int i = 0; i < agent->npath; ++i)
			{
				const unsigned short* t = &nav->tris[agent->path[i]*6];
				glVertex2fv(&nav->verts[t[0]*2]);
				glVertex2fv(&nav->verts[t[1]*2]);
				glVertex2fv(&nav->verts[t[2]*2]);
			}
			glEnd();
			
			glLineWidth(2.0f*zoom);
			glLineStipple(1,0xf0f0);
			glEnable(GL_LINE_STIPPLE);
			
			glBegin(GL_LINES);
//			glColor4ub(255,255,255,220);
			setcolor(ctrans(COL_DARK,192));
			for (int i = 0; i < agent->npath-1; ++i)
			{
				const unsigned short* t = &nav->tris[agent->path[i]*6];
				const unsigned short next = agent->path[i+1];
				for (int j = 0, k = 2; j < 3; k=j++)
				{
					if (t[3+k] == next)
					{
						glVertex2fv(&nav->verts[t[k]*2]);
						glVertex2fv(&nav->verts[t[j]*2]);
					}
				}
			}
			glEnd();
			glDisable(GL_LINE_STIPPLE);
			
			glLineWidth(4.0f*zoom);
			glBegin(GL_LINES);
			setcolor(ctrans(COL_DARK,192));
			for (int i = 0; i < agent->npath; ++i)
			{
				const unsigned short* t = &nav->tris[agent->path[i]*6];
				const unsigned short prev = (i-1) < 0 ? agent->path[i] : agent->path[i-1];
				const unsigned short next = (i+1) >= agent->npath ? agent->path[i] : agent->path[i+1];
				for (int j = 0, k = 2; j < 3; k=j++)
				{
					if (t[3+k] == prev || t[3+k] == next) continue;
					glVertex2fv(&nav->verts[t[k]*2]);
					glVertex2fv(&nav->verts[t[j]*2]);
				}
			}
			glEnd();
			glLineWidth(1.0f);
		}
	}

	if (flags & AGENTDRAW_VISITED)
	{
		if (agent->nvisited)
		{
			setcolor(ctrans(COL_BACK,64));
			glBegin(GL_TRIANGLES);
			for (int i = 0; i < agent->nvisited; ++i)
			{
				const unsigned short* t = &nav->tris[agent->visited[i]*6];
				glVertex2fv(&nav->verts[t[0]*2]);
				glVertex2fv(&nav->verts[t[1]*2]);
				glVertex2fv(&nav->verts[t[2]*2]);
			}
			glEnd();
			
/*
			glLineWidth(3.0f);
//			glLineStipple(1,0xf0f0);
//			glEnable(GL_LINE_STIPPLE);
			
			glBegin(GL_LINES);
//			glColor4ub(255,255,255,220);
			for (int i = 0; i < agent->nvisited-1; ++i)
			{
				const unsigned short* t = &nav->tris[agent->visited[i]*6];
				const unsigned short next = agent->visited[i+1];
				for (int j = 0, k = 2; j < 3; k=j++)
				{
					if (t[3+k] == next)
					{
						glVertex2fv(&nav->verts[t[k]*2]);
						glVertex2fv(&nav->verts[t[j]*2]);
					}
				}
			}
			glEnd();
			glDisable(GL_LINE_STIPPLE);*/
			
			glLineWidth(3.0f*zoom);
//			glLineStipple(1,0xffc0);
//			glEnable(GL_LINE_STIPPLE);
			glBegin(GL_LINES);
//			glColor4ub(255,255,255,220);
			setcolor(ctrans(COL_BACK,230));
			for (int i = 0; i < agent->nvisited; ++i)
			{
				const unsigned short* t = &nav->tris[agent->visited[i]*6];
				const unsigned short prev = (i-1) < 0 ? agent->visited[i] : agent->visited[i-1];
				const unsigned short next = (i+1) >= agent->nvisited ? agent->visited[i] : agent->visited[i+1];
				for (int j = 0, k = 2; j < 3; k=j++)
				{
					if (t[3+k] == prev || t[3+k] == next) continue;
					glVertex2fv(&nav->verts[t[k]*2]);
					glVertex2fv(&nav->verts[t[j]*2]);
				}
			}
			glEnd();
			glLineWidth(1.0f);
//			glDisable(GL_LINE_STIPPLE);
		}
	}
	
	if (flags & AGENTDRAW_CORNER)
	{
		if (posValid(agent->corner))
		{
			//		glColor4ub(128,24,0,255);

			setcolor(COL_BACK);

			glLineWidth(7.0f*zoom);
			glBegin(GL_LINES);
			glVertex2fv(agent->pos);
			glVertex2fv(agent->corner);
			glEnd();
			glPointSize(10.0f*zoom);
			glBegin(GL_POINTS);
			glVertex2fv(agent->pos);
			glVertex2fv(agent->corner);
			glEnd();

			setcolor(clerp(COL_PRI,COL_DIM,96));
			
			glLineWidth(3.0f*zoom);
			glBegin(GL_LINES);
			glVertex2fv(agent->pos);
			glVertex2fv(agent->corner);
			glEnd();
			glPointSize(6.0f*zoom);
			glBegin(GL_POINTS);
			glVertex2fv(agent->pos);
			glVertex2fv(agent->corner);
			glEnd();
			
			glLineWidth(1.0f);
			glPointSize(1.0f);
		}
	}
	
/*	if (agent->ntrail > 1)
	{
		glLineWidth(4.0f*zoom);
		//		glBegin(GL_LINE_STRIP);
		glPointSize(3.0f*zoom);
		glBegin(GL_POINTS);
		int head = agent->htrail;
		for (int i = 0; i < agent->ntrail; ++i)
		{
			const float u = (float)i / (float)agent->ntrail;
			int a = (int)(255*(1-u*u));
			setcolor(ctrans(COL_DIM,a));
			//glColor4ub(192,32,0,a);
			glVertex2fv(&agent->trail[head*2]);
			head = (head+AGENT_MAX_TRAIL-1) % AGENT_MAX_TRAIL;
		}
		glEnd();
	}*/
	
	if (posValid(agent->pos))
	{
		setcolor(ctrans(COL_DARK,220));
		drawcirclefeather(agent->pos[0],agent->pos[1],agent->rad+0.01f,0.06f,32);

		//		glColor4ub(192,0,128,64);
//		setcolor(ctrans(COL_PRI,64));
		setcolor(ctrans(clerp(COL_BACK,COL_PRI,64),220));
		drawcirclefilled(agent->pos[0],agent->pos[1],agent->rad,23);
		//		glColor4ub(192,0,128,255);
		setcolor(COL_PRI);
		glLineWidth(4.0f*zoom);
		drawcircle(agent->pos[0],agent->pos[1],agent->rad,23);
		glLineWidth(1.0f);
		
		const float s = 0.05f;
		setcolor(COL_DIM);
		glBegin(GL_LINES);
		glVertex2f(agent->pos[0]-s,agent->pos[1]);
		glVertex2f(agent->pos[0]+s,agent->pos[1]);
		glVertex2f(agent->pos[0],agent->pos[1]-s);
		glVertex2f(agent->pos[0],agent->pos[1]+s);
		glEnd();
	}
	
	
}

void navmeshDraw(Navmesh* nav, const float zoom)
{
	if (!nav) return;
	
	//	glColor4ub(0,192,255,64);
	setcolor(ctrans(clerp(COL_SEC,COL_BACK,32),96));
	glBegin(GL_TRIANGLES);
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		glVertex2fv(&nav->verts[t[0]*2]);
		glVertex2fv(&nav->verts[t[1]*2]);
		glVertex2fv(&nav->verts[t[2]*2]);
	}
	glEnd();
	
	// draw triangle labels.
	/*	glColor4ub(0,96,128,255);
	 glLineWidth(1.0f);
	 glPointSize(2.0f);
	 glBegin(GL_POINTS);
	 for (int i = 0; i < nav->ntris; ++i)
	 {
	 const unsigned short* t = &nav->tris[i*6];
	 float c[2];
	 getTriCenter(&nav->verts[t[0]*2], &nav->verts[t[1]*2], &nav->verts[t[2]*2], c);
	 glVertex2fv(c);
	 }
	 glEnd();
	 glPointSize(1.0f);
	 for (int i = 0; i < nav->ntris; ++i)
	 {
	 const unsigned short* t = &nav->tris[i*6];
	 float c[2];
	 getTriCenter(&nav->verts[t[0]*2], &nav->verts[t[1]*2], &nav->verts[t[2]*2], c);
	 drawtext(c[0]+0.02f,c[1], 0.07f, "%d", i);
	 }*/
	
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
	
	// Draw boundary lines
	glLineWidth(3.0f*zoom);
	glBegin(GL_LINES);
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		for (int j = 0; j < 3; ++j)
		{
			if (t[3+j] == 0xffff)
			{
				glVertex2fv(&nav->verts[t[j]*2]);
				glVertex2fv(&nav->verts[t[(j+1)%3]*2]);
			}
		}
	}
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
	
}


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
		
		tapeTex.load("tape.png",IMG_REPEAT);
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
	Image tapeTex;
	int cap;
	float* edirs;
	float* elens;
	char* eflags;
};

BoundaryData g_bdata;

void drawBoundary(const float* verts, const int nverts, const float zoom)
{
	g_bdata.init();
	g_bdata.reserve(nverts);

	// Calc edge dirs.
	for (int i = 0, j = nverts-1; i < nverts; j=i++)
	{
		const float* pa = &verts[j*2];
		const float* pb = &verts[i*2];
		float* dir = &g_bdata.edirs[j*2];
		vsub(dir, pb,pa);
		float len = vlen(dir);
		if (len > 0.001f)
		{
			dir[0] /= len;
			dir[1] /= len;
		}
		else
		{
			printf("%d zero!\n", j);
		}
		g_bdata.elens[j] = len;
	}
	// Calc edge flags
	for (int i = 0, j = nverts-1, k = nverts-2; i < nverts; k=j, j=i++)
	{
		const float* pa = &verts[k*2];
		const float* pb = &verts[j*2];
		const float* pc = &verts[i*2];
		g_bdata.eflags[j] = triarea(pa,pb,pc) < 0.0f ? 1 : 0;
	}
		
	// Draw boundary
/*	glLineWidth(4.0f*zoom);
	setcolor(ctrans(COL_DARK,192));
	glBegin(GL_LINE_LOOP);
	for (int i = 0; i < nverts; ++i)
		glVertex2fv(&verts[i*2]);
	glEnd();
	
	glPointSize(4.0f*zoom);
	glColor4ub(255,0,0,255);
	glBegin(GL_POINTS);
	for (int i = 0; i < nverts; ++i)
	{
		if (g_bdata.eflags[i])
			glVertex2fv(&verts[i*2]);
	}
	glEnd();
	glPointSize(1.0f);
	glLineWidth(1.0f);*/
	
	
	const float w = 0.15f;
	const float w0 = w * -0.1f;
	const float w1 = w * 0.9f;
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, g_bdata.tapeTex.texId());
	
	const float dv = 1.0f / (w*2);
	
	glBegin(GL_QUADS);
	glColor4ub(255,255,255,255);
	for (int i = 0, j = nverts-1; i < nverts; j=i++)
	{
		const float* pa = &verts[j*2];
		const float* pb = &verts[i*2];
		const float* dir = &g_bdata.edirs[j*2];
		const float norm[2] = {dir[1],-dir[0]};
		const float len = g_bdata.elens[j];
		const char fa = g_bdata.eflags[j];
		const char fb = g_bdata.eflags[i];

		float exa = fa ? -w*0.9f : 0; //min(len/2-w, fa ? 0 : -w);
		float exb = fb ? w*0.9f : 0; //max(len/2+w, fb ? 0 : w);
		
//		glColor4ub(255,0,0,64);
		
		glTexCoord2f(0,0);
		glVertex2f(pa[0]+norm[0]*w0+dir[0]*exa,pa[1]+norm[1]*w0+dir[1]*exa);
		glTexCoord2f(0.5f,0);
		glVertex2f(pa[0]+norm[0]*w1+dir[0]*exa,pa[1]+norm[1]*w1+dir[1]*exa);

		glTexCoord2f(0.5f,0.5f);
		glVertex2f(pa[0]+norm[0]*w1+dir[0]*(exa+w),pa[1]+norm[1]*w1+dir[1]*(exa+w));
		glTexCoord2f(0,0.5f);
		glVertex2f(pa[0]+norm[0]*w0+dir[0]*(exa+w),pa[1]+norm[1]*w0+dir[1]*(exa+w));

//		glColor4ub(255,255,255,64);

		glTexCoord2f(0.5f,0);
		glVertex2f(pa[0]+norm[0]*w0+dir[0]*(exa+w),pa[1]+norm[1]*w0+dir[1]*(exa+w));
		glTexCoord2f(1,0);
		glVertex2f(pa[0]+norm[0]*w1+dir[0]*(exa+w),pa[1]+norm[1]*w1+dir[1]*(exa+w));

		glTexCoord2f(1,len*dv);
		glVertex2f(pb[0]+norm[0]*w1+dir[0]*(exb-w),pb[1]+norm[1]*w1+dir[1]*(exb-w));
		glTexCoord2f(0.5f,len*dv);
		glVertex2f(pb[0]+norm[0]*w0+dir[0]*(exb-w),pb[1]+norm[1]*w0+dir[1]*(exb-w));

//		glColor4ub(0,255,0,64);

		glTexCoord2f(0,0.5f);
		glVertex2f(pb[0]+norm[0]*w0+dir[0]*(exb-w),pb[1]+norm[1]*w0+dir[1]*(exb-w));
		glTexCoord2f(0.5f,0.5f);
		glVertex2f(pb[0]+norm[0]*w1+dir[0]*(exb-w),pb[1]+norm[1]*w1+dir[1]*(exb-w));

		glTexCoord2f(0.5f,1);
		glVertex2f(pb[0]+norm[0]*w1+dir[0]*exb,pb[1]+norm[1]*w1+dir[1]*exb);
		glTexCoord2f(0,1);
		glVertex2f(pb[0]+norm[0]*w0+dir[0]*exb,pb[1]+norm[1]*w0+dir[1]*exb);
		
	}
	glEnd();
	
	glDisable(GL_TEXTURE_2D);

/*	glBegin(GL_LINES);
	for (int i = 0, j = nverts-1; i < nverts; j=i++)
	{
		const float* pa = &verts[j*2];
		const float* pb = &verts[i*2];
		float delta[2], norm[2], mid[2];
		vsub(delta, pb,pa);
		float len = vlen(delta);
		delta[0] /= len;
		delta[1] /= len;
		
		int n = 1+(int)floorf(len / 0.1f);
		norm[0] = delta[1];
		norm[1] = -delta[0];
		
		const float s = 0.1f;
		const float s2 = 0.1f;
		for (int k = 0; k < n; ++k)
		{
			float u = (float)(k)/(float)n;
			vlerp(mid, pa,pb, u);
			setcolor(ctrans(COL_DARK,192));
			glVertex2f(mid[0],mid[1]);
			setcolor(ctrans(COL_DARK,16));
			glVertex2f(mid[0]+norm[0]*s+delta[0]*s2, mid[1]+norm[1]*s+delta[1]*s2);
		}
		
	}
	glEnd();*/
}

void drawBoundaryWire(const float* verts, const int nverts, const float zoom)
{
	// Draw boundary
	glLineWidth(4.0f*zoom);
	setcolor(ctrans(COL_DARK,192));
	glBegin(GL_LINE_LOOP);
	for (int i = 0; i < nverts; ++i)
		glVertex2fv(&verts[i*2]);
	glEnd();
	glPointSize(4.0f*zoom);
	glBegin(GL_POINTS);
	for (int i = 0; i < nverts; ++i)
		glVertex2fv(&verts[i*2]);
	glEnd();
	glPointSize(1.0f);
	glLineWidth(1.0f);
	glBegin(GL_LINES);
	for (int i = 0, j = nverts-1; i < nverts; j=i++)
	{
		const float* pa = &verts[j*2];
		const float* pb = &verts[i*2];
		float delta[2], norm[2], mid[2];
		vsub(delta, pb,pa);
		float len = vlen(delta);
		delta[0] /= len;
		delta[1] /= len;
		
		int n = 1+(int)floorf(len / 0.1f);
		norm[0] = delta[1];
		norm[1] = -delta[0];
		
		const float s = 0.1f;
		const float s2 = 0.1f;
		for (int k = 0; k < n; ++k)
		{
			float u = (float)(k)/(float)n;
			vlerp(mid, pa,pb, u);
			setcolor(ctrans(COL_DARK,192));
			glVertex2f(mid[0],mid[1]);
			setcolor(ctrans(COL_DARK,16));
			glVertex2f(mid[0]+norm[0]*s+delta[0]*s2, mid[1]+norm[1]*s+delta[1]*s2);
		}
		
	}
	glEnd();
}
