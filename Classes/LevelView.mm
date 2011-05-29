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
@synthesize menu,pause,scrollView;

-(void)dealloc
{
    [[Camera standardCamera] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unscheduleUpdate];
    
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:scrollView];
    [scrollView release];
    
    
    [menu release];
    [pause release];
    [super dealloc];
}

-(id)initWithLevelName:(NSString *)levelName
{
    self = [super init];
    
    if(self)
    {
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        [frames addSpriteFramesWithFile:@"backgroundGame.plist" 
                                texture:[[CCTextureCache sharedTextureCache] addImage:@"backgroundGame.png"]];
        
        self.pause = [PauseMenu node];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"backgroundGame.png"]];
        [background setAnchorPoint:ccp(0,0)];
        
        CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"pauseButton.png"]];
        CCMenuItemImage *pauseButton = [CCMenuItemImage itemFromNormalSprite:pauseSprite 
                                                              selectedSprite:nil 
                                                                      target:self 
                                                                    selector:@selector(pauseGame)];
        
        [pauseButton setPosition:ccp(-450,320)];
        
        self.menu = [CCMenu menuWithItems:pauseButton, nil];
        
        self.scrollView = [ScrollLevelView levelWithName:levelName];
        
        [self addChild:background];
        [self addChild:scrollView];
        [self addChild:[BubbleView node]];
        [self addChild:menu];
        [self addChild:pause];
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    [self.scrollView update:dt];
}

-(void)pauseGame
{
    [self unscheduleUpdate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseLevel" object:nil];
    
    [pause setVisible:YES];
    [pause pause:YES];
    [menu setIsTouchEnabled:NO];
    
    [menu runAction:[CCFadeOut actionWithDuration:.5]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(levelMenuHandler) 
                                                 name:@"levelButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(continueHandler) 
                                                 name:@"continueButtonTouched" 
                                               object:nil];
}

-(void)continueHandler
{
    [self scheduleUpdate];
    
    [menu setIsTouchEnabled:YES];
    [menu runAction:[CCFadeIn actionWithDuration:.5]];
    [pause pause:NO];
    
    [self removePauseHandlers];
}

-(void)levelMenuHandler
{
    [self unscheduleUpdate];
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[LevelMenu node]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
}

-(void)restartHandler
{
    [self unscheduleUpdate];
    
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
        
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)removePauseHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)onEnterTransitionDidFinish
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [pause setOpacity:0];
    [super onEnterTransitionDidFinish];
}

+(id)levelWithName:(NSString *)levelName
{
    return [[[LevelView alloc] initWithLevelName:levelName] autorelease];
}

@end
