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
#import "LoseMenu.h"

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
                                                             selectedImage:@"playButton.png" 
                                                                    target:self 
                                                                  selector:@selector(play)];
        [playButton setPosition:ccp(512,-200)];
        
        CCMenuItemImage *collectionButton = [CCMenuItemImage itemFromNormalImage:@"collectionButton.png" 
                                                                   selectedImage:nil 
                                                                          target:self 
                                                                        selector:@selector(collection)];
        [collectionButton setAnchorPoint:ccp(1,0)];
        [collectionButton setPosition:ccp(SCREEN_CENTER.x*2,-250)];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, collectionButton, nil];
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
        
        [self addChild:menu];
    }
    
    return self;
}

-(void)play
{
    CCScene *loaderScene = [CCScene node];
    
    [loaderScene addChild:loader];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

-(void)collection
{    
    CCScene *loaderScene = [CCScene node];
    
    [loaderScene addChild:[LoseMenu node]];
    
//    [loaderScene addChild:[WinMenu winWithTime:185 sacrifices:2 indices:3]];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

@end
