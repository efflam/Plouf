//
//  InstanceContactOperation.h
//  ProtoMesh2
//
//  Created by Efflam on 20/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
@class Actor;

@interface InstanceContactOperation : NSObject 
{
    Actor *actor;
    id target;
    SEL selector;
    BOOL fireOnce;
    int whenTag;
}

@property(nonatomic, retain) Actor *actor;
@property(nonatomic, retain) id target;
@property(readwrite, assign) SEL selector;
@property(readwrite, assign) BOOL fireOnce;
@property(readwrite, assign) int whenTag;

- (id)initFor:(Actor *)aActor WithTarget:(id )aTarget andSelector:(SEL)aSelector when:(int)aWhenTag;
+(id)operationFor:(Actor *)aActor WithTarget:(id )aTarget andSelector:(SEL)aSelector when:(int)aWhenTag;
-(void)execute;


@end
