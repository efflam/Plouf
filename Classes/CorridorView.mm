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
#import "Rock.h"
#import "RectSensor.h"
#import "MyContactListener.h"
#import "ClassContactOperation.h"
#import "RockFallSensor.h"
#import "CrumblyRockTriangle.h"
#import "Anemone.h"
#import "SimpleAudioEngine.h"
#import "Murene.h"
#import "Finish.h"

@implementation CorridorView

@synthesize moveToFinger;
@synthesize fingerPos;
@synthesize navScene; 
@synthesize actorSet;
@synthesize contactListener;
@synthesize world;
@synthesize murene;
@synthesize parcel;
@synthesize fall;

#define MAX_NAV_AGENTS 8

float camSpring = 0.02;

- (void) dealloc
{
    

	delete world;
	delete debugDraw;
    delete contactListener;
    
    world = NULL;
    
    [fall release];
    [actorSet release];
    [parcel release];
    [murene release];
	[super dealloc];
}

+(id)corridorWithName:(NSString *)levelName
{
	return [[[self alloc] initWithLevelName:levelName] autorelease];
}

-(void)onExit
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fall setDelegate:nil];
    [self removeAllActors];
}

-(id)initWithLevelName:(NSString *)levelName 
{
	if((self = [super init]))
	{
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        [[CCTextureCache sharedTextureCache] addImage:@"colis.png"];
        
        [self initPhysics];
        
        [self initMesh:levelName];
      
        [self initCorridor:navScene.edge count:navScene.nedge];
        
		//NavmeshAgent* agent = &navScene.agents[0];
        
        Fish *clown  = [Fish fishWithName:@"clown" andPosition:ccp( 465.0f, 3663.0f) andParcelOffset:ccp(0.0f, 50.0f)];
        Fish *labre  = [Fish fishWithName:@"labre" andPosition:ccp(2658.0f, 2603.0f) andParcelOffset:ccp(0.0f, 40.0f)];
        Fish *papillon  = [Fish fishWithName:@"papillon" andPosition:ccp(3634.0f, 2532.0f) andParcelOffset:ccp(0.0f, 58.0f)];
        Fish *coffre  = [Fish fishWithName:@"coffre" andPosition:ccp(2560.0f, 902.0f) andParcelOffset:ccp(0.0f, 45.0f)];
        Fish *crevette  = [Fish fishWithName:@"crevette" andPosition:ccp(2926.0f, 2812.0f) andParcelOffset:ccp(0.0f, 35.0f)];

        currentFish = clown;
        currentActor = clown;
        [currentFish setSelected:YES];
        fishes = [NSMutableArray arrayWithObjects:clown, labre, papillon, coffre, crevette, nil];
        
        RectSensor *mureneWashSensor = [RectSensor rectSensorFrom:ccp(1400, 2460) to:ccp(1470, 2420)];
        [self addActor:mureneWashSensor];
        
        RectSensor *mureneSensor = [RectSensor rectSensorFrom:ccp(1400, 2510) to:ccp(1550, 2400)];
        [self addActor:mureneSensor];

        
        for(uint i = 0 ; i < [fishes count];i++)
        {
            Fish *fish = (Fish*)[fishes objectAtIndex:i];
            
            [fish setDelegate:self];
            [self addActor:fish];
            
            if(fish != coffre)
            {
                ClassContactOperation *hitOp = [ClassContactOperation operationFor:[Rock class] WithTarget:fish andSelector:@selector(hit) when:1];
                [fish addClassOperation:hitOp];
            }
            if(fish != clown && fish != papillon)
            {
                ClassContactOperation *electOp = [ClassContactOperation operationFor:[Anemone class] WithTarget:fish andSelector:@selector(hit) when:1];
                [fish addClassOperation:electOp];
            }
            if(fish !=labre)
            {
                InstanceContactOperation *fishMureneAteOp = [InstanceContactOperation operationFor:fish WithTarget:self andSelector:@selector(mureneEat) when:1];
                [mureneSensor addInstanceOperation:fishMureneAteOp];

            }
        }
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
        [self addChild:batch z:0 tag:1];
        
        self.fall = [RockFall rockFallWithDelegate:self];
        [fall setEmissionPoint:ccp(1080, 1300)];
        
        RectSensor *fallSensor = [RockFallSensor rockFallSensorFor:fall from:ccp(200, 1300) to:ccp(1500, 660)];
        [self addActor:fallSensor];
        
        
        [self setContactListener: new MyContactListener()];
        world->SetContactListener([self contactListener]);
        
        self.murene = [Murene murene];
        [self addActor:self.murene];
        [self.murene setPosition:ccp(1100.0f, 2400.0f)];
        
       
        
        InstanceContactOperation *washMureneAteOp = [InstanceContactOperation operationFor:labre WithTarget:self.murene andSelector:@selector(wash) when:1];
        [mureneWashSensor addInstanceOperation:washMureneAteOp];
        
        InstanceContactOperation *unwashMureneAteOp = [InstanceContactOperation operationFor:labre WithTarget:self.murene andSelector:@selector(unwash) when:2];
        [mureneWashSensor addInstanceOperation:unwashMureneAteOp];
        
        
      
        
       
        
        CrumblyRockTriangle *rock;
        for(Actor *anActor in [NSSet setWithSet:[self actorSet]]) 
        {
            if([anActor isKindOfClass:[CrumblyRockTriangle class]])
            {
                rock = (CrumblyRockTriangle *)anActor;
                InstanceContactOperation *destroyOp = [InstanceContactOperation operationFor:crevette WithTarget:rock andSelector:@selector(destroy) when:1];
                [rock addInstanceOperation:destroyOp];

            }
            else if([anActor isKindOfClass:[Anemone class]])
            {
                Anemone *anem = (Anemone *)anActor;
                InstanceContactOperation *ateOp = [InstanceContactOperation operationFor:papillon WithTarget:anem andSelector:@selector(ate) when:1];
                [anem addInstanceOperation:ateOp];
            }
            
        }
        
        
      
        
        self.parcel = [Parcel parcelAtPosition:ccp(1120, 1960)];
        [self addActor:self.parcel];
        
        ClassContactOperation *pickParcelOp = [ClassContactOperation operationFor:[Fish class] WithTarget:self andSelector:@selector(pickParcel) when:1];
        
        
        RectSensor *finishSensor = [Finish finishFrom:ccp(0.0f, 850.0f) to:ccp(70.0f, 770.0f)];
        [self addActor:finishSensor];
        ClassContactOperation *shippedOp = [ClassContactOperation operationFor:[Fish class] WithTarget:self andSelector:@selector(fishOnFinish) when:1];
        [finishSensor addClassOperation:shippedOp];
        
        [self.parcel addClassOperation:pickParcelOp];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActorHandler:) name:@"removeActor" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bubbleTouch:) name:@"bubbleTouch" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(giveParcelHandler:) name:@"giveParcel" object:nil];

	}
	return self;
}

-(void)onEnter
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Ambiance.mp3" loop:YES];
    [super onEnter];
}


-(void)giveParcelHandler:(NSNotification*)notification
{
    Fish *fish = (Fish *)[notification object];
    
    //if(shippingFish) [self setShippingFish:currentFish];
    if(fish)[self setShippingFish:fish];
}

-(void)setShippingFish:(Fish *)fish
{
    if(fish == shippingFish) 
        return; 
    
    if(shippingFish)
        [shippingFish unship];
    
    shippingFish = fish;
    [shippingFish ship];
    
}

-(void)pickParcel
{
    if(shippingFish)return;
    [self removeActor:self.parcel];
    self.parcel = nil;
    [self setShippingFish:currentFish];        
}


-(void)fishOnFinish
{
    if(currentFish == shippingFish) [self win];
}


-(void)mureneEat
{
    if([[self murene] washing]) return;
    [self.murene eat];
    currentFish.spriteLinked = NO;
    
    [currentFish.sprite runAction:
                                    [CCSequence actions:[CCMoveTo actionWithDuration:0.5 position:ccp(1515, 2450)], 
                                     [CCCallFunc actionWithTarget:self selector:@selector(fishEatenByMurene)], 
                                     nil]
     ];
}

-(void)fishEatenByMurene
{ 
    [self removeFish:currentFish];
    currentFish = nil;
    NavmeshAgent* agent = &navScene.agents[navScene.nagents-1];
     if(!travelling && currentActor) vset(agent->pos, currentActor.position.x,currentActor.position.y);
    currentActor = nil;
}

-(void)removeFish:(Fish *)aFish
{
    if(aFish == shippingFish) 
    {
        [self removeActor:aFish];
        [self loose];
        //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0f],[CCCallFunc actionWithTarget:self selector:@selector(loose)], nil]];
        return;
    }
    [self removeActor:aFish];
}

-(void)loose
{
    CCLOG(@"LOOSER :(");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loose" object:self userInfo:nil];
}


-(void)win
{
    CCLOG(@"WINNER :)");
    currentFish.spriteLinked = NO;
    [[currentFish sprite] runAction:
        [CCSequence actions:
            [CCMoveBy actionWithDuration:0.7f position:ccp(-250.0f, 0.0f)],
            [CCDelayTime actionWithDuration:0.5],
            [CCCallFunc actionWithTarget:self selector:@selector(notifyWin)],
            nil
        ]
    ];
   }
     
-(void)notifyWin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"win" object:self userInfo:nil];

}

-(void)bubbleTouch:(NSNotification*)notification
{
    BubbleSprite* bubbleSprite = [notification object];
    Actor *target = (Actor*)[bubbleSprite target];
    if([target isKindOfClass:[Fish class]])
       [self setSelectedFish:(Fish*)[bubbleSprite target]];
    else
    {
        NavmeshAgent* agent = &navScene.agents[navScene.nagents-1];
        
        if(!travelling && currentActor) vset(agent->pos, currentActor.position.x,currentActor.position.y);
        
        float pos[2] = {target.position.x,target.position.y};
        float nearest[2] = {target.position.x,target.position.y};
        
        if (navScene.nav)
            navmeshFindNearestTri(navScene.nav, pos, nearest);
        
        vcpy(navScene.agents[navScene.nagents-1].target, nearest);
        vcpy(navScene.agents[navScene.nagents-1].oldpos, navScene.agents[navScene.nagents-1].pos);
        agentFindPath(&navScene.agents[navScene.nagents-1], navScene.nav);
        vset(navScene.agents[navScene.nagents-1].corner, FLT_MAX,FLT_MAX);
        
        travelling = YES;
        
        currentFish = nil;
        currentActor = target;
        camSpring = 0.02;

    }
}

-(void)removeActorHandler:(NSNotification*)notification
{
    Actor* actor = [notification object];
    [self removeActor:actor];
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
    SVGPath* walkablePath = 0;
    SVGPath* edgePath = 0;
	SVGPath* boundaryPath = 0;
	SVGPath* agentPaths[MAX_NAV_AGENTS];
    SVGPath* rockPaths[50];
    SVGPath* anemonePaths[50];
    int nrockPaths = 0;
	int nagentPaths = 0;
	int nanemonePaths = 0;
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
        else if (it->strokeColor == 0xff9E55C9)
		{
			rockPaths[nrockPaths++] = it;
		}
        else if (it->strokeColor == 0xffFF7FDB && !it->closed)
		{
			anemonePaths[nanemonePaths++] = it;
		}


		for (int i = 0; i < it->npts; ++i)
		{
			const float* p = &it->pts[i*2];
			bmin[0] = min(bmin[0], p[0]);
			bmin[1] = min(bmin[1], p[1]);
			bmax[0] = max(bmax[0], p[0]);
			bmax[1] = max(bmax[1], p[1]);
		}
	}
	
	
	if (!boundaryPath) printf("navsceneLoad: No boundary!\n");
	if (!walkablePath) printf("navsceneLoad: No walkable!\n");
	if (!nagentPaths) printf("navsceneLoad: No agents!\n");
    if (!edgePath)printf("navsceneLoad: No edge!\n");

	const float s = 1;
    
    for(int i = 0; i < nrockPaths; i++)
    {
        float *pts = new float [rockPaths[i]->npts * 2];
        storePath(pts, rockPaths[i]->pts, rockPaths[i]->npts, 1, bmin, bmax);
        CrumblyRockTriangle *tri = [CrumblyRockTriangle crumblyRockTriangle:pts];
        [self addActor:tri];
    }
    
    for(int i = 0; i < nanemonePaths; i++)
    {
        
        const float* pa = &anemonePaths[i]->pts[0];
		const float* pb = &anemonePaths[i]->pts[(anemonePaths[i]->npts-1)*2];
        
        float p1[2];
        float p2[2];
        convertPoint(p1, pa, s, bmin, bmax);
		convertPoint(p2, pb, s, bmin, bmax);

        float a = p1[0] - p2[0];
        float b = p1[1] - p2[1];
        float ang = atan2f(b, a) + M_PI * 0.5;
        
        Anemone *anem = [Anemone anemoneAtPosition:ccp(p1[0], p1[1]) andRotation:ang];
        
        [self addActor:anem];
    }

    
    
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
        
//        NSLog(@"HEYYYYY : %f : %f",agentPaths[i]->pts[0],agentPaths[i]->pts[(agentPaths[i]->npts-1)*2]);
		
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
    b2Vec2 gravity = b2Vec2(0.0f, -2.0f);
    bool doSleep = true;
    world = new b2World(gravity, doSleep);    
    world->SetContinuousPhysics(true);
    debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(debugDraw) ;
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    debugDraw->SetFlags(flags);	
    
    [self setActorSet:[[[NSMutableSet alloc] init] autorelease]];
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
    previousCamPos = [Camera standardCamera].position;
    
    moveToFinger = true;
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

-(void)setSelectedFish:(Fish *)fish
{
    if(fish == currentFish) 
    {
        NSLog(@"currentFish bitch !");
        return; 
    }
    
   
    if(currentFish) currentFish.selected = NO;
    
    NavmeshAgent* agent = &navScene.agents[navScene.nagents-1];
    
    if(!travelling && currentFish) vset(agent->pos, currentFish.sprite.position.x,currentFish.sprite.position.y);
    
    float pos[2] = {fish.sprite.position.x,fish.sprite.position.y};
    float nearest[2] = {fish.sprite.position.x,fish.sprite.position.y};
    
    NSLog(@"Départ agent    : %f : %f",agent->pos[0],agent->pos[1]);
    if(currentFish) NSLog(@"Départ poisson  : %f : %f",currentFish.sprite.position.x,currentFish.sprite.position.y);
    NSLog(@"Arrivée poisson : %f : %f",fish.sprite.position.x,fish.sprite.position.y);
    
    if (navScene.nav)
        navmeshFindNearestTri(navScene.nav, pos, nearest);
	
    vcpy(navScene.agents[navScene.nagents-1].target, nearest);
    vcpy(navScene.agents[navScene.nagents-1].oldpos, navScene.agents[navScene.nagents-1].pos);
    agentFindPath(&navScene.agents[navScene.nagents-1], navScene.nav);
    vset(navScene.agents[navScene.nagents-1].corner, FLT_MAX,FLT_MAX);
    
    travelling = YES;
    
    currentFish = fish;
    currentActor = fish;
    currentFish.selected = YES;
    
    camSpring = 0.02;
}


    
-(void)update:(ccTime)dt
{
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    world->Step(dt, velocityIterations, positionIterations);
    
    for(Actor *anActor in [NSSet setWithSet:[self actorSet]]) 
    {
        if(anActor.destroyable)
        {
//            [anActor retain];
            [anActor actorWillDisappear];
            [anActor setScene:nil];
            [anActor setWorld:nil];
            [[self actorSet] removeObject:anActor];
//            [anActor release];
        }
        else
        {
            [anActor worldDidStep];
        }
               
    }

    
    if(!travelling)
    {
        
        if(moveToFinger)
        {
            fingerPos = ccpSub(fingerPos, ccpSub([[Camera standardCamera] position],previousCamPos));
            [currentFish swimTo:fingerPos];
            
            previousCamPos = [[Camera standardCamera] position];
        }
        
        if(currentActor)
        {
            CGPoint fishpoint = [self convertToScreenCenter:currentActor.position];
            
            [[Camera standardCamera] setPosition:fishpoint];
        }
        
        
        return;
    }
    	
	const float maxSpeed = 1500.0f;
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
//	last = agentFindNextCornerSmooth(agent, dir, navScene.nav, corner);
	last = agentFindNextCorner(agent, navScene.nav, corner);
        
    float distFromCam = ccpDistance([[Camera standardCamera] position], [[Camera standardCamera] checkBoundsForPoint:[self convertToScreenCenter:currentActor.position] withScale:1]);
    
    //NSLog(@"distFromCam : %f",distFromCam);
        
	if (last && vdist(agent->pos, corner) < 2.0f)
	{
		// Reached goal
		vcpy(agent->oldpos, agent->pos);
		vset(agent->dvel, 0,0);
		vcpy(agent->vel, agent->dvel);
        //travelling = NO;
        if(distFromCam > 1.0f)
        {
            camSpring *= 1.05;
            [[Camera standardCamera] springTo: [self convertToScreenCenter:currentActor.position] withSpring:camSpring]; 
        } 
        else
        {
            travelling = NO;
            [[Camera standardCamera] setPosition:[self convertToScreenCenter:currentActor.position]];
        }
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
        CGPoint camPoint = [self convertToScreenCenter:ccp(agent->pos[0],agent->pos[1])];
        [[Camera standardCamera] springTo: camPoint withSpring:0.02];            
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

-(void)draw
{
    
    //[self drawNavMesh];
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    //world->DrawDebugData();
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	[super draw];
}



#pragma mark Actor Methods

- (void)addActor:(Actor *)anActor 
{
	if(anActor && ![[self actorSet] containsObject:anActor]) 
    {
		[anActor setScene:self];
		[anActor setWorld:self.world];
		[[self actorSet] addObject:anActor];
		[anActor actorDidAppear];
	}
}


- (void)removeActor:(Actor *)anActor 
{
	if(anActor && [[self actorSet] containsObject:anActor])
    {
        anActor.destroyable = YES;
    }
}

- (void)removeAllActors 
{
	for(Actor *anActor in [NSSet setWithSet:[self actorSet]]) 
    {
        [anActor retain];
        [anActor actorWillDisappear];
        [[self actorSet] removeObject:anActor];
        [anActor setScene:nil];
        [anActor setWorld:nil];
        [anActor release];
	}
}


-(CGPoint)convertVertToCGPoint:(float*)v;
{
	return ccp(v[0], v[1]);
}

-(CGPoint)convertToScreenCenter:(CGPoint)point
{
    return ccpAdd(ccpMult(ccpSub(point, ccp(2000, 2000)), -1), SCREEN_CENTER);
}

@end
