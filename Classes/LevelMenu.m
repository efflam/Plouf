//
//  LevelMenu.m
//  ProtoMesh2
//
//  Created by Efflam on 27/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "LevelMenu.h"
#import "Loader.h"

@implementation LevelMenu

- (id)init {
    self = [super init];
    if (self) {
        
        CCSprite *bg = [CCSprite spriteWithFile:@"backgroundMenu.png"];
        [bg setAnchorPoint:ccp(0,0)];
        
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        [frames addSpriteFramesWithFile:@"levelNumbers.plist" 
                                texture:[[CCTextureCache sharedTextureCache] addImage:@"levelNumbers.png"]];
        
        CCSprite *sprite1       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot1.png"]];
        CCMenuItemImage *ilot1  = [CCMenuItemImage itemFromNormalSprite:sprite1 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:@selector(loadLevel)];
        
        CCSprite *sprite2       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot2.png"]];
        CCMenuItemImage *ilot2  = [CCMenuItemImage itemFromNormalSprite:sprite2 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:@selector(loadLevel)];
        
        CCSprite *sprite3       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot3.png"]];
        CCMenuItemImage *ilot3  = [CCMenuItemImage itemFromNormalSprite:sprite3 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:@selector(loadLevel)];
        
        CCSprite *sprite4       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot4.png"]];
        CCMenuItemImage *ilot4  = [CCMenuItemImage itemFromNormalSprite:sprite4 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:@selector(loadLevel)];
        
        CCSprite *sprite5       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot5.png"]];
        CCMenuItemImage *ilot5  = [CCMenuItemImage itemFromNormalSprite:sprite5 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:@selector(loadLevel)];
        
        CCSprite *sprite6       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot6.png"]];
        CCMenuItemImage *ilot6  = [CCMenuItemImage itemFromNormalSprite:sprite6 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:nil];
        
        CCSprite *sprite7       = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"ilot7.png"]];
        CCMenuItemImage *ilot7  = [CCMenuItemImage itemFromNormalSprite:sprite7 
                                                         selectedSprite:nil 
                                                                 target:self 
                                                               selector:nil];
        
        CCMenu *menu = [CCMenu menuWithItems:ilot1,ilot2,ilot3,ilot4,ilot5,ilot6,ilot7, nil];
        [menu setAnchorPoint:ccp(0,0)];
        
        [ilot1 setPosition:ccp(-700,-700)];
        [ilot2 setPosition:ccp(10,-700)];
        [ilot3 setPosition:ccp(700,-700)];
        [ilot4 setPosition:ccp(-700,-700)];
        [ilot5 setPosition:ccp(-700,-700)];
        [ilot6 setPosition:ccp(700,-700)];
        [ilot7 setPosition:ccp(700,-700)];
        
        CCSprite *infos = [CCSprite spriteWithFile:@"tropicInfo.png"];
        [infos setAnchorPoint:ccp(0,0)];
        
        CCSprite *title = [CCSprite spriteWithFile:@"tropicTitle.png"];
        [title setPosition:ccp(512,640)];
        
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton.png" target:self selector:@selector(back)];
        
        [backButton setPosition:ccp(-440,-310)];
        [menu addChild:backButton];
        
        [self addChild:bg];
        [self addChild:title];
        [self addChild:infos];
        [self addChild:menu];
        
        [ilot1 runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(-256,96)]];
        [ilot2 runAction:[CCMoveTo actionWithDuration:1.1 position:ccp(10,96)]];
        [ilot3 runAction:[CCMoveTo actionWithDuration:1.2 position:ccp(276,96)]];
        [ilot4 runAction:[CCMoveTo actionWithDuration:1.3 position:ccp(-307,-97)]];
        [ilot5 runAction:[CCMoveTo actionWithDuration:1.2 position:ccp(-92,-97)]];
        [ilot6 runAction:[CCMoveTo actionWithDuration:1.1 position:ccp(122,-97)]];
        [ilot7 runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(337,-97)]];
        
    }
    return self;
}

-(void)back
{
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5];
}

- (void)loadLevel
{
    NSLog(@"loadLevel");
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
    
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:.5 
                                        scene:scene]];
    
}

@end
