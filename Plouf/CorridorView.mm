//
//  CorridorView.m
//  ProtoSV-GL
//
//  Created by Efflam on 26/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
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


#define PTM_RATIO 32

@implementation CorridorView

@synthesize moveToFinger;
@synthesize fingerPos;
@synthesize world;
@synthesize fish;
@synthesize navScene;

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        [self initNavMeshWithName:levelName];
        [self initPhysics];
        [self initCorridor:navScene.walkable count:navScene.nwalkable];
        [self initFishWithFile:@"fish.png" x:100 y:100];
        [self scheduleUpdate];
        
        [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
    }
    
    return self;
}

+(id)corridorWithName:(NSString*)levelName
{
    return [[[CorridorView alloc] initWithLevelName:levelName] autorelease];
}

-(void)initNavMeshWithName:(NSString*)levelName
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-mesh",levelName] ofType:@"svg"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"navmesh" ofType:@"svg"];
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
    //flags += b2DebugDraw::e_jointBit;
    //flags += b2DebugDraw::e_aabbBit;
    //flags += b2DebugDraw::e_pairBit;
    //flags += b2DebugDraw::e_centerOfMassBit;
    debugDraw->SetFlags(flags);
}

-(void)initCorridor:(float *)points count:(int)count
{
    int i;
    for(i = 0; i < count * 2 - 2; i+=2)
    {
        [self   createEdge: points[i] 
                y1:         points[i+1]
                x2:         points[i+2] 
                y2:         points[i+3]];
    }
    
    [self   createEdge: points[0] 
            y1:         points[1]
            x2:         points[i] 
            y2:         points[i+1]];
}

-(void)createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0/PTM_RATIO, 0/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    
    b2PolygonShape edge;
    edge.SetAsEdge(b2Vec2(x1/PTM_RATIO, y1/PTM_RATIO), b2Vec2(x2/PTM_RATIO, y2/PTM_RATIO));
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &edge;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
}

-(void)initFishWithFile:(NSString *)file x:(float)x y:(float)y
{
    CCSprite *fishSprite = [CCSprite spriteWithFile:file];
    [self addChild:fishSprite];
    [fishSprite setPosition:ccp(x, y)];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.angularDamping = 10.0f;
    bodyDef.linearDamping = 1.0f;
    bodyDef.position.Set(x/PTM_RATIO, y/PTM_RATIO);
    bodyDef.userData = fishSprite;
    fish = world->CreateBody(&bodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 1.0f;
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circle;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.1f;
    fixtureDef.restitution = 0.1f;
    fish->CreateFixture(&fixtureDef);
}

-(void)counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity
{
    b2Vec2 f = b2Vec2(antiGravity.x, antiGravity.y);
    f*= body->GetMass();
    body->ApplyForce(f, body->GetWorldCenter());
}


-(void)addNewSpriteWithCoords:(CGPoint)p
{
    
}

-(void)update:(ccTime) dt
{
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
    if(moveToFinger)
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
    [self counterGravity:fish antiGravity:antiGravity];
    
	world->Step(dt, velocityIterations, positionIterations);
    
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
        {
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    
    if(1 > 2)
        
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
        /*	
         float angleInRad = atan2(agent->vel[0], agent->vel[1]);
         float angleInDeg = angleInRad * 180.0f / M_PI - 90.0f;
         float s = abs(fish.scale);
         BOOL flip = NO;
         if(sinf(angleInRad) < 0)
         {
         angleInDeg -= 180;
         s = -s;
         flip = YES;
         }
         
         */
        //
        //if(fish.scaleX != s) fish.scaleX = s;
        //	[fish setFlipX:flip];
        //	[fish setRotation:angleInDeg];
        //	[fish setPosition:ccp(agent->pos[0], agent->pos[1])];
    }
}


-(void) draw
{
    [super draw];
   
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    navmeshDraw(navScene.nav, 1);
}


@end
