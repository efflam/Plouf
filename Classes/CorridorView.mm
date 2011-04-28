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
#import "Navscene.h"
#import "math.h"

@implementation CorridorView
@synthesize moveToFinger;
@synthesize fingerPos;
@synthesize navScene;

#define MAX_NAV_AGENTS 3

NavScene navScene;
b2Body *fish;
CCSprite* fishImage;


#define PTM_RATIO 32


+(id)corridorWithName:(NSString *)levelName
{
	return [[[self alloc] initWithLevelName:levelName] autorelease];
}


-(id)initWithLevelName:(NSString *)levelName 
{
	if((self = [super init]))
	{
         
         
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        [self initNavMesh:levelName];
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


-(void)initNavMesh:(NSString*)levelName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-mesh",levelName] ofType:@"svg"];
    navsceneLoad(&navScene, [path UTF8String]);
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
    int num = count * 2 - 2;
    for(int i = 0; i < num; i+=2)
    {
        [self createEdge:vertices[i] y1:vertices[i+1] x2:vertices[i+2] y2:vertices[i+3]];
    }
    [self createEdge:vertices[0] y1:vertices[1] x2:vertices[count] y2:vertices[count + 1]];
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


-(void) touchAtPosition:(CGPoint)point
{
    fingerPos = point;
	
    const float lx = point.x;
    const float ly = point.y;
    
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

/*
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *tch = [[touches allObjects] objectAtIndex:0];
	CGPoint tchLoc = [tch locationInView:tch.view];
	tchLoc = [[CCDirector sharedDirector] convertToGL:tchLoc];
    tchLoc.x += 2000;
    tchLoc.y += 2000;
    
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
 */

// Move at position
-(void) moveAtPosition:(CGPoint)point
{
    fingerPos = point;
}

/*
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"dfqsf");
    UITouch *tch = [[touches allObjects] objectAtIndex:0];
	CGPoint tchLoc = [tch locationInView:tch.view];
	//tchLoc = [[CCDirector sharedDirector] convertToGL:tchLoc];
    fingerPos = [[CCDirector sharedDirector] convertToGL:tchLoc];
    //tchLoc = ccpMult(tchLoc, 1 / PTM_RATIO);
        
    
}
*/

-(void)update:(ccTime) dt
{
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
    
    if(moveToFinger)
    {
        CCLOG(@"moveToFinger");
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
	navmeshDraw(navScene.nav, 1);
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	world->DrawDebugData();
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	[super draw];
}

@end
