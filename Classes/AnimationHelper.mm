//
//  FishAnimation.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "AnimationHelper.h"


@implementation AnimationHelper
@synthesize listen,action,delegate;

-(void)dealloc
{
    [self setDelegate:nil];
    [self setListen:NO];
    [self cleanup];
    [action release];
    [delegate release];
    [super dealloc];
}

-(void)onExit
{
    [[self action] stop];
    [self stopAllActions];
    [self setDelegate:nil];
    [self setListen:NO];
    [self cleanup];
    [super onExit];
}

+(id) animationWithName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber
{
    return [[[AnimationHelper alloc] initWithAnimationName:name andOption:option frameNumber:frameNumber] autorelease];
}

-(id) initWithAnimationName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber
{
    self = [super init];
    
    if (self)
    {
        self.listen = NO;
        
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        [frameCache addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",name] texture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%@.png",name]]];
        
        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameNumber];
        
        for (int i = 0; i < frameNumber; i++)
        {
            NSString* file = [NSString stringWithFormat:@"%@%@%i.png", name, option,i];
            CCSpriteFrame* frame = [frameCache spriteFrameByName:file]; 
            [frames addObject:frame];
        }
        
        CCAnimation* anim   = [CCAnimation animationWithFrames:frames delay:0.06f];
        CCAnimate* animate  = [CCAnimate actionWithAnimation:anim];
        CCCallBlock *func    = [CCCallBlock actionWithBlock:^(void) 
        {
            if(self.listen) 
            {
                [self.delegate animationComplete];
            }
        }];
        CCSequence *seq     = [CCSequence actions:animate,func, nil];
        
        self.action = [CCRepeatForever actionWithAction:seq];
    }
    
	return self;
}

-(void)stopAllActions
{
    self.listen = NO;
    [super stopAllActions];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"stop");
}

@end
