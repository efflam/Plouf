//
//  LevelView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 19/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LevelView.h"
#import "ScrollLevelView.h"

@implementation LevelView

-(id)initWithLevelName:(NSString *)levelName
{
    self = [super init];
    
    if(self)
    {
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-background.png",levelName]];
        [background setAnchorPoint:ccp(0,0)];
        [self addChild:background];
        [self addChild:[ScrollLevelView levelWithName:levelName]];
    }
    
    return self;
}

+(id)levelWithName:(NSString *)levelName
{
    return [[[LevelView alloc] initWithLevelName:levelName] autorelease];
}

@end
