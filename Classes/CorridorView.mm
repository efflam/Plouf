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

@implementation CorridorView
@synthesize moveToFinger;
@synthesize fingerPos;
@synthesize navScene;
@synthesize delegate;


b2Body *fish;
CCSprite* fishImage;

#define MAX_NAV_AGENTS 8
#define PTM_RATIO 32

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
        
        
        [self initMesh:levelName];
        [self initPhysics];
        [self initCorridor:navScene.walkable count:navScene.nwalkable];
		
        
		CCSprite *fishSprite = [CCSprite spriteWithFile:@"fish.png"];
		[self addChild:fishSprite];
        fishImage = fishSprite;
		
		NavmeshAgent* agent = &navScene.agents[0];
		[fishSprite setPosition:ccp(agent->pos[0], agent->pos[1])];
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.angularDamping = 10.0f;
        bodyDef.linearDamping = 1.0f;
        bodyDef.position.Set(agent->pos[0]/PTM_RATIO,  agent->pos[1]/PTM_RATIO);
        //bodyDef.userData = fishSprite;
        fish = world->CreateBody(&bodyDef);
        b2CircleShape circle;
       // circle.m_p.Set(1.0f, 2.0f, 3.0f);
        circle.m_radius = 1.0f;
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &circle;	
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.1f;
        fixtureDef.restitution = 0.1f;
        fish->CreateFixture(&fixtureDef);
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
	
	navScene.nwalkable = walkablePath->npts;
	navScene.walkable = new float [navScene.nwalkable*2];
	if (!navScene.walkable)
	{
		printf("navsceneLoad: Out of mem 'walkable' (%d).\n", navScene.nwalkable);
		//return false;
	}
	
	navScene.nboundary = boundaryPath->npts;
	navScene.boundary = new float [navScene.nboundary*2];
	if (!navScene.boundary)
	{
		printf("navsceneLoad: Out of mem 'boundary' (%d).\n", navScene.nboundary);
		//return false;
	}
	
	storePath(navScene.walkable, walkablePath->pts, navScene.nwalkable, s, bmin, bmax);
	storePath(navScene.boundary, boundaryPath->pts, navScene.nboundary, s, bmin, bmax);
	
	navScene.nagents = nagentPaths;
	for (int i = 0; i < nagentPaths; ++i)
	{
		NavmeshAgent* ag = &navScene.agents[i];
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
	
	navScene.dim[0] = (bmax[0]-bmin[0])*s;
	navScene.dim[1] = (bmax[1]-bmin[1])*s;
	
	//	m_dim[0] = (bmax[0]-bmin[0])*s + PADDING_SIZE*2;
	//	m_dim[1] = (bmax[1]-bmin[1])*s + PADDING_SIZE*2;
	
	navScene.nav = navmeshCreate(navScene.walkable, navScene.nwalkable);
	if (!navScene.nav)
	{
		printf("navsceneLoad: failed to create navmesh\n");
		//return false;
	}
    
	
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
    tchLoc.x += 2000 - delegate.position.x;
    tchLoc.y += 2000 - delegate.position.y;
    
    NSLog(@"position touch : %f",tch.view.frame.origin.x);
    
    fingerPos =tchLoc;
	
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
    tchLoc.x += 2000 - delegate.position.x;
    tchLoc.y += 2000 - delegate.position.y;
    
    fingerPos = tchLoc;
}

-(void)update:(ccTime) dt
{
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
    
    if(self.moveToFinger)
    {
        b2Vec2 tchPos = b2Vec2(fingerPos.x / PTM_RATIO, fingerPos.y / PTM_RATIO);
        b2Vec2 fishPos = fish->GetPosition();
        b2Vec2 fishToTch = tchPos - fishPos;
        float dist = fishToTch.Normalize();
        float maxSpeed = 100;
        b2Vec2 desiredVelocity = b2Vec2(fishToTch.x, fishToTch.y);
        //desiredVelocity *=  fminf(dist * dist, maxSpeed);
        desiredVelocity *=  maxSpeed;
        b2Vec2 steeringForce = desiredVelocity - fish->GetLinearVelocity();
        steeringForce *= 1/fish->GetMass();
        
        b2Vec2 appPtOffset = b2Vec2(15, 0);
        fish->ApplyForce(steeringForce, fish->GetWorldPoint(appPtOffset));

    }
    
    b2Vec2 gravity = world->GetGravity();
    b2Vec2 antiGravity = b2Vec2(-gravity.x, -gravity.y);
    //antiGravity *= -1;
    [self counterGravity:fish antiGravity:antiGravity];
    
	world->Step(dt, velocityIterations, positionIterations);
    
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    
    if(1 < 2)
    
	{
	const float maxSpeed = 200.0f;
	NavmeshAgent* agent = &navScene.agents[0];
	
	// Find next corner to steer to.
	// Smooth corner finding does a little bit of magic to calculate spline
	// like curve (or first tangent) based on current position and movement direction
	// next couple of corners.
	float corner[2],dir[2];
	int last = 1;
	vsub(dir, agent->pos, agent->oldpos); // This delta handles wall-hugging better than using current velocity.
	vnorm(dir);
	vcpy(corner, agent->pos);
	//if (m_moveMode == AGENTMOVE_SMOOTH || m_moveMode == AGENTMOVE_DRUNK)
	last = agentFindNextCornerSmooth(agent, dir, navScene.nav, corner);
	//else
	//	last = agentFindNextCorner(agent, navScene.nav, corner);
	
	//CCLOG(@"corner x=%f y=%f", corner[0], corner[1]);
	
	
	if (last && vdist(agent->pos, corner) < 2.0f)
	{
		// Reached goal
		vcpy(agent->oldpos, agent->pos);
		vset(agent->dvel, 0,0);
		vcpy(agent->vel, agent->dvel);
		return;
	}
	
	vsub(agent->dvel, corner, agent->pos);
	
	// Apply style
	/*
	if (m_moveMode == AGENTMOVE_DRUNK)
	{
		agent->t += dt*4;
		float amp = cosf(agent->t)*0.25f;
		float nx = -agent->dvel[1];
		float ny = agent->dvel[0];
		agent->dvel[0] += nx * amp;
		agent->dvel[1] += ny * amp;
	}
	*/
	// Limit desired velocity to max speed.
	
	const float distToTarget = vdist(agent->pos,agent->target);
	//CCLOG(@"distToTarget = %f", distToTarget);
	const float clampedSpeed = maxSpeed * min(1.0f, distToTarget/agent->rad);
	vsetlen(agent->dvel, clampedSpeed);
	
	vcpy(agent->vel, agent->dvel);
	
	// Move agent
	vscale(agent->delta, agent->vel, dt);
	float npos[2];
	vadd(npos, agent->pos, agent->delta);
	agentMoveAndAdjustCorridor(&navScene.agents[0], npos, navScene.nav);
	
	float angleInRad = atan2(agent->vel[0], agent->vel[1]);
	float angleInDeg = angleInRad * 180.0f / M_PI - 90.0f;
	float s = abs(fishImage.scale);
	BOOL flip = NO;
	if(sinf(angleInRad) < 0)
	{
		angleInDeg -= 180;
		s = -s;
		flip = YES;
	}
	

        [fishImage setFlipX:flip];
        [fishImage setRotation:angleInDeg];
        [fishImage setPosition:ccp(agent->pos[0], agent->pos[1])];
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


-(void) addNewSpriteWithCoords:(CGPoint)p
{
    /*
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
    [batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
     */
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
    [self drawNavMesh];
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	world->DrawDebugData();
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	[super draw];
}

-(void)drawNavMesh
{
    Navmesh* nav = navScene.nav;
	glColor4f(0.8, 1.0, 0.76, 1.0);  
	glLineWidth(1.0f);
	CGPoint vertices[3];
	for (int i = 0; i < nav->ntris; ++i)
	{
		const unsigned short* t = &nav->tris[i*6];
		vertices[0] = ccpMult([self convertVertToCGPoint:&nav->verts[t[0]*2]], 1);
		vertices[1] = ccpMult([self convertVertToCGPoint:&nav->verts[t[1]*2]], 1);
		vertices[2] = ccpMult([self convertVertToCGPoint:&nav->verts[t[2]*2]], 1);
        ccDrawPoly(vertices, 3, YES);
	}
}

-(CGPoint)convertVertToCGPoint:(float*)v;
{
	return ccp(v[0], v[1]);
}





@end
