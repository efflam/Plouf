//
//  MureneAnimation.m
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "MureneAnimation.h"


@implementation MureneAnimation

@synthesize topJaw;
@synthesize bottomJaw;
@synthesize body;
@synthesize bulles;

- (id)init
{
	self = [super init];
    if(self)
    {
		self.topJaw     = [CCSprite spriteWithFile:@"machoire_haut.png"];
		self.bottomJaw  = [CCSprite spriteWithFile:@"machoire_bas.png"];
		self.body       = [CCSprite spriteWithFile:@"corps.png"];
        
        [topJaw setAnchorPoint:ccp(0.18,0.18)];
        [bottomJaw setAnchorPoint:ccp(0.19,0.73)];
        
        [topJaw setRotation:-10];
        [bottomJaw setRotation:10];
        
        [topJaw setPosition:ccp(310,35)];
        [bottomJaw setPosition:ccp(310,35)];
        
        [self addChild:self.body];
        [self addChild:self.bottomJaw];
        [self addChild:self.topJaw];
        
        self.bulles = [AnimationHelper animationWithName:@"bulle" andOption:@"" frameNumber:9];
        [bulles setOpacity:0.0];
        [bulles setDelegate:self];
        
        [self addChild:bulles];
        [bulles setPosition:ccp(383,45)];
        [bulles setRotation:14];
        [bulles runAction:bulles.action];
        
        //[self wash];
	}
	return self;
}

-(void)wash
{
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:^(void) {        
        [self openToAngle:18 andDuration:.5];
//        [bulles runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCFadeIn actionWithDuration:.5],[CCCallFunc actionWithTarget:self selector:@selector(endWash)],nil]];
        [bulles runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],[CCFadeIn actionWithDuration:.5],nil]];
    }];
    
    [self runAction:block];
}

-(void)animationComplete
{
    //
}

-(void)endWash
{
//    [bulles runAction:[CCSequence actions:[CCFadeOut actionWithDuration:.5],[CCCallFunc actionWithTarget:self selector:@selector(closeWash)],[CCDelayTime actionWithDuration:.5],[CCCallFunc actionWithTarget:self selector:@selector(wash)],nil]];
    [bulles runAction:[CCSequence actions:[CCFadeOut actionWithDuration:.5],[CCCallFunc actionWithTarget:self selector:@selector(close)],nil]];
}
     
-(void)close
{
    [self openToAngle:10 andDuration:.5];
}

-(void)openToAngle:(float)angle andDuration:(float)duration
{
    [topJaw runAction:[CCRotateTo actionWithDuration:duration angle:-angle]];
    [bottomJaw runAction:[CCRotateTo actionWithDuration:duration angle:angle]];
}

-(void)eat
{
    [topJaw runAction:
        [CCSequence actions:
            [CCRotateTo actionWithDuration:.3 angle:-35],
            [CCRotateTo actionWithDuration:.1 angle:0],
            [CCRotateTo actionWithDuration:.2 angle:-10],nil]];
    
    [bottomJaw runAction:
        [CCSequence actions:
            [CCRotateTo actionWithDuration:.3 angle:35],
            [CCRotateTo actionWithDuration:.1 angle:0],
            [CCRotateTo actionWithDuration:.2 angle:10],nil]];
}

+(id)animation
{
    return [[[MureneAnimation alloc] init] autorelease];
}


@end
