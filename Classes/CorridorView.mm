//
//  Level.m
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CorridorView.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import <float.h>
#import "mathutil.h"
#import "nanosvg.h"
#import "navmesh.h"
#import "math.h"
#import "nanosvg.h"
#import "FishView.h"

@implementation CorridorView
@synthesize moveToFinger;
@synthesize fingerPos;
@synthesize navScene;
 
#define MAX_NAV_AGENTS 8

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


+(id)corridorWithName:(NSString *)levelName
{
	return [[[self alloc] initWithLevelName:levelName] autorelease];
}


-(id)initWithLevelName:(NSString *)levelName 
{
	if((self = [super init]))
	{
         
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        /*
        bodyDef.position.Set(agent->pos[0]/PTM_RATIO,  agent->pos[1]/PTM_RATIO);
        */
        
        [self initMesh:levelName];
        [self initPhysics];
        [self initCorridor:navScene.edge count:navScene.nedge];
        
		NavmeshAgent* agent = &navScene.agents[0];
        
        FishView *fishView = [FishView fishWithName:@"Clown" andWorld:world andPosition:ccp(agent->pos[0],agent->pos[1])];
        FishView *fishView2 = [FishView fishWithName:@"Clown" andWorld:world andPosition:ccp(agent->pos[0],agent->pos[1])];
        currentFish = fishView;
        
        fishes = [NSMutableArray arrayWithObjects:fishView, fishView2, nil];
        
        for(uint i = 0 ; i < [fishes count];i++)
        {
            FishView *fish = (FishView*)[fishes objectAtIndex:i];
            [self addChild:fish];
            [fish setDelegate:self];
        }
        
        [self scheduleUpdate];
	}
	return self;
}


-(SVGPath*)loadMesh:(NSString*)levelName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-mesh",levelName] ofType:@"svg"];
    return svgParseFromFile([path UTF8String]);
}

-(void)initMesh:(NSString*)levelName
{
    SVGPath* plist = [self loadMesh:levelName];
    if (!plist) CCLOG(@"loadMesh: Could not load Mesh");   
    
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
    SVGPath* edgePath = 0;
	SVGPath* boundaryPath = 0;
	SVGPath* agentPaths[MAX_NAV_AGENTS];
	int nagentPaths = 0;
	for (SVGPath* it = plist; it; it = it->next)
	{
		if (it->strokeColor == 0xff000000)
			boundaryPath = it;
		else if (it->strokeColor == 0xff0000ff)
			walkablePath = it;
        else if (it->strokeColor == 0xff00ff00)
			edgePath = it;
		else if (it->strokeColor == 0xffff0000 && !it->closed)
		{
			if (it->npts > 1 && nagentPaths < MAX_NAV_AGENTS)
				agentPaths[nagentPaths++] = it;
		}
	}
	
	if (!boundaryPath) printf("navsceneLoad: No boundary!\n");
	if (!walkablePath) printf("navsceneLoad: No walkable!\n");
	if (!nagentPaths) printf("navsceneLoad: No agents!\n");
    if (!edgePath)printf("navsceneLoad: No edge!\n");

	const float s = 1;
    
    navScene.nedge = edgePath->npts;
	navScene.edge = new float [navScene.nedge*2];
	if (!navScene.edge) printf("navsceneLoad: Out of mem 'edge' (%d).\n", navScene.nedge);
	
	navScene.nwalkable = walkablePath->npts;
	navScene.walkable = new float [navScene.nwalkable*2];
	if (!navScene.walkable) printf("navsceneLoad: Out of mem 'walkable' (%d).\n", navScene.nwalkable);
	
	navScene.nboundary = boundaryPath->npts;
	navScene.boundary = new float [navScene.nboundary*2];
	if (!navScene.boundary) printf("navsceneLoad: Out of mem 'boundary' (%d).\n", navScene.nboundary);
	
    storePath(navScene.edge, edgePath->pts, navScene.nedge, s, bmin, bmax);
	storePath(navScene.walkable, walkablePath->pts, navScene.nwalkable, s, bmin, bmax);
	storePath(navScene.boundary, boundaryPath->pts, navScene.nboundary, s, bmin, bmax);
	
	navScene.nagents = nagentPaths;
	for (int i = 0; i < nagentPaths; ++i)
	{
		NavmeshAgent* ag = &navScene.agents[i];
		agentInit(ag, AGENT_RAD);
		
		const float* pa = &agentPaths[i]->pts[0];
		const float* pb = &agentPaths[i]->pts[(agentPaths[i]->npts-1)*2];
        
        NSLog(@"HEYYYYY : %f : %f",agentPaths[i]->pts[0],agentPaths[i]->pts[(agentPaths[i]->npts-1)*2]);
		
		convertPoint(ag->pos, pa, s, bmin, bmax);
		vcpy(ag->oldpos, ag->pos);
		convertPoint(ag->target, pb, s, bmin, bmax);
        
		vcpy(ag->opos, ag->pos);
		vcpy(ag->otarget, ag->target);
	}
    
    // ADD AGENT FOR CAMERA
    
    navScene.nagents++;
    
    NavmeshAgent* cam = &navScene.agents[navScene.nagents-1];
    agentInit(cam, AGENT_RAD);
    
    NavmeshAgent* ag = &navScene.agents[0];
    
    CGPoint camPoint = ccp(ag->pos[0],ag->pos[1]);
    
    float pa[2];
    pa[0] = camPoint.x;
    pa[1] = camPoint.y;
    
    float pb[2];
    pb[0] = ag->pos[0];
    pb[1] = ag->pos[1];
    
    convertPoint(cam->pos, pa, s, bmin, bmax);
    vcpy(cam->oldpos, cam->pos);
    convertPoint(cam->target, pb, s, bmin, bmax);
    
    vcpy(cam->opos, cam->pos);
    vcpy(cam->otarget, cam->target);
    
    //
	
	if (plist)
		svgDelete(plist);
	
	navScene.dim[0] = (bmax[0]-bmin[0])*s;
	navScene.dim[1] = (bmax[1]-bmin[1])*s;
	
	//	m_dim[0] = (bmax[0]-bmin[0])*s + PADDING_SIZE*2;
	//	m_dim[1] = (bmax[1]-bmin[1])*s + PADDING_SIZE*2;
	
	navScene.nav = navmeshCreate(navScene.walkable, navScene.nwalkable);
	if (!navScene.nav) printf("navsceneLoad: failed to create navmesh\n");
	
	//return true;

    //navsceneInit(&navScene, plist);
}


-(void)initPhysics
{
    b2Vec2 gravity = b2Vec2(0.0f, -5.0f);
    bool doSleep = true;
    world = new b2World(gravity, doSleep);    
    world->SetContinuousPhysics(true);
    debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(debugDraw);
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    debugDraw->SetFlags(flags);		

}

-(void)initCorridor:(float *)vertices count:(int)count
{
    for(int i = 0; i < count * 2 - 2; i+=2)
    {
        [self createEdge:vertices[i] y1:vertices[i+1] x2:vertices[i+2] y2:vertices[i+3]];
    }
    
    [self createEdge:vertices[0] y1:vertices[1] x2:vertices[count * 2 - 2] y2:vertices[count * 2 - 1]];
}

-(void)createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0/PTM_RATIO, 0/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsEdge(b2Vec2(x1/PTM_RATIO, y1/PTM_RATIO), b2Vec2(x2/PTM_RATIO, y2/PTM_RATIO));
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *tch = [[touches allObjects] objectAtIndex:0];
	CGPoint tchLoc = [tch locationInView:tch.view];
	tchLoc = [[CCDirector sharedDirector] convertToGL:tchLoc];
    tchLoc.x += 2000 - [Camera standardCamera].position.x;
    tchLoc.y += 2000 - [Camera standardCamera].position.y;
        
    fingerPos = tchLoc;
	
    const float lx = tchLoc.x;
    const float ly = tchLoc.y;
    
    moveToFinger = true;
			
    float pos[2] = {lx,ly};
    float nearest[2] = {lx,ly};
    if (navScene.nav)
        navmeshFindNearestTri(navScene.nav, pos, nearest);
	
    vcpy(navScene.agents[0].target, nearest);
    vcpy(navScene.agents[0].oldpos, navScene.agents[0].pos);
    agentFindPath(&navScene.agents[0], navScene.nav);
    vset(navScene.agents[0].corner, FLT_MAX,FLT_MAX);
	
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *tch = [[touches allObjects] objectAtIndex:0];
	CGPoint tchLoc = [tch locationInView:tch.view];
    tchLoc = [[CCDirector sharedDirector] convertToGL:tchLoc];
    tchLoc.x += 2000 - [Camera standardCamera].position.x;
    tchLoc.y += 2000 - [Camera standardCamera].position.y;
    
    fingerPos = tchLoc;
}

-(void)setSelectedFish:(FishView *)fish
{
    if(fish == currentFish) return;
    
    NavmeshAgent* agent = &navScene.agents[navScene.nagents-1];
    
    if(!travelling) vset(navScene.agents[navScene.nagents-1].pos, currentFish.fishSprite.position.x,currentFish.fishSprite.position.y);
    
    float pos[2] = {fish.fishSprite.position.x,fish.fishSprite.position.y};
    float nearest[2] = {fish.fishSprite.position.x,fish.fishSprite.position.y};
    
    NSLog(@"Départ agent : %f : %f",agent->pos[0],agent->pos[1]);
    NSLog(@"Départ poisson : %f : %f",currentFish.fishSprite.position.x,currentFish.fishSprite.position.y);
    NSLog(@"Arrivée poisson : %f : %f",fish.fishSprite.position.x,fish.fishSprite.position.y);
    
    if (navScene.nav)
        navmeshFindNearestTri(navScene.nav, pos, nearest);
	
    vcpy(navScene.agents[navScene.nagents-1].target, nearest);
    vcpy(navScene.agents[navScene.nagents-1].oldpos, navScene.agents[navScene.nagents-1].pos);
    agentFindPath(&navScene.agents[navScene.nagents-1], navScene.nav);
    vset(navScene.agents[navScene.nagents-1].corner, FLT_MAX,FLT_MAX);
    
    travelling = YES;
    
    currentFish = fish;
}

-(void)update:(ccTime) dt
{
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
    if(!travelling)
    {        
        CGPoint fishpoint = currentFish.fishSprite.position;
        fishpoint.x -= 2000;
        fishpoint.y -= 2000;
        
        fishpoint.x = -fishpoint.x + 1024/2;
        fishpoint.y = -fishpoint.y + 768/2;
        
        [[Camera standardCamera] setPosition:fishpoint];
    }
    
    if(self.moveToFinger && !travelling)
    {
        [currentFish setPosition:fingerPos];
    }
     
	world->Step(dt, velocityIterations, positionIterations);
    
    if(1 < 2)
	{
	const float maxSpeed = 700.0f;
	NavmeshAgent* agent = &navScene.agents[navScene.nagents-1];
	
	// Find next corner to steer to.
	// Smooth corner finding does a little bit of magic to calculate spline
	// like curve (or first tangent) based on current position and movement direction
	// next couple of corners.
        
	float corner[2],dir[2];
	int last = 1;
	vsub(dir, agent->pos, agent->oldpos); // This delta handles wall-hugging better than using current velocity.
	vnorm(dir);
	vcpy(corner, agent->pos);
	last = agentFindNextCornerSmooth(agent, dir, navScene.nav, corner);
	
        
	if (last && vdist(agent->pos, corner) < 2.0f)
	{
		// Reached goal
		vcpy(agent->oldpos, agent->pos);
		vset(agent->dvel, 0,0);
		vcpy(agent->vel, agent->dvel);
        travelling = NO;
        return;
	}
	
	vsub(agent->dvel, corner, agent->pos);
	
	// Limit desired velocity to max speed.
	
	const float distToTarget = vdist(agent->pos,agent->target);
	const float clampedSpeed = maxSpeed * min(1.0f, distToTarget/agent->rad);
	vsetlen(agent->dvel, clampedSpeed);
	
	vcpy(agent->vel, agent->dvel);
	
	// Move agent
	vscale(agent->delta, agent->vel, dt);
	float npos[2];
	vadd(npos, agent->pos, agent->delta);
	agentMoveAndAdjustCorridor(&navScene.agents[navScene.nagents-1], npos, navScene.nav);
        
        if(travelling)
        {
            CGPoint camPoint = ccp(agent->pos[0],agent->pos[1]);
            camPoint.x -= 2000;
            camPoint.y -= 2000;
            
            camPoint.x = -camPoint.x + 1024/2;
            camPoint.y = -camPoint.y + 768/2;
            [[Camera standardCamera] setPosition:camPoint];
        }
    }
}

-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity
{
    b2Vec2 f = b2Vec2(antiGravity.x, antiGravity.y);
    f*= body->GetMass();
    body->ApplyForce(f, body->GetWorldCenter());
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    moveToFinger = false;
}

- (void) dealloc
{
	delete world;
	world = NULL;	
	delete debugDraw;
	[super dealloc];
}

-(void)draw
{
    //[self drawNavMesh];
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	world->DrawDebugData();
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	[super draw];
}

-(CGPoint)convertVertToCGPoint:(float*)v;
{
	return ccp(v[0], v[1]);
}

@end
