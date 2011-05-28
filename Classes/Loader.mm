//
//  Loader.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 25/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Loader.h"
#import "LevelView.h"

@implementation Loader
@synthesize playScene, playButton;

+(id) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [Loader node]];
    //    [scene addChild:[HelloWorld node]];
    
	return scene;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        CCSprite *background = [CCSprite spriteWithFile:@"loader.png"];
        
        [background setAnchorPoint:ccp(0,0)];
        
        [self addChild:background];
        
        //CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton.png" target:self selector:@selector(back)];
        
        self.playButton = [CCMenuItemImage itemFromNormalImage:@"playButton.png" selectedImage:@"playButton.png" target:self selector:@selector(play)];
        
        [playButton setPosition:ccp(768,-200)];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, nil];
        [menu setPosition:ccp(0,0)];       
        
        //[backButton setPosition:ccp(20,100)];
        
        [menu setAnchorPoint:ccp(0,0)];
        
        [self addChild:menu];
        
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0 scene:playScene]];
    }
    
    return  self;
}

-(void)back
{
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5];
}

-(void)dealloc
{
    [playButton release];
    [playScene release];
    [super dealloc];
}

-(void)onEnterTransitionDidFinish
{
    //[super onEnterTransitionDidFinish];
    self.playScene = [CCScene node];
    [playScene addChild:[LevelView levelWithName:@"level1"]];
    [playButton runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:ccp(840,100)]]];
}

-(void)play
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:playScene]];
}



@end
