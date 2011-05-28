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
@synthesize menu;

-(void)dealloc
{
    [menu release];
}

-(id)initWithLevelName:(NSString *)levelName
{
    self = [super init];
    
    if(self)
    {
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        [frames addSpriteFramesWithFile:@"backgroundGame.plist" 
                                texture:[[CCTextureCache sharedTextureCache] addImage:@"backgroundGame.png"]];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"backgroundGame.png"]];
        [background setAnchorPoint:ccp(0,0)];
        
        CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"pauseButton.png"]];
        CCMenuItemImage *pauseButton = [CCMenuItemImage itemFromNormalSprite:pauseSprite 
                                                              selectedSprite:nil 
                                                                      target:self 
                                                                    selector:@selector(pauseGame)];
        
        self.menu = [CCMenu menuWithItems:pauseButton, nil];
        
        [self addChild:background];
        [self addChild:[ScrollLevelView levelWithName:levelName]];
        [self addChild:[BubbleView node]];
        [self addChild:menu];
    }
    
    return self;
}

-(void)pauseGame
{
    [menu setIsTouchEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
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
