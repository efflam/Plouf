//
//  Rock.m
//  ProtoMesh2
//
//  Created by Efflam on 16/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Rock.h"
#import "globals.h"

@implementation Rock

@synthesize body;
@synthesize bodyDef;
@synthesize shapeDef;
@synthesize fixtureDef;

#pragma mark Object Methods

- (void)dealloc
{
	delete bodyDef;
	delete shapeDef;
    delete fixtureDef;
	[self setBody:nil];
	[self setBodyDef:nil];
	[self setShapeDef:nil];
    [self setFixtureDef:nil];
	[self setRockSprite:nil];
	[super dealloc];
}

- (id)init
{
	self = [super init];
    if(self)
    {
		[self setBodyDef:new b2BodyDef];
        [self bodyDef]->type = b2_dynamicBody;
		[self setShapeDef:new b2CircleShape];
        [self setFixtureDef:new b2FixtureDef];
		[self fixtureDef]->density = 5.0f;
		[self fixtureDef]->restitution = 0.1f;
		[self setRadius:10.0f + rand()% 14 - 8.0f];
	}
	return self;
}


#pragma mark Event Methods

- (void)actorDidAppear 
{	
	[super actorDidAppear];
	[self bodyDef]->userData =  self;
	[self setBody:[self world]->CreateBody([self bodyDef])];
	[self fixtureDef]->shape = [self shapeDef];
	
    [self body]->CreateFixture([self fixtureDef]);
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [[self scene] getChildByTag:999];
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(30 * idx,30 * idy,30,30)];
    [batch addChild:sprite];
    [self setRockSprite:sprite];
    [[self rockSprite] setScaleX: [self radius]/[self rockSprite].contentSize.width * 2];
    [[self rockSprite] setScaleY: [self radius]/[self rockSprite].contentSize.height * 2];
	//[[self game] addChild:[self rockSprite]];
	
}


- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[self world]->DestroyBody([self body]);
	[self setBody:nil];
	[[self scene] removeChild:[self rockSprite] cleanup:NO];
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [[self scene] getChildByTag:999];
    [batch removeChild:[self rockSprite] cleanup:YES];
    [self setRockSprite:nil];
	[super actorWillDisappear];
}


- (void)worldDidStep 
{
	[super worldDidStep];
    //CCLOG(@"body ? %@", ([self body]));
//     CCLOG(@"world body ? %d", ([self body] == nil));
    
    [[self rockSprite] setPosition:ccp(WORLD_TO_SCREEN([self body]->GetPosition().x), WORLD_TO_SCREEN([self body]->GetPosition().y))];
    [[self rockSprite] setRotation: -1 * RADIANS_TO_DEGREES([self body]->GetAngle())];
	
}


#pragma mark Physics Accessors


#pragma mark Transform Accessors

- (CGPoint)position
{
	if([self body]) return ccp(WORLD_TO_SCREEN(body->GetPosition().x), WORLD_TO_SCREEN(body->GetPosition().y));
	else return ccp(WORLD_TO_SCREEN(bodyDef->position.x), WORLD_TO_SCREEN(bodyDef->position.y));
}

- (void)setPosition:(CGPoint)aPosition
{
    //CCLOG(@"body ? %@", ([self body]));
	//NSAssert(![self body], @"Cannot set position");
	[self bodyDef]->position.Set(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y));
    //[self body]->SetTransform(b2Vec2(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y)), [self body]->GetAngle());
    
}

- (CGFloat)radius
{
	return WORLD_TO_SCREEN([self shapeDef]->m_radius);
}

- (void)setRadius:(CGFloat)aRadius 
{
	NSAssert(![self body], @"Cannot set radius");
	[self shapeDef]->m_radius = SCREEN_TO_WORLD(aRadius);
}

- (CGFloat)rotation
{
	if([self body]) return RADIANS_TO_DEGREES([self body]->GetAngle());
	else return RADIANS_TO_DEGREES([self bodyDef]->angle);
}

- (void)setRotation:(CGFloat)aRotation
{
	NSAssert(![self body], @"Cannot set rotation");
	[self bodyDef]->angle = DEGREES_TO_RADIANS(aRotation);
}


#pragma mark View Accessors

@synthesize rockSprite;

@end
