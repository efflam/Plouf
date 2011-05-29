//
//  InstanceContactOperation.m
//  ProtoMesh2
//
//  Created by Efflam on 20/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "InstanceContactOperation.h"


@implementation InstanceContactOperation

@synthesize actor;
@synthesize target;
@synthesize selector;
@synthesize fireOnce;
@synthesize whenTag;

- (id)initFor:(Actor *)aActor WithTarget:(id)aTarget andSelector:(SEL)aSelector when:(int)aWhenTag
{
	self = [super init];
    if(self)
    {
        self.actor = aActor;
        self.target = aTarget;
        self.selector = aSelector;
        self.whenTag = aWhenTag;
        self.fireOnce = NO;
    }
	return self;
}

+(id)operationFor:(Actor *)aActor WithTarget:(id)aTarget andSelector:(SEL) aSelector when:(int)aWhenTag
{
    return [[[InstanceContactOperation alloc] initFor:aActor WithTarget:aTarget andSelector:aSelector when:aWhenTag] autorelease];
}

-(void)execute
{
    if (self.target && self.selector && [[self target] respondsToSelector:self.selector])
    {
        (void) [target performSelector:selector
                              withObject:self];
    }
}


-(void)dealloc
{
    [actor release];
    [target release];
    [super dealloc];
}


@end
