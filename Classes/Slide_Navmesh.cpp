#import "Slide.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import <float.h>
#import "mathutil.h"
#import "SDL.h"
#import "SDL_Opengl.h"
#import "font.h"
#import "nanosvg.h"
#import "navmesh.h"
#import "Navscene.h"

static const float PADDING_SIZE = 0.4f;

enum AgentMoveMode
{
	AGENTMOVE_NONE,
	AGENTMOVE_STRAIGHT,
	AGENTMOVE_SMOOTH,
	AGENTMOVE_DRUNK,
};



class SlideNavmesh : public Slide
{
protected:

	char m_filepath[256];

	bool m_expanded;

	NavScene m_scene;
		
	bool m_step;
	bool m_update;
	
	bool m_drawCorner;
	bool m_drawCorridor;
	bool m_drawVisited;
	bool m_drawGraph;
	bool m_drawDelta;
	
	int m_moveMode;
	
public:
	SlideNavmesh();
	virtual ~SlideNavmesh();
	
	virtual const char* cname();
	virtual bool param(const char* token, const char* data); 
	virtual bool init(); 
	virtual void save(FILE* fp);
	virtual bool mouseDown(const float x, const float y); 
	virtual void mouseMove(const float x, const float y); 
	virtual void mouseUp(const float x, const float y);
	virtual void keyDown(const int key);
	virtual void update(const float dt);
	virtual void draw(const float* view, const float zoom, bool highlight);
};

DEFINE_SLIDE_FACTORY(SlideNavmesh, "navmesh")


SlideNavmesh::SlideNavmesh() :
	m_expanded(false),
	m_step(false),
	m_update(false),
	m_drawCorner(false),
	m_drawCorridor(false),
	m_drawVisited(false),
	m_drawGraph(false),
	m_moveMode(AGENTMOVE_SMOOTH)
{
}

SlideNavmesh::~SlideNavmesh()
{
	navsceneDelete(&m_scene);
}

const char* SlideNavmesh::cname()
{
	return "navmesh";
}

bool SlideNavmesh::param(const char* token, const char* data)
{
	if (Slide::param(token, data))
		return true;
	
	if (strcmp(token, "file") == 0)
	{
		strncpy(m_filepath, data, sizeof(m_filepath));
		return true;
	}
	
	return false;
}

bool SlideNavmesh::init()
{
	if (!navsceneLoad(&m_scene, m_filepath))
	{
		return false;
	}
	
	m_dim[0] = m_scene.dim[0] + PADDING_SIZE*2;
	m_dim[1] = m_scene.dim[1] + PADDING_SIZE*2;
	
	const float bw = BUTTON_WIDTH*0.7f;
	float x = PADDING_SIZE;
	float y = PADDING_SIZE/4;
	addButton(3,"Graph",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(2,"Corridor",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(1,"Corner",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(9,"Delta",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(8,"Visited",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	
	x += 0.3f;
	
	addButton(5,"Straight",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(6,"Smooth",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;
	addButton(7,"Drunk",x,y,bw,BUTTON_HEIGHT);
	x += bw+0.1f;

	m_expanded = true;
	m_step = false;
	m_update = false;
	
	return true;
}

void SlideNavmesh::save(FILE* fp)
{
	Slide::save(fp);
	
	fprintf(fp, "\tfile %s\n", m_filepath);
}

bool SlideNavmesh::mouseDown(const float x, const float y)
{
	if (!m_expanded)
	{
		if (hitCorner(x,y))
		{
			startDrag(1, x,y, m_pos);
			return true;
		}
	}
	else
	{
		int bidx = hitButtons(x-m_pos[0],y-m_pos[1]);
		if (bidx != -1)
		{
			return true;
		}
		else if (hitCorner(x,y))
		{
			startDrag(1, x,y, m_pos);
			return true;
		}
		else if (hitArea(x,y))
		{
			const float lx = x - (m_pos[0]+PADDING_SIZE);
			const float ly = y - (m_pos[1]+PADDING_SIZE);

			float pos[2] = {lx,ly};
			float nearest[2] = {lx,ly};
			if (m_scene.nav)
				navmeshFindNearestTri(m_scene.nav, pos, nearest);
			
			if (SDL_GetModState() & KMOD_SHIFT)
			{
				agentMoveAndAdjustCorridor(&m_scene.agents[0], nearest, m_scene.nav);
				vcpy(m_scene.agents[0].oldpos, m_scene.agents[0].pos);
				vset(m_scene.agents[0].corner, FLT_MAX,FLT_MAX);
			}
			else
			{
				vcpy(m_scene.agents[0].target, nearest);
				vcpy(m_scene.agents[0].oldpos, m_scene.agents[0].pos);
				agentFindPath(&m_scene.agents[0], m_scene.nav);
				vset(m_scene.agents[0].corner, FLT_MAX,FLT_MAX);
			}

			return true;
		}
	}
	return false;
}

void SlideNavmesh::mouseMove(const float x, const float y)
{
	if (m_drag == 1)
	{
		updateDrag(x,y, m_pos);
	}
	else
	{
		hitButtons(x-m_pos[0],y-m_pos[1]);
	}
}

void SlideNavmesh::mouseUp(const float x, const float y)
{
	if (m_drag == 1)
	{
		if (!m_dragMoved)
			m_expanded = !m_expanded;
	}
	else
	{
		int bidx = hitButtons(x-m_pos[0],y-m_pos[1]);
		switch (bidx)
		{
			case 1:
				m_drawCorner = !m_drawCorner;
				break;
			case 2:
				m_drawCorridor = !m_drawCorridor;
				break;
			case 8:
				m_drawVisited = !m_drawVisited;
				break;
			case 3:
				m_drawGraph = !m_drawGraph;
				break;
			case 5:
				m_moveMode = AGENTMOVE_STRAIGHT;
				break;
			case 6:
				m_moveMode = AGENTMOVE_SMOOTH;
				break;
			case 7:
				m_moveMode = AGENTMOVE_DRUNK;
				break;
			case 9:
				m_drawDelta = !m_drawDelta;
				break;
		}
	}
	
	m_selButton = -1;
	m_drag = 0;
}

void SlideNavmesh::keyDown(const int key)
{
	if (key == SDLK_SPACE)
	{
		m_update = !m_update;
	}
	else if (key == SDLK_1)
	{
		m_update = false;
		m_step = true;
	}
	else if (key == SDLK_r)
	{
		m_scene.agents[0].nvisited = 0;		
		m_scene.agents[0].ntrail = 0;		
		m_scene.agents[0].htrail = 0;		
	}
}

void SlideNavmesh::update(const float dt)
{
	if (!m_update && !m_step)
		return;
	m_step = false;

	const float maxSpeed = 1.0f;
	NavmeshAgent* agent = &m_scene.agents[0];
	
	// Find next corner to steer to.
	// Smooth corner finding does a little bit of magic to calculate spline
	// like curve (or first tangent) based on current position and movement direction
	// next couple of corners.
	float corner[2],dir[2];
	int last = 1;
	vsub(dir, agent->pos, agent->oldpos); // This delta handles wall-hugging better than using current velocity.
	vnorm(dir);
	vcpy(corner, agent->pos);
	if (m_moveMode == AGENTMOVE_SMOOTH || m_moveMode == AGENTMOVE_DRUNK)
		last = agentFindNextCornerSmooth(agent, dir, m_scene.nav, corner);
	else
		last = agentFindNextCorner(agent, m_scene.nav, corner);
		
	if (last && vdist(agent->pos, corner) < 0.02f)
	{
		// Reached goal
		vcpy(agent->oldpos, agent->pos);
		vset(agent->dvel, 0,0);
		vcpy(agent->vel, agent->dvel);
		return;
	}

	vsub(agent->dvel, corner, agent->pos);

	// Apply style
	if (m_moveMode == AGENTMOVE_DRUNK)
	{
		agent->t += dt*4;
		float amp = cosf(agent->t)*0.25f;
		float nx = -agent->dvel[1];
		float ny = agent->dvel[0];
		agent->dvel[0] += nx * amp;
		agent->dvel[1] += ny * amp;
	}
	
	// Limit desired velocity to max speed.
	const float distToTarget = vdist(agent->pos,agent->target);
	const float clampedSpeed = maxSpeed * min(1.0f, distToTarget/agent->rad);
	vsetlen(agent->dvel, clampedSpeed);

	vcpy(agent->vel, agent->dvel);

	// Move agent
	vscale(agent->delta, agent->vel, dt);
	float npos[2];
	vadd(npos, agent->pos, agent->delta);
	agentMoveAndAdjustCorridor(&m_scene.agents[0], npos, m_scene.nav);

}

void SlideNavmesh::draw(const float* view, const float zoom, bool highlight)
{
	if (!visible(view))
		return;
	
	drawCorner(!m_expanded);
	
	if (!m_expanded)
		return;
	
	glPushMatrix();
	glTranslatef(m_pos[0],m_pos[1],0);

//	drawDropShadow(0,0, m_dim[0],m_dim[1], highlight ? 2 : 1);
	
/*	if (highlight)
		glColor4ub(255,255,255,128);
	else
		glColor4ub(255,255,255,96);*/

	setcolor(COL_BACK);
//	drawBG(0,0,m_dim[0],m_dim[1]);
	
	
	glPushMatrix();
	glTranslatef(PADDING_SIZE,PADDING_SIZE,0);

	drawBoundary(m_scene.boundary, m_scene.nboundary, zoom);
	
	// Draw navmesh
	if (m_drawGraph)
		navmeshDraw(m_scene.nav, zoom);

	// Draw Agent
	int aflags = 0;
	if (m_drawCorner)
		aflags |= AGENTDRAW_CORNER;
	if (m_drawCorridor)
		aflags |= AGENTDRAW_CORRIDOR;
	if (m_drawVisited)
		aflags |= AGENTDRAW_VISITED;

	NavmeshAgent* ag = &m_scene.agents[0];
	
	agentTrailDraw(ag, m_scene.nav, zoom);
	agentDraw(ag, m_scene.nav, aflags, zoom);

	// Actual
	if (m_drawDelta)
	{
		glLineWidth(2.0f*zoom);
		setcolor(COL_DARK);
		drawarrow(ag->pos[0],ag->pos[1],
				  ag->pos[0]+ag->vel[0], ag->pos[1]+ag->vel[1],0.1f);
	}
	
	glPopMatrix();

	drawButtons();

/*
	setcolor(clerp(COL_DIM,COL_BACK,128));
	glPointSize(1.0f);
	glLineWidth(1.0f);
	
//	drawtext(PADDING_SIZE,PADDING_SIZE/2, 0.07f, "M A S T E R   P L A N");
	const float ts = 0.07f;
	float sx;
	float x = PADDING_SIZE;
	float y = PADDING_SIZE/3;
	sx = x;
	drawtext(x,y, ts, "Corner");
	x += 0.7f;
	drawtext(x,y, ts, "Corridor");
	x += 0.7f;
	drawtext(x,y, ts, "Mesh");
	x += 0.7f;

	glBegin(GL_LINES);
	glVertex2f(x,y+ts*1.5f);
	glVertex2f(sx,y+ts*1.5f);
	glEnd();
	
	x += 0.5f;

	sx = x;
	drawtext(x,y, ts, "Straight");
	x += 0.7f;
	drawtext(x,y, ts, "Smooth");
	x += 0.7f;
	drawtext(x,y, ts, "Drunk");
	x += 0.7f;

	glBegin(GL_LINES);
	glVertex2f(x,y+ts*1.5f);
	glVertex2f(sx,y+ts*1.5f);
	glEnd();
*/
	
	glPopMatrix();
}
