//
//  Parcel.m
//  ProtoMesh2
//
//  Created by Efflam on 29/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Parcel.h"
#import "globals.h"

@implementation Parcel

@synthesize body;
@synthesize bodyDef;
@synthesize shapeDef;
@synthesize fixtureDef;
@synthesize sprite;

-(void)dealloc
{
    delete bodyDef;
    delete shapeDef;
    delete fixtureDef;
    
    [sprite release];
    
    [super dealloc];
}

+(id)parcelAtPosition:(CGPoint)aPosition
{
    return [[[Parcel alloc] initAtPosition:aPosition] autorelease];
}

- (id)initAtPosition:(CGPoint)aPosition
{
	self = [super init];
    if(self)
    {
		[self setBodyDef:new b2BodyDef];
        [self bodyDef]->type = b2_dynamicBody;
		[self setShapeDef:new b2CircleShape];
        self.shapeDef->m_radius = SCREEN_TO_WORLD(30.0f);
        self.bodyDef->position.Set(SCREEN_TO_WORLD(aPosition.x) , SCREEN_TO_WORLD(aPosition.y));
        [self setFixtureDef:new b2FixtureDef];
        [self fixtureDef]->density = 5.0f;
		[self fixtureDef]->restitution = 0.1f;
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
    self.sprite = [CCSprite spriteWithFile:@"colis.png"];
    [self.sprite setPosition:ccp(WORLD_TO_SCREEN(self.body->GetPosition().x),WORLD_TO_SCREEN(self.body->GetPosition().y ))];
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



- (void)worldDidStep 
{
	[super worldDidStep];
    [[self sprite] setPosition:ccp(WORLD_TO_SCREEN([self body]->GetPosition().x), WORLD_TO_SCREEN([self body]->GetPosition().y))];
    [[self sprite] setRotation: -1 * RADIANS_TO_DEGREES([self body]->GetAngle())];

    
}

 - (CGPoint)position
 {
 if([self body]) return ccp(WORLD_TO_SCREEN(body->GetPosition().x), WORLD_TO_SCREEN(body->GetPosition().y));
 else return ccp(WORLD_TO_SCREEN(bodyDef->position.x), WORLD_TO_SCREEN(bodyDef->position.y));
 }
 
 - (void)setPosition:(CGPoint)aPosition
 {
     [self bodyDef]->position.Set(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y));
 }


@end
