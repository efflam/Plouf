//
//  Murene.m
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Murene.h"


@implementation Murene

@synthesize sprite;
@synthesize washing;

- (void)dealloc
{
	[self setSprite:nil];
	[super dealloc];
}

- (id)init
{
	self = [super init];
    if(self)
    {
		self.washing = NO;
	}
	return self;
}

+(id)murene
{
    return [[[Murene alloc] init] autorelease];
}


- (void)actorDidAppear 
{	
	[super actorDidAppear];
    self.sprite = [MureneAnimation animation];
    [[self scene] addChild:self.sprite];
}


- (void)actorWillDisappear 
{
    [[self scene] removeChild:self.sprite cleanup:NO];
}


-(void)eat
{
    
    [[self sprite] runAction:
                    [CCSequence actions:
                                [CCMoveBy actionWithDuration:0.4 position:ccp(100.0f, 0.0f)],
                                [CCMoveBy actionWithDuration:0.5 position:ccp(-100.0f, 0.0f)],
                                nil 
                    ]
    ];
 [self.sprite eat];
}

-(void)wash
{
    [self.sprite wash];
    self.washing = YES;
}


-(void)unwash
{
    [self.sprite endWash];
    self.washing = NO;
}

- (void)worldDidStep 
{
	[super worldDidStep];
}



- (CGPoint)position
{
	return self.sprite.position;
}

- (void)setPosition:(CGPoint)aPosition
{
    [self.sprite setPosition:aPosition];
}

- (CGFloat)rotation
{
	return self.sprite.rotation;
}

- (void)setRotation:(CGFloat)aRotation
{
	[self.sprite setRotation:aRotation];
}




@end
