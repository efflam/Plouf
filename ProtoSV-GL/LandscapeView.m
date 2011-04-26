//
//  LandscapeView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 18/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LandscapeView.h"


@implementation LandscapeView

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        [self setAnchorPoint:ccp(0,0)];
        
        CCSprite *level1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-1.png",levelName]];
        CCSprite *level2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-2.png",levelName]];
        CCSprite *level3 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-3.png",levelName]];
        CCSprite *level4 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-4.png",levelName]];
        
        [level1 setAnchorPoint:ccp(0,0)];
        [level2 setAnchorPoint:ccp(0,0)];
        [level3 setAnchorPoint:ccp(0,0)];
        [level4 setAnchorPoint:ccp(0,0)];
        
        [level1 setPosition:ccp(0,MAP_WIDTH/2)];
        [level2 setPosition:ccp(MAP_WIDTH/2,MAP_HEIGHT/2)];
        [level3 setPosition:ccp(MAP_WIDTH/2,0)];
        [level4 setPosition:ccp(0,0)];
        
        [self addChild:level1];
        [self addChild:level2];
        [self addChild:level3];
        [self addChild:level4];
    }
    
    return self;
}

+(id)landscapeWithName:(NSString*)levelName
{
    return [[[LandscapeView alloc] initWithLevelName:levelName] autorelease];
}

@end
