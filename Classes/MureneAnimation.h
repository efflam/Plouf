//
//  MureneAnimation.h
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MureneAnimation : CCNode
{
    CCSprite *topJaw;
    CCSprite *bottomJaw;
    CCSprite *body;
}


@property(nonatomic, retain) CCSprite *topJaw;

@property(nonatomic, retain) CCSprite *bottomJaw;

@property(nonatomic, retain) CCSprite *body;

-(id)init;
+(id)animation;

@end
