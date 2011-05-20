//
//  ClassContactOperation.m
//  ProtoMesh2
//
//  Created by Efflam on 20/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "ClassContactOperation.h"


@implementation ClassContactOperation

@synthesize actorClass;
@synthesize target;
@synthesize selector;
@synthesize fireOnce;
@synthesize whenTag;

- (id)initForClass:(Class )aActorClass WithTarget:(id)aTarget andSelector:(SEL)aSelector when:(int)aWhenTag
{
	self = [super init];
    if(self)
    {
        self.actorClass = aActorClass;
        self.target = aTarget;
        self.selector = aSelector;
        self.whenTag = aWhenTag;
        self.fireOnce = NO;
    }
	return self;
}

+(id)operationFor:(Class )aActorClass WithTarget:(id)aTarget andSelector:(SEL) aSelector when:(int)aWhenTag
{
    return [[[ClassContactOperation alloc] initForClass:aActorClass WithTarget:aTarget andSelector:aSelector when:aWhenTag] autorelease];
}

-(void)execute
{
    if (self.target && self.selector && [[self target] respondsToSelector:self.selector])
    {
        (void) [target performSelector:selector
                            withObject:self];
    }
}


@end