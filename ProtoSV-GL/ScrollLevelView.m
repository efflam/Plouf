//
//  GameLayer.m
//  Proto4
//
//  Created by Clément RUCHETON on 01/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "ScrollLevelView.h"
//#import "SVGNode.h"
#import "BackrockView.h"
#import "LandscapeView.h"

@implementation ScrollLevelView

@synthesize mapSize, winSize, scaleMin, isScrolling, isScaling;

-(id) initWithLevelName:(NSString *)levelName
{
	if((self=[super init])) 
	{
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
		
        [self setAnchorPoint:ccp(0,0)];
        
        BackrockView *rocks = [BackrockView backrockWithName:levelName];
        LandscapeView *landscape = [LandscapeView landscapeWithName:levelName];
        
		[self addChild:rocks        z:0     parallaxRatio:ccp(.7,.7)  positionOffset:ccp(0,0)];
		[self addChild:landscape    z:0     parallaxRatio:ccp(1,1)  positionOffset:ccp(-2048,-2048)];
		
		mapSize    = CGSizeMake(4096, 4096);
		winSize    = [[CCDirector sharedDirector] winSize];
		scaleMin   = fmaxf(winSize.width/mapSize.width,winSize.height/mapSize.height);
	}
	return self;
}

+(id)levelWithName:(NSString *)levelName
{
    return [[[ScrollLevelView alloc] initWithLevelName:levelName] autorelease];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self unschedule:@selector(applyIntertia)];
	[self unschedule:@selector(applyScaleInertia)];
	
	UITouch *touch = [touches anyObject];
	
//	[mapSVG setShowTess:![mapSVG showTess]];
	
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchOffset = [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    switch([[event allTouches] count]) 
	{
		case 1 : [self handleScroll:touches]; break;
		case 2 : [self handlePinch:touches withEvent:event]; break;
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if ([self isScrolling]) 
	{
		[self setIsScrolling:NO];
		[self schedule:@selector(applyIntertia) interval:0.01f];
	} else if([self isScaling]) 
	{
		[self setIsScaling:NO];
		[self schedule:@selector(applyScaleInertia) interval:0.01f];
	}
}

-(void)applyScaleInertia
{
	delta = delta * 0.95;
	
	float newScale = self.scale + delta * 0.0009;
	newScale = fmaxf(scaleMin, fminf(1.0f, newScale));
	
	if(newScale >= 1.0f || newScale <= scaleMin) 
	{
		[self unschedule:@selector(applyScaleInertia)];
	}
	
	CGPoint point = self.position;
	point = [self checkBoundsForPoint:point withScale:newScale];
	
	[self setScale:newScale];
	[self setPosition:point];
	
	if(fabsf(delta) < 1 || [self isScaling]) 
	{
		[self unschedule:@selector(applyScaleInertia)];
	}
}

-(void)applyIntertia
{
	inertiaVector = ccpMult(inertiaVector, 0.90);
	
	CGPoint newpos = ccpAdd(self.position, inertiaVector);
	
	newpos = [self checkBoundsForPoint:newpos withScale:self.scale];
	[self setPosition:newpos];
	
	if(ccpLength(inertiaVector) < 1 || [self isScrolling]) 
	{
		[self unschedule:@selector(applyIntertia)];
	}
}

-(void)handlePinch:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self setIsScrolling:NO];
	[self setIsScaling:YES];
	
	UITouch *one = [[[event allTouches] allObjects] objectAtIndex:0];
	UITouch *two = [[[event allTouches] allObjects] objectAtIndex:1];
	
	CGPoint ptOne = [one locationInView:[one view]];
	CGPoint ptTwo = [two locationInView:[two view]];
	
	CGPoint ptPrevOne = [one previousLocationInView:[one view]];
	CGPoint ptPrevTwo = [two previousLocationInView:[two view]];
	
	ptOne = [[CCDirector sharedDirector] convertToGL:ptOne];
	ptTwo = [[CCDirector sharedDirector] convertToGL:ptTwo];
	
	ptPrevOne = [[CCDirector sharedDirector] convertToGL:ptPrevOne];
	ptPrevTwo = [[CCDirector sharedDirector] convertToGL:ptPrevTwo];
		
	float dist = ccpDistance(ptOne, ptTwo);
	float prevDist = ccpDistance(ptPrevOne, ptPrevTwo);
	
	BOOL zoomIn = dist > prevDist;
	
	delta = fabsf(prevDist - dist);
	delta *= (zoomIn ? 1 : -1);
		
	float newScale = self.scale + delta * 0.0009;
	newScale = fmaxf(scaleMin, fminf(1.0f, newScale));
	
	CGPoint point = self.position;
	point = [self checkBoundsForPoint:point withScale:newScale];
	
	[self setScale:newScale];
	[self setPosition:point];
}


-(void)handleScroll:(NSSet *)touches 
{
	[self setIsScaling:NO];
	[self setIsScrolling:YES];
	
	UITouch *touch = [touches anyObject];
	
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	inertiaVector = ccpSub(touchLocation,prevLocation);
		
	CGPoint newpos = ccpAdd(self.position,inertiaVector);
	
	newpos = [self checkBoundsForPoint:newpos withScale:self.scale];
	[self setPosition:newpos];
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

@end
