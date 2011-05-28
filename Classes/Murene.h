//
//  Murene.h
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MureneAnimation.h"
#import "Actor.h"

@interface Murene : Actor
{
    MureneAnimation *sprite;
}

@property(nonatomic, retain) MureneAnimation *sprite;

- (id)init;
+(id)murene;
- (CGPoint)position;
- (void)setPosition:(CGPoint)aPosition;
- (CGFloat)rotation;
- (void)setRotation:(CGFloat)aRotation;

@end
