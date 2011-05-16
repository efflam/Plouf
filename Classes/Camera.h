//
//  Camera.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 11/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "globals.h"
#import "cocos2d.h"

@protocol CameraDelegate;
@interface Camera : CCNode {
    id <CameraDelegate> delegate;
    CGPoint currentPosition;
    CGSize mapSize;
    CGSize winSize;
    CGPoint rawPosition;
}

@property(readwrite,assign) CGPoint rawPosition;
@property(nonatomic,retain) id <CameraDelegate> delegate;
@property(readwrite,assign) CGPoint currentPosition;

+(Camera *)standardCamera;
-(CGPoint)position;
-(CGPoint)checkBoundsForPoint:(CGPoint)point withScale:(float)newScale;
-(void)springTo:(CGPoint)position withSpring:(float)spring;

@end

@protocol CameraDelegate <NSObject>

-(void)setPosition:(CGPoint)position;
-(CGPoint)position;

@end
