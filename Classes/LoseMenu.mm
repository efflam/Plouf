//
//  LoseMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "LoseMenu.h"
#import "Loader.h"
#import "LevelMenu.h"
#import "SimpleAudioEngine.h"

@implementation LoseMenu
@synthesize parcel;

-(void)dealloc
{
    [parcel release];
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        // ASSETS
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"loseAssets.plist" 
                                                                 textureFile:@"loseAssets.png"];
        
        // ELEMENTS
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"loseBackground.png"];
        CCSprite *text = [CCSprite spriteWithSpriteFrameName:@"loseText.png"];
        self.parcel = [CCSprite spriteWithFile:@"loseParcel.png"];
        
        [background setAnchorPoint:CGPointZero];
        [parcel setAnchorPoint:ccp(.5,0)];
        
        [text setPosition:ccpAdd(SCREEN_CENTER,ccp(20,130))];
        [parcel setPosition:ccp(512,768)];
        
        // MENU
        
        CCMenuItemSprite *restart = [CCMenuItemSprite itemFromNormalSprite:
                                        [CCSprite spriteWithSpriteFrameName:@"restartButton.png"]
                                                            selectedSprite:nil 
                                                                    target:self 
                                                                  selector:@selector(restartHandler)];
        
        CCMenuItemSprite *level = [CCMenuItemSprite itemFromNormalSprite:
                                        [CCSprite spriteWithSpriteFrameName:@"levelButton.png"]
                                                          selectedSprite:nil 
                                                                  target:self 
                                                                selector:@selector(levelMenuHandler)];
        
        CCMenu *menu = [CCMenu menuWithItems:level,restart, nil];
        [menu alignItemsHorizontally];
        [menu setPosition:ccpSub(menu.position, ccp(0,70))];
        
        // ADD CHILDREN
        
        [self addChild:background];
        [self addChild:parcel];
        [self addChild:menu];
        [self addChild:text];
        
        [self setOpacity:0];
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"perdu.mp3" loop:NO];
}


-(void)onExit
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [super onExit];
}

-(void)levelMenuHandler
{    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[LevelMenu node]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
}

-(void)restartHandler
{    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self runAction:[CCFadeIn actionWithDuration:.5]];
    
    [parcel runAction:[CCMoveTo actionWithDuration:6.0 position:ccp(512,-768)]];
}

-(void) setOpacity: (GLubyte) opacity
{
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
    }
}

@end
