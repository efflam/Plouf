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
}

@property(nonatomic,retain) id <CameraDelegate> delegate;
@property(readwrite,assign) CGPoint currentPosition;

+(Camera *)standardCamera;
-(CGPoint)position;
-(CGPoint)checkBoundsForPoint:(CGPoint)point withScale:(float)newScale;

@end

@protocol CameraDelegate <NSObject>

-(void)setPosition:(CGPoint)position;
-(CGPoint)position;

@end
