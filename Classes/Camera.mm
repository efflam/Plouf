//
//  Camera.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 11/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Camera.h"

@implementation Camera

@synthesize delegate, currentPosition, rawPosition;

static Camera* _standardCamera = nil;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        mapSize    = CGSizeMake(MAP_WIDTH, MAP_HEIGHT);
		winSize    = [[CCDirector sharedDirector] winSize];
        self.scale = 1;
        self.position = ccp(0,0);
    }
    
    return self;
}

+(Camera *)standardCamera
{
    if (!_standardCamera)
        _standardCamera = [[self alloc] init];
    
    return _standardCamera;
}

-(void)setPosition:(CGPoint)position
{          
    self.rawPosition = position;
    position = [self checkBoundsForPoint:position withScale:self.scale];
    [self.delegate setPosition:position];
    self.currentPosition = position;
}


-(void)springTo:(CGPoint)position withSpring:(float)spring
{
    CGPoint newPos = ccpAdd([self position], ccpMult(ccpSub(position, [self position]), spring));
    newPos = [self checkBoundsForPoint:newPos withScale:self.scale];
    [self.delegate setPosition:newPos];
    self.currentPosition = newPos;
}

-(void)update:(ccTime) dt
{
    
}

-(CGPoint)position
{
    return currentPosition;
}

-(CGPoint)checkBoundsForPoint:(CGPoint)point withScale:(float)newScale
{	
	float w = mapSize.width  * 0.5 * newScale;
	float h = mapSize.height * 0.5 * newScale;
	
	CGPoint bl = ccp(w, h);
	CGPoint tr = ccp(winSize.width - w, winSize.height - h);
	
	point.x = fmaxf(fminf(point.x, bl.x), tr.x);
	point.y = fmaxf(fminf(point.y, bl.y), tr.y);
	
	return point;
}

-(void)dealloc
{
    [delegate release];
    [super dealloc];
}

@end
