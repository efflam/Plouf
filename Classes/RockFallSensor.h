//
//  RockFallSensor.h
//  ProtoMesh2
//
//  Created by Efflam on 23/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RectSensor.h"
#import "RockFall.h"

@interface RockFallSensor : RectSensor 
{
    RockFall * rockFall;
    int coins;
}

@property(nonatomic, retain) RockFall *rockFall;
@property(readwrite, assign) int coins;

- (id)initFor:(RockFall *) aRockFall from:(CGPoint)a to:(CGPoint)b;
+(id)rockFallSensorFor:(RockFall *)aRockFall from:(CGPoint)a to:(CGPoint)b;

@end
