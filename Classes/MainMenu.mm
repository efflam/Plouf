//
//  MainMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 25/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "MainMenu.h"
#import "Loader.h"

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
        self.loader = [Loader node];
        
        CCSprite *background = [CCSprite spriteWithFile:@"mainMenuBackground.png"];
        [background setAnchorPoint:ccp(0,0)];
        [background setPosition:ccp(0,-200)];
        [self addChild:background];
        
        CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
        [logo setAnchorPoint:ccp(0,0)];
        [logo setPosition:ccp(280,505)];
        [self addChild:logo];
                
        CCMoveTo *moveBackground    = [CCMoveTo actionWithDuration:1.5 position:ccp(0,0)];
        CCMoveTo *moveLogo          = [CCMoveTo actionWithDuration:1.5 position:ccp(280,210)];
        
        [background runAction:[CCEaseSineInOut actionWithAction:moveBackground]];
        [logo       runAction:[CCEaseSineInOut actionWithAction:moveLogo]];
    
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"playButton.png" selectedImage:@"playButton.png" target:self selector:@selector(play)];
        
        [playButton setPosition:ccp(512,-200)];
        
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, nil];
        [menu setPosition:ccp(0,0)];
        
        [playButton runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:ccp(512,130)]]];
        
        [self addChild:menu];
    }
    
    return self;
}

-(void)play
{
    NSLog(@"Play");
    
    CCScene *loaderScene = [CCScene node];
    
    [loaderScene addChild:loader];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:loaderScene]];
}

@end
