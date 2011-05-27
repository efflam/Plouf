//
//  LevelView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 19/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LevelView.h"
#import "ScrollLevelView.h"
#import "BackgroundView.h"

@implementation LevelView

-(id)initWithLevelName:(NSString *)levelName
{
    self = [super init];
    
    if(self)
    {
        BackgroundView *background = [BackgroundView backgroundWithName:levelName];
        [self addChild:background];
        [self addChild:[ScrollLevelView levelWithName:levelName]];
        [self addChild:[BubbleView node]];
        
        
    }
    
    return self;
}

-(void)onEnterTransitionDidFinish
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    NSLog(@"removed textures!");
}

+(id)levelWithName:(NSString *)levelName
{
    return [[[LevelView alloc] initWithLevelName:levelName] autorelease];
}

@end
