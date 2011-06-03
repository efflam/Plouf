//
//  PauseMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 28/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "PauseMenu.h"
#import "SimpleAudioEngine.h"

@implementation PauseMenu
@synthesize soundButton,menu,soundOn,background;

-(void)dealloc
{
    [background release];
    [soundButton release];
    [menu release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        [self setAnchorPoint:ccp(0,0)];
        [self setVisible:NO];
        
        self.soundOn = YES;
        
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
                
        self.background = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"backgroundGame.png"]];
        [background setAnchorPoint:ccp(0,0)];
        [background setOpacity:0];
        
        CCSprite *niveau        = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"levelButton.png"]];
        CCSprite *recommencer   = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"restartButton.png"]];
        CCSprite *son           = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"soundOnButton.png"]];
        CCSprite *continuer     = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"continueButton.png"]];
        
        CCMenuItemImage *levelButton = [CCMenuItemImage itemFromNormalSprite:niveau 
                                                              selectedSprite:nil 
                                                                     target:self 
                                                                   selector:@selector(levelButtonHandler)];
        
        CCMenuItemImage *restartButton = [CCMenuItemImage itemFromNormalSprite:recommencer 
                                                              selectedSprite:nil 
                                                                     target:self 
                                                                   selector:@selector(restartHandler)];
        
        self.soundButton = [CCMenuItemImage itemFromNormalSprite:son 
                                                  selectedSprite:nil 
                                                          target:self 
                                                        selector:@selector(soundHandler)];
        
        CCMenuItemImage *continueButton = [CCMenuItemImage itemFromNormalSprite:continuer 
                                                              selectedSprite:nil 
                                                                     target:self 
                                                                   selector:@selector(continueHandler)];
        
        self.menu = [CCMenu menuWithItems:levelButton,restartButton,soundButton,continueButton, nil];
        [menu alignItemsHorizontally];
        [menu setIsTouchEnabled:NO];
        
        [self addChild:background];
        [self addChild:menu];
    }
    return self;
}

-(void)levelButtonHandler
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"levelButtonTouched" object:self userInfo:nil];
}

-(void)restartHandler
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"restartButtonTouched" object:self userInfo:nil];
}

-(void)pause:(BOOL)p
{
    if(p)
    {
        [self setVisible:YES];
        [background runAction:[CCFadeTo actionWithDuration:.5 opacity:200]];
        [menu runAction:[CCFadeIn actionWithDuration:.5]];
        [menu setIsTouchEnabled:YES];
    }
    else
    {
        [background runAction:[CCFadeTo actionWithDuration:.5 opacity:0]];
        CCSequence *seq = [CCSequence actions:[CCFadeOut actionWithDuration:.5],[CCCallFunc actionWithTarget:self selector:@selector(hide)], nil];
        [menu runAction:seq];
        [menu setIsTouchEnabled:NO];
    }
}
                           
-(void)hide
{
    [self setVisible:NO];
}

-(void)soundHandler
{
    
    CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
    if(soundOn)
    {
        [soundButton setNormalImage:[CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"soundOffButton.png"]]];
        self.soundOn = NO;
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    }
    else
    {
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
        [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
        
        [soundButton setNormalImage:[CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"soundOnButton.png"]]];
        self.soundOn = YES;
    }
}

-(void)continueHandler
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueButtonTouched" object:self userInfo:nil];
}

@end
