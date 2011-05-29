//
//  RockFall.h
//  ProtoMesh2
//
//  Created by Efflam on 17/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Actor.h"

@protocol RockFallDelegate;
@interface RockFall : NSObject 
{
    CGPoint emissionPoint;
    float frequency;
    NSTimer *timer;
    id <RockFallDelegate> delegate;
    u_int maxRocks;
    NSMutableArray *rocks;
    BOOL emitting;
}

@property(nonatomic, assign) CGPoint emissionPoint;
@property(readwrite, assign) float frequency;
@property(nonatomic, retain) id <RockFallDelegate>  delegate;
@property(nonatomic, retain) NSTimer  *timer;
@property(readwrite, assign) u_int maxRocks;
@property(nonatomic, retain) NSMutableArray *rocks;
@property(readwrite, assign) BOOL emitting;

- (id)initWithDelegate:(id)del;
+(id)rockFallWithDelegate:(id)del;
-(void)startEmission;
-(void)stopEmission;
-(void)toggleEmission;
-(void)emitRockAt:(CGPoint)p;
-(void)onTimer;

@end

@protocol RockFallDelegate <NSObject>

-(void)addActor:(Actor *)anActor;
-(void)removeActor:(Actor *)anActor;
-(void)addChild:(id)child z:(int)zIndex tag:(int)tagNumber;

@end
