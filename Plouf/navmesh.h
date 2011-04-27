#ifndef NAVMESH_H
#define NAVMESH_H

#ifdef __cplusplus
extern "C" {
#endif

struct Navmesh
{
	float* verts;
	int nverts;
	unsigned short* tris;
	int ntris;
};

// Creates navmesh from a polygon.
struct Navmesh* navmeshCreate(const float* pts, const int npts);

// Find nearest triangle
int navmeshFindNearestTri(struct Navmesh* nav, const float* pos, float* nearest);

// Find path
int navmeshFindPath(struct Navmesh* nav, const float* start, const float* end, unsigned short* path, const int maxpath);

// Find tight rope path
int navmeshStringPull(struct Navmesh* nav, const float* start, const float* end,
					  const unsigned short* path, const int npath,
					  float* pts, const int maxpts);

// Move along navmesh
int navmeshMoveAlong(struct Navmesh* nav, float* start, const unsigned short idx, const float* target,
					 unsigned short* visited, const int maxvisited);

// Deletes navmesh.
void navmeshDelete(struct Navmesh* nav);



#define AGENT_MAX_TRAIL 64
#define AGENT_MAX_PATH 128

#define VEL_HIST_SIZE 6

struct NavmeshAgent
{
	float rad;
	float pos[2];
	float oldpos[2];
	float target[2];
	float delta[2];
	float corner[2];

	float npos[2];
	float disp[2];
	
	float vel[2];
	float pvel[2];
	float dvel[2];
	float nvel[2];

	float hvel[VEL_HIST_SIZE*2];	// history of velocities.
	int hhead;
	
	float opos[2], otarget[2];
	
	float t;
	unsigned short visited[AGENT_MAX_PATH];
	int nvisited;
	unsigned short path[AGENT_MAX_PATH];
	int npath;
	
	float trail[AGENT_MAX_TRAIL*2];
	int htrail;
	int ntrail;
};

struct MemPool
{
        unsigned char* buf;
        unsigned int cap;
        unsigned int size;
};
	
int posValid(const float* p);
void agentInit(struct NavmeshAgent* agent, const float rad);
void agentFindPath(struct NavmeshAgent* agent, struct Navmesh* nav);

int getDebugLineCount();
const float* getDebugLine(int i);

int agentFindNextCorner(struct NavmeshAgent* agent, struct Navmesh* nav, float* corner);
int agentFindNextCornerSmooth(struct NavmeshAgent* agent, const float* dir, struct Navmesh* nav, float* corner);
int agentCalcSmoothSteerVel(struct NavmeshAgent* agent, struct Navmesh* nav, const float maxSpeed, const float dt);

void agentMoveAndAdjustCorridor(struct NavmeshAgent* agent, const float* target, struct Navmesh* nav);
	

#ifdef __cplusplus
}
#endif
		

#endif