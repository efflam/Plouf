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

#define MAX_NAV_AGENTS 3

NavScene navScene;
b2Body *fish;
CCSprite* fishImage;
//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

-(id)initWithLevelName:(NSString *)levelName 
{
	if((self = [super init]))
	{
		//self.isTouchEnabled = true;
		
         // enable touches
        // self.isTouchEnabled = YES;
         
         // enable accelerometer
         //self.isAccelerometerEnabled = YES;
         
         CGSize screenSize = [CCDirector sharedDirector].winSize;
         CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
         
         // Define the gravity vector.
         b2Vec2 gravity;
         gravity.Set(0.0f, -5.0f);
         
         // Do we want to let bodies sleep?
         // This will speed up the physics simulation
         bool doSleep = true;
         
         // Construct a world object, which will hold and simulate the rigid bodies.
         world = new b2World(gravity, doSleep);
         
         world->SetContinuousPhysics(true);
         
         // Debug Draw functions
         m_debugDraw = new GLESDebugDraw( PTM_RATIO );
         world->SetDebugDraw(m_debugDraw);
         
         uint32 flags = 0;
         flags += b2DebugDraw::e_shapeBit;
         //		flags += b2DebugDraw::e_jointBit;
         //		flags += b2DebugDraw::e_aabbBit;
         //		flags += b2DebugDraw::e_pairBit;
         //		flags += b2DebugDraw::e_centerOfMassBit;
         m_debugDraw->SetFlags(flags);		
         
        //b2_maxPolygonVertices -> 100;
        b2Vec2 vertices[7];
        
        //row 1, col 1
        int num = 7;
        vertices[0].Set(-158.0f / PTM_RATIO, 113.0f / PTM_RATIO);
        vertices[1].Set(-183.0f / PTM_RATIO, 118.0f / PTM_RATIO);
        vertices[2].Set(-219.0f / PTM_RATIO, 95.0f / PTM_RATIO);
        vertices[3].Set(-238.0f / PTM_RATIO, 43.0f / PTM_RATIO);
        vertices[4].Set(-198.0f / PTM_RATIO, -100.0f / PTM_RATIO);
        vertices[5].Set(-102.0f / PTM_RATIO, -102.0f / PTM_RATIO);
        vertices[6].Set(-68.0f / PTM_RATIO, 27.0f / PTM_RATIO);
        
        
        
        /*
        b2BodyDef bodyDef;
        b2PolygonShape shape; 
        shape.Set(vertices, count);
        b2FixtureDef fixtureDef; 
        fixtureDef.shape = &shape; 
        fixtureDef.density = 1.0f; 
        fixtureDef.friction = 0.2f;
        fixtureDef.restitution = 0.1f;
        b2Body* body = world->CreateBody(&bodyDef);
        body->CreateFixture(&fixtureDef);
        */
        
        
        
        /*
        
        b2BodyDef bd;
        b2Body* body = world->CreateBody(&bd);
        
        b2EdgeChainDef chain;
        chain.isALoop = true; // connects the first and last vertices
        chain.vertexCount = 4;
        chain.vertices = vertices;
        body->CreateShape(&chain);
*/
        
        
         
         //Set up sprite
         
         CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
         [self addChild:batch z:0 tag:kTagBatchNode];
         
         [self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
         
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
		
        NSString *svgPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-mesh",levelName] ofType:@"svg"]; 
        
		const char *path = [svgPath UTF8String];
		navsceneLoad(&navScene, path);
		        
        
        CCLOG(@"nwalkable = %i", navScene.nwalkable);

        ///*
        int i;
        for(i = 0; i < navScene.nwalkable * 2 - 2; i+=2)
        {
            CCLOG(@"%f", navScene.walkable[i]);
            
            [self createEdge:navScene.walkable[i] y1:navScene.walkable[i+1] x2:navScene.walkable[i+2] y2:navScene.walkable[i+3]];
        }
        
         [self createEdge:navScene.walkable[0] y1:navScene.walkable[1] x2:navScene.walkable[navScene.nwalkable * 2 - 2] y2:navScene.walkable[navScene.nwalkable * 2 - 1]];
		//*/
        
        
        
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

        
       // [self createEdge:0 y1:300 x2:400 y2:200];
        
       // [self createEdge:400 y1:200 x2:700 y2:500];
        //[self createEdge:500 y1:700 x2:700 y2:500];

        [self scheduleUpdate];
	}
	return self;
}

-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2
{
    CCLOG(@"createEdge : (%f, %f), (%f, %f)", x1, y1, x2, y2);
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0/PTM_RATIO, 0/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    
    b2PolygonShape dynamicBox;
    //dynamicBox.Set(vertices, num);
    dynamicBox.SetAsEdge(b2Vec2(x1/PTM_RATIO, y1/PTM_RATIO), b2Vec2(x2/PTM_RATIO, y2/PTM_RATIO));
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
}

+(id)corridorWithName:(NSString *)levelName
{
	return [[[self alloc] initWithLevelName:levelName] autorelease];
	
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

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"dfqsf");
    UITouch *tch = [[touches allObjects] objectAtIndex:0];
	CGPoint tchLoc = [tch locationInView:tch.view];
	//tchLoc = [[CCDirector sharedDirector] convertToGL:tchLoc];
    fingerPos = [[CCDirector sharedDirector] convertToGL:tchLoc];
    //tchLoc = ccpMult(tchLoc, 1 / PTM_RATIO);
        
    
}

-(void)update:(ccTime) dt
{
    //CCLOG(@"%f, %f", fishImage.position.x, fishImage.position.y);

    
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
    
    
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
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
        location.x += 2000;
        location.y += 2000;
        //[self addNewSpriteWithCoords: location];
	}
}


-(void) addNewSpriteWithCoords:(CGPoint)p
{
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
}


- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
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
