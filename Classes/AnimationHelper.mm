//
//  FishAnimation.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "AnimationHelper.h"


@implementation AnimationHelper
@synthesize listen,delegate,frames;

-(void)dealloc
{
    [self cleanup];
    [self setDelegate:nil];
    [self setListen:NO];
    [self.frames removeAllObjects];
    [frames release];
    [delegate release];
    [super dealloc];
}

-(void)onExit
{
    [self cleanup];
    [self setDelegate:nil];
    [self setListen:NO];
    [self.frames removeAllObjects];
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
        
        self.frames = [NSMutableArray arrayWithCapacity:frameNumber];
        
        for (int i = 0; i < frameNumber; i++)
        {
            NSString* file = [NSString stringWithFormat:@"%@%@%i.png", name, option,i];
            CCSpriteFrame* frame = [frameCache spriteFrameByName:file]; 
            [self.frames addObject:frame];
        }
    }
    
	return self;
}

-(void)runAnimation
{
    [self runAction:
        [CCRepeatForever actionWithAction:
            [CCSequence actions:
                [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:frames delay:0.06f]],
                [CCCallBlock actionWithBlock:^(void) 
                 { 
                    if(self.listen) 
                    { 
                        [self.delegate animationComplete];
                    }
                 }], nil]]];
}

-(void)stopAnimation
{
    [self cleanup];
    [self setListen:NO];
}

@end
