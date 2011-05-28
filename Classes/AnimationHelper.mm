//
//  FishAnimation.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "AnimationHelper.h"


@implementation AnimationHelper
@synthesize listen,action;

-(void)dealloc
{
    [self setListen:NO];
    [action release];
    [super dealloc];
}

+(id) animationWithName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber
{
    return [[[AnimationHelper alloc] initWithAnimationName:name andOption:option frameNumber:frameNumber] autorelease];
}

//+(CCAnimate*) animateWithName:(NSString*)name option:(NSString*)option frameNumber:(int)frameNumber
//{
//    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
//    [frameCache addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",name]];
//    
//    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameNumber];
//        
//    for (int i = 0; i < frameNumber; i++)
//    {
//        NSString* file = [NSString stringWithFormat:@"%@%@%i.png", name, option,i];
//        CCSpriteFrame* frame = [frameCache spriteFrameByName:file]; 
//        [frames addObject:frame];
//    }
//        
//    CCAnimation* anim   = [CCAnimation animationWithFrames:frames delay:0.06f];
//    CCAnimate* animate  = [CCAnimate actionWithAnimation:anim];
//    
//	return animate;
//}

-(id) initWithAnimationName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber
{
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [frameCache addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",name] texture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%@.png",name]]];
    
//    self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",name]];
    
    self = [super init];
    
    if (self)
    {
        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameNumber];
        
        for (int i = 0; i < frameNumber; i++)
        {
            NSString* file = [NSString stringWithFormat:@"%@%@%i.png", name, option,i];
            CCSpriteFrame* frame = [frameCache spriteFrameByName:file]; 
            [frames addObject:frame];
        }
        
        CCAnimation* anim   = [CCAnimation animationWithFrames:frames delay:0.06f];
        CCAnimate* animate  = [CCAnimate actionWithAnimation:anim];
        CCCallFunc *func    = [CCCallFunc actionWithTarget:self selector:@selector(animationComplete)];
        CCSequence *seq     = [CCSequence actions:animate,func, nil];
        
        self.action = [CCRepeatForever actionWithAction:seq];
    }
    
	return self;
}

-(void)animationComplete
{
    if(listen) [[NSNotificationCenter defaultCenter] postNotificationName:@"animationComplete" object:self];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"stop");
}

@end
