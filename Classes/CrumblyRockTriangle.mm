//
//  CrumblyRockTriangle.m
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "CrumblyRockTriangle.h"
#import "globals.h"

@implementation CrumblyRockTriangle

@synthesize body;
@synthesize bodyDef;
@synthesize shapeDef;
@synthesize fixtureDef;
@synthesize points;
@synthesize texture;

- (void)dealloc
{
	delete bodyDef;
	delete shapeDef;
    delete fixtureDef;
    [texture release];
	[super dealloc];
}

+(id)crumblyRockTriangle:(float *)aPts
{
    return [[[CrumblyRockTriangle alloc] init:aPts] autorelease];
}

- (id)init:(float *)pts
{
	self = [super init];
    if(self)
    {
		[self setBodyDef:new b2BodyDef];
        [self bodyDef]->type = b2_staticBody;
		[self setShapeDef:new b2PolygonShape];
        b2Vec2 vertices[3];
        for(int i = 0; i< 3 * 2; i+=2)
        {
            //CCLOG(@"i = %d", j);
            // CCLOG(@"pt%d :(%f, %f)", j/2, pts[j], pts[j+1]);
            vertices[i/2].Set(SCREEN_TO_WORLD(pts[i]), SCREEN_TO_WORLD(pts[i+1]));
        }
        self.shapeDef->Set(vertices, 3);
        [self setFixtureDef:new b2FixtureDef];
		[self fixtureDef]->restitution = 0.1f;
        [self setTexture:[CrumblyRockTriangleTexture nodeWithPoints:pts]];
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
    [[self scene] addChild:self.texture];
}


- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[self world]->DestroyBody([self body]);
	[self setBody:nil];
    [[self scene] removeChild:texture cleanup:NO];
	[super actorWillDisappear];
}


- (void)worldDidStep 
{
	[super worldDidStep];
    //Dessiner le triangle
}

-(void)destroy
{
//    CCLOG(@"Destroy");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeActor" object:self];
}

@end
