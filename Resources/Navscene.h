#ifndef NAVSCENE_H
#define NAVSCENE_H

static const float AGENT_RAD = 0.25f;
static const int MAX_NAV_AGENTS = 16;

struct NavScene
{
	float* boundary;
	int nboundary;
	float* walkable;
	int nwalkable;
	NavmeshAgent agents[MAX_NAV_AGENTS];
	int nagents;
	Navmesh* nav;
	float dim[2];
};

bool navsceneLoad(NavScene* scene, const char* path);
void navsceneDelete(NavScene* scene);

enum AgentDrawFlags
{
	AGENTDRAW_CORNER = 1,
	AGENTDRAW_CORRIDOR = 2,
	AGENTDRAW_VISITED = 4,
	AGENTDRAW_GOAL = 8,
};
void agentTrailDraw(struct NavmeshAgent* agent, struct Navmesh* nav, const float zoom);
void agentDraw(struct NavmeshAgent* agent, struct Navmesh* nav, int flags, const float zoom);
void navmeshDraw(struct Navmesh* nav, const float zoom);
void drawBoundary(const float* verts, const int nverts, const float zoom);

#endif // NAVSCENE_H