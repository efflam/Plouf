//
//  Rock.m
//  ProtoMesh2
//
//  Created by Efflam on 16/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Rock.h"


@implementation Rock

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
		[self fixtureDef]->density = 2.0f;
		[self fixtureDef]->restitution = 0.75f;
		[self setRadius:15.0f];
		//[self setRockSprite:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ball.png"]] autorelease]];
	}
	return self;
}


#pragma mark Event Methods

- (void)actorDidAppear 
{	
	[super actorDidAppear];
	
	[self setBody:[[self game] world]->CreateBody([self bodyDef])];
	[self fixtureDef]->shape = [self shapeDef];
	[self bodyDef]->userData = (void *)self;
    [self body]->CreateFixture([self fixtureDef]);
	
	//[[self game] addChild:[self rockSprite]];
	
}

- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[[self game] world]->DestroyBody([self body]);
	[self setBody:nil];
	[[self game] removeChild:[self rockSprite] cleanup:NO];
	[super actorWillDisappear];
}

- (void)worldDidStep 
{
	[super worldDidStep];
	
}


#pragma mark Physics Accessors

@synthesize body;

@synthesize bodyDef;

@synthesize shapeDef;

@synthesize fixtureDef;


#pragma mark Transform Accessors

- (CGPoint)position
{
	if([self body]) return ccp(WORLD_TO_SCREEN(body->GetPosition().x), WORLD_TO_SCREEN(body->GetPosition().y));
	else return ccp(WORLD_TO_SCREEN(bodyDef->position.x), WORLD_TO_SCREEN(bodyDef->position.y));
}

- (void)setPosition:(CGPoint)aPosition
{
	NSAssert(![self body], @"Cannot set position");
	[self bodyDef]->position.Set(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y));
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
