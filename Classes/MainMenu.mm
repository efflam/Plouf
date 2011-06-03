//
//  MainMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 25/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "MainMenu.h"
#import "Loader.h"
#import "WinMenu.h"
#import "FishMenu.h"
#import "MerciScreen.h"
#import "LoseMenu.h"
#import "SimpleAudioEngine.h"

@implementation MainMenu
@synthesize loader;

+(id) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [MainMenu node]];
    //    [scene addChild:[HelloWorld node]];
    
	return scene;
}

-(void)dealloc
{
    [loader release];
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if(self)
    {        
        self.loader = [EnvironmentMenu node];
        
        CCSprite *background = [CCSprite spriteWithFile:@"mainMenuBackground.png"];
        [background setAnchorPoint:ccp(0,0)];
        [background setPosition:ccp(0,-200)];
        [self addChild:background];
        
        CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
        [logo setAnchorPoint:ccp(0,0)];
        [logo setPosition:ccp(280,505)];
        [self addChild:logo];
                        
        [background runAction:
            [CCEaseSineInOut actionWithAction:
                [CCMoveTo actionWithDuration:1.5 position:ccp(0,0)]]];
        [logo runAction:
            [CCEaseSineInOut actionWithAction:
                [CCMoveTo actionWithDuration:1.5 position:ccp(280,210)]]];
    
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"playButton.png" 
                                                             selectedImage:nil 
                                                                    target:self 
                                                                  selector:@selector(play)];
        
        [playButton setPosition:ccp(512,-200)];
        
        CCMenuItemImage *infoButton = [CCMenuItemImage itemFromNormalImage:@"infoButton.png" 
                                                             selectedImage:nil 
                                                                    target:self 
                                                                  selector:@selector(infoHandler)];
        [infoButton setAnchorPoint:ccp(0,0)];
        [infoButton setPosition:ccp(10,-250)];
        
        CCMenuItemImage *collectionButton = [CCMenuItemImage itemFromNormalImage:@"collectionButton.png" 
                                                                   selectedImage:nil 
                                                                          target:self 
                                                                        selector:@selector(collection)];
        [collectionButton setAnchorPoint:ccp(1,0)];
        [collectionButton setPosition:ccp(SCREEN_CENTER.x*2,-250)];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, infoButton,collectionButton, nil];
        [menu setPosition:ccp(0,0)];
        
        [playButton runAction:
            [CCEaseSineInOut actionWithAction:
                [CCMoveTo actionWithDuration:1.5 position:ccp(512,130)]]];
        
        [collectionButton runAction:
            [CCSequence actions:
                [CCDelayTime actionWithDuration:0.5],
                [CCEaseSineInOut actionWithAction:
                    [CCMoveTo actionWithDuration:1.5 position:ccp(SCREEN_CENTER.x*2,5)]],
             nil]];
        
        [infoButton runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:0.8],
          [CCEaseSineInOut actionWithAction:
           [CCMoveTo actionWithDuration:1.5 position:ccp(10,5)]],
          nil]];
        
        [self addChild:menu];
    }
    
    return self;
}

-(void)infoHandler
{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    CCScene *loaderScene = [CCScene node];
    [loaderScene addChild:[MerciScreen node]];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

-(void)play
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    CCScene *loaderScene = [CCScene node];
    [loaderScene addChild:loader];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

-(void)collection
{    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    CCScene *loaderScene = [CCScene node];
    [loaderScene addChild:[FishMenu node]];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

@end
