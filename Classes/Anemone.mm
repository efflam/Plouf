//
//  Anemone.m
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Anemone.h"
#import "globals.h"

@implementation Anemone

@synthesize body;
@synthesize bodyDef;
@synthesize shapeDef;
@synthesize fixtureDef;
@synthesize sprite;
@synthesize eaten;


+(id)anemoneAtPosition:(CGPoint)aPosition andRotation:(float)aRotation
{
    return [[[Anemone alloc] initAtPosition:aPosition andRotation:aRotation] autorelease];
}

- (id)initAtPosition:(CGPoint)aPosition andRotation:(float)aRotation
{
	self = [super init];
    if(self)
    {
		[self setBodyDef:new b2BodyDef];
        [self bodyDef]->type = b2_staticBody;
		[self setShapeDef:new b2PolygonShape];
        float offsetX =  sinf(aRotation-M_PI) * 90.0f;
        float offsetY =  - cosf(aRotation-M_PI) * 90.0f;
        self.bodyDef->position.Set(SCREEN_TO_WORLD(aPosition.x +offsetX) , SCREEN_TO_WORLD(aPosition.y + offsetY));
        self.bodyDef->angle = aRotation;
        self.shapeDef->SetAsBox(SCREEN_TO_WORLD(20.0f), SCREEN_TO_WORLD(90.0f));
        [self setFixtureDef:new b2FixtureDef];
        eaten = NO;
	}
	return self;
}


- (void)actorDidAppear 
{	
	[super actorDidAppear];
	[self bodyDef]->userData =  self;
	[self setBody:[self world]->CreateBody([self bodyDef])];
	[self fixtureDef]->shape = [self shapeDef];
    [self body]->CreateFixture([self fixtureDef]);
    self.sprite = [AnemoneAnimated node];
    [self.sprite setPosition:ccp(WORLD_TO_SCREEN(self.body->GetPosition().x),WORLD_TO_SCREEN(self.body->GetPosition().y ))];
    float angleInDeg = -1 * CC_RADIANS_TO_DEGREES(self.body->GetAngle());
    [[self sprite] setRotation: angleInDeg];
	[[self scene] addChild:[self sprite]];
	
}


- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[self world]->DestroyBody([self body]);
	[self setBody:nil];
	[[self scene] removeChild:[self sprite] cleanup:NO];
    [self setSprite:nil];
	[super actorWillDisappear];
}

-(void)ate
{
    [self.sprite ate];
    eaten = YES;
}


- (void)worldDidStep 
{
	[super worldDidStep];
    if(eaten && self.body)
    {
        self.world->DestroyBody(self.body);
        self.body = nil;
    }
        
    
   
}
/*

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
 
 */
@end
