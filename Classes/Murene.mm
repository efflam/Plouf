//
//  Murene.m
//  ProtoMesh2
//
//  Created by Efflam on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Murene.h"
#import "SimpleAudioEngine.h"


@implementation Murene

@synthesize sprite;
@synthesize washing;

- (void)dealloc
{
	[sprite release];
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
    [[self scene] removeChild:self.sprite cleanup:YES];
    [self.sprite stopAllActions];
    [super actorWillDisappear];
}

-(void)eat
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"croque.caf"];
    [self.sprite eat];
}

-(void)wash
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"wash.caf"];
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
