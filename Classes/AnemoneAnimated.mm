//
//  AnemoneAnimated.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "AnemoneAnimated.h"


@implementation AnemoneAnimated
@synthesize body, eat;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.body = [AnimationHelper animationWithName:@"anemone" andOption:@"" frameNumber:12];
        self.eat = [AnimationHelper animationWithName:@"anemone" andOption:@"coup" frameNumber:12];
        
        self.eat.visible = NO;
        self.body.listen = NO;
        
        [self addChild:self.body];
        [self addChild:self.eat];
        
        [self.body runAction:self.body.action];
        [self.eat runAction:self.eat.action];
    }
    
    return self;
}

-(void)ate
{
    self.body.visible = NO;
    self.eat.visible = YES;
    
    [[CCActionManager sharedManager] pauseTarget:self.body];
}

+(id)anemone
{
    return [[[AnemoneAnimated alloc] init] autorelease];
}

-(void) setFlipX:(BOOL)flip
{
    for (uint i = 0; i < [[self children] count]; i++) 
    {
        [[[self children] objectAtIndex:i] setFlipX:flip];
    }
}

-(void)dealloc
{
    [body release];
    [eat release];
    [super dealloc];
}

@end
