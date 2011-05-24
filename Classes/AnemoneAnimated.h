//
//  AnemoneAnimated.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationHelper.h"

@interface AnemoneAnimated : CCNode {
    AnimationHelper *body;
    AnimationHelper *eat;
}
@property(nonatomic,retain) AnimationHelper *body;
@property(nonatomic,retain) AnimationHelper *eat;

-(void)setFlipX:(BOOL)flip;
+(id)anemone;
-(void)ate;

@end
