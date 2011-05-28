//
//  GameLayer.m
//  Proto4
//
//  Created by Clément RUCHETON on 01/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "ScrollLevelView.h"


@implementation ScrollLevelView
@synthesize corridor,landscape,rocks;

+(id)levelWithName:(NSString *)levelName
{
    return [[[ScrollLevelView alloc] initWithLevelName:levelName] autorelease];
}

-(void)dealloc
{
    [rocks release];
    [landscape release];
    [corridor release];
    [super dealloc];
}

-(id) initWithLevelName:(NSString *)levelName
{
	if((self=[super init])) 
	{        
        [[Camera standardCamera] setDelegate:self];
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
		
        [self setAnchorPoint:ccp(0,0)];
        
        self.rocks       = [BackrockView backrockWithName:levelName];
        self.landscape   = [LandscapeView landscapeWithName:levelName];
        self.corridor    = [CorridorView corridorWithName:levelName];
                        
		[self addChild:rocks        z:-2    parallaxRatio:ccp(.7,.7)    positionOffset:ccp(0,0)];
        [self addChild:corridor     z:-1    parallaxRatio:ccp(1,1)      positionOffset:ccp(-MAP_WIDTH/2,-MAP_HEIGHT/2)];
		[self addChild:landscape    z:0     parallaxRatio:ccp(1,1)      positionOffset:ccp(-MAP_WIDTH/2,-MAP_HEIGHT/2)];
        
        [[Camera standardCamera] setPosition:self.position];
        
	}
	return self;
}

-(void)update:(ccTime)dt
{
    [corridor update:dt];
    [landscape update:dt];
}

@end
