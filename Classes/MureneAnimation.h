//
//  MureneAnimation.h
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationHelper.h"

@interface MureneAnimation : CCNode <AnimationHelperDelegate>
{
    CCSprite *topJaw;
    CCSprite *bottomJaw;
    CCSprite *body;
    AnimationHelper *bulles;
}
@property(nonatomic,retain)AnimationHelper *bulles;

@property(nonatomic, retain) CCSprite *topJaw;

@property(nonatomic, retain) CCSprite *bottomJaw;

@property(nonatomic, retain) CCSprite *body;

-(id)init;
+(id)animation;
-(void)openToAngle:(float)angle andDuration:(float)duration;
-(void)wash;
-(void)endWash;
-(void)eat;
-(void)close;

@end
