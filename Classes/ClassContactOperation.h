//
//  ClassContactOperation.h
//  ProtoMesh2
//
//  Created by Efflam on 20/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassContactOperation : NSObject 
{
    Class actorClass;
    id target;
    SEL selector;
    BOOL fireOnce;
    int whenTag;
}

@property(readwrite, assign) Class actorClass;
@property(nonatomic, retain) id target;
@property(readwrite, assign) SEL selector;
@property(readwrite, assign) BOOL fireOnce;
@property(readwrite, assign) int whenTag;

- (id)initForClass:(Class )aActorClass WithTarget:(id )aTarget andSelector:(SEL)aSelector when:(int)aWhenTag;
+(id)operationFor:(Class )aActorClass WithTarget:(id )aTarget andSelector:(SEL)aSelector when:(int)aWhenTag;
-(void)execute;


@end