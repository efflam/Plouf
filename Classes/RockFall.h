//
//  RockFall.h
//  ProtoMesh2
//
//  Created by Efflam on 17/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CorridorView.h"

@interface RockFall : NSObject 
{
    CGPoint emissionPoint;
    float frequency;
    NSTimer *timer;
    CorridorView *game;
    u_int maxRocks;
    NSMutableArray *rocks;
    BOOL emitting;
}

@property(nonatomic, assign) CGPoint emissionPoint;
@property(readwrite, assign) float frequency;
@property(nonatomic, retain) CorridorView  *game;
@property(nonatomic, retain) NSTimer  *timer;
@property(readwrite, assign) u_int maxRocks;
@property(nonatomic, retain) NSMutableArray *rocks;
@property(readwrite, assign) BOOL emitting;

- (id)initWithGame:(CorridorView *)aGame;
+(id)rockFallWithGame:(CorridorView *)aGame;
-(void)startEmission;
-(void)stopEmission;
-(void)toggleEmission;
-(void)emitRockAt:(CGPoint)p;
-(void)onTimer;

@end
