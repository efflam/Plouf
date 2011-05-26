//
//  MureneAnimation.m
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "MureneAnimation.h"


@implementation MureneAnimation

@synthesize topJaw;
@synthesize bottomJaw;
@synthesize body;

- (id)init
{
	self = [super init];
    if(self)
    {
		self.topJaw = [CCSprite spriteWithFile:@"machoire_haut.png"];
		self.bottomJaw = [CCSprite spriteWithFile:@"machoire_bas.png"];
		self.body = [CCSprite spriteWithFile:@"corps.png"];
        
        [self addChild:self.body];
        [self addChild:self.topJaw];
        [self addChild:self.bottomJaw];
	}
	return self;
}

+(id)animation
{
    return [[[MureneAnimation alloc] init] autorelease];
}


@end
