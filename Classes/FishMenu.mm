//
//  FishMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "FishMenu.h"


@implementation FishMenu
@synthesize image1;
@synthesize image2;
@synthesize turned;
@synthesize isTurning;

-(void)dealloc
{
    [image1 release];
    [image2 release];
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.isTouchEnabled = YES;
        
        // BACK BUTTON
        
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"backButton.png" selectedImage:@"backButton.png" target:self selector:@selector(back)];
        [backButton setPosition:ccp(-440,-310)];
        CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
        [menu setAnchorPoint:ccp(0,0)];
        
        // ELEMENTS
        
        CCSprite *background = [CCSprite spriteWithFile:@"fishBackground.png"];
        [background setAnchorPoint:CGPointZero];
        
        self.image1 = [CCSprite spriteWithFile:@"papillon1.png"];
        self.image2 = [CCSprite spriteWithFile:@"papillon2.png"];
        
        [image1 setPosition:SCREEN_CENTER];
        [image2 setPosition:SCREEN_CENTER];
        
        [image2 setScaleX:0];
        [image2 setFlipX:YES];
        
        [self addChild:background];
        [self addChild:image1];
        [self addChild:image2];
        [self addChild:menu];
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isTurning)
    {
        self.isTurning = YES;
        self.turned = !self.turned;
        
        if(self.turned)
        {
            [self.image1 runAction:[CCScaleTo actionWithDuration:0.3 scaleX:0 scaleY:1]];
            [self.image2 runAction:[CCSequence actions:
                                    [CCDelayTime actionWithDuration:0.3],
                                    [CCScaleTo actionWithDuration:0.3 scaleX:1 scaleY:1],
                                    [CCCallBlock actionWithBlock:^(void) {
                                        self.isTurning = NO;
                                    }],
                                    nil]];
        }
        else
        {
            [self.image2 runAction:[CCScaleTo actionWithDuration:0.3 scaleX:0 scaleY:1]];
            [self.image1 runAction:[CCSequence actions:
                                    [CCDelayTime actionWithDuration:0.3],
                                    [CCScaleTo actionWithDuration:0.3 scaleX:1 scaleY:1],
                                    [CCCallBlock actionWithBlock:^(void) {
                                        self.isTurning = NO;
                                    }],
                                    nil]];
        }
    }
}

-(void)onEnter
{
    [self loopAnimation];
    [super onEnter];
}

-(void)onExit
{
    [image1 stopAllActions];
    [image2 stopAllActions];
    [super onExit];
}

-(void)loopAnimation
{
    self.isTurning = YES ;
    
    [self.image1 runAction:[CCSequence actions:
                            [CCScaleTo actionWithDuration:0.5 scaleX:0 scaleY:1],
                            [CCDelayTime actionWithDuration:1],
                            [CCScaleTo actionWithDuration:0.5 scaleX:1 scaleY:1],
                            nil]];
    [self.image2 runAction:[CCSequence actions:
                            [CCDelayTime actionWithDuration:0.5],
                            [CCScaleTo actionWithDuration:0.5 scaleX:1 scaleY:1],
                            [CCScaleTo actionWithDuration:0.5 scaleX:0 scaleY:1],
                            [CCCallBlock actionWithBlock:^(void) {
                                self.isTurning = NO;
                            }],
                            nil]];
}

-(void)back
{
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5];
}

@end
