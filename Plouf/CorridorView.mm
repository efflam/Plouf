//
//  CorridorView.m
//  ProtoSV-GL
//
//  Created by Efflam on 26/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "CorridorView.h"


#define PTM_RATIO 32

@implementation CorridorView

@synthesize moveToFinger;
@synthesize fingerPos;

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        //self.isTouchEnabled = true;
		
        // enable touches
        // self.isTouchEnabled = YES;
        
        // enable accelerometer
        //self.isAccelerometerEnabled = YES;
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        


        /*
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
        [self addChild:batch z:0 tag:kTagBatchNode];
        
        [self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
        
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
		
		const char *path = [filename UTF8String];
		navsceneLoad(&navScene, path);
        
        
        CCLOG(@"nwalkable = %i", navScene.nwalkable);
        
        int i;
        for(i = 0; i < navScene.nwalkable * 2 - 2; i+=2)
        {
            CCLOG(@"%f", navScene.walkable[i]);
            
            [self createEdge:navScene.walkable[i] y1:navScene.walkable[i+1] x2:navScene.walkable[i+2] y2:navScene.walkable[i+3]];
        }
        
        [self createEdge:navScene.walkable[0] y1:navScene.walkable[1] x2:navScene.walkable[navScene.nwalkable * 2 - 2] y2:navScene.walkable[navScene.nwalkable * 2 - 1]];
        
        
        
		CCSprite *fishSprite = [CCSprite spriteWithFile:@"fish.png"];
		[self addChild:fishSprite];
		
		NavmeshAgent* agent = &navScene.agents[0];
		[fishSprite setPosition:ccp(agent->pos[0], agent->pos[1])];
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.angularDamping = 10.0f;
        bodyDef.linearDamping = 1.0f;
        bodyDef.position.Set(agent->pos[0]/PTM_RATIO,  agent->pos[1]/PTM_RATIO);
        bodyDef.userData = fishSprite;
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
        */

    }
    
    return self;
}

+(id)corridorWithName:(NSString*)levelName
{
    return [[[CorridorView alloc] initWithLevelName:levelName] autorelease];
}

-(void)initPhysics
{
    /*
    b2Vec2 gravity = b2Vec2(0.0f, -5.0f);
    bool doSleep = true;
    
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
    */
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
    
}

-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2
{
    
}

-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity
{
    
}


@end
