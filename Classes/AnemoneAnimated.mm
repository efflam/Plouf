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
        
        [self.body runAnimation];
        [self.eat runAnimation];
    }
    
    return self;
}

-(void)ate
{
    self.body.visible = NO;
    self.eat.visible = YES;
    
    [[CCActionManager sharedManager] pauseTarget:self.body];
}

-(void)animationComplete
{
    //
}

+(id)anemone
{
    return [[[AnemoneAnimated alloc] init] autorelease];
}

-(void)onExit
{
    [self.body stopAnimation];
    [self.eat stopAnimation];
    [super onExit];
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
