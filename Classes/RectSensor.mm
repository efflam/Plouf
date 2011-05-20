//
//  RectSensor.m
//  ProtoMesh2
//
//  Created by Efflam on 16/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "RectSensor.h"


@implementation RectSensor

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
	[super dealloc];
}

- (id)initFrom:(CGPoint)a to:(CGPoint)b
{
	self = [super init];
    if(self)
    {
        float width = fabsf(b.x -a.x);
        float height = fabsf(a.y - b.y);
        
		[self setBodyDef:new b2BodyDef];
        [self bodyDef]->type = b2_staticBody;
        [self bodyDef]->userData = self;
		[self setShapeDef:new b2PolygonShape];
        [self setFixtureDef:new b2FixtureDef];
        [self fixtureDef]->isSensor = YES;
        [self shapeDef]->SetAsBox(SCREEN_TO_WORLD(width), SCREEN_TO_WORLD(height));
        [self bodyDef]->position.Set(SCREEN_TO_WORLD( a.x + width ), SCREEN_TO_WORLD(a.y-height));
	}
	return self;
}

+(id)rectSensorFrom:(CGPoint)a to:(CGPoint)b
{
    return [[[RectSensor alloc] initFrom:a to:b] autorelease];
}

#pragma mark Event Methods

- (void)actorDidAppear 
{	
	[super actorDidAppear];
	
	[self setBody:[self world]->CreateBody([self bodyDef])];
	[self fixtureDef]->shape = [self shapeDef];
    [self body]->CreateFixture([self fixtureDef]);
}

- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[self world]->DestroyBody([self body]);
	[self setBody:nil];
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
    //NSAssert(![self body], @"Cannot set position");
	[self bodyDef]->position.Set(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y));
    
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





@end
