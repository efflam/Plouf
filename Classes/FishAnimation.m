//
//  FishAnimation.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "FishAnimation.h"


@implementation FishAnimation
@synthesize listen;

+(id) fishWithName:(NSString*)name andOption:(NSString*)option
{
    return [[[FishAnimation alloc] initWithFishName:name andOption:option] autorelease];
}

-(id) initWithFishName:(NSString*)name andOption:(NSString*)option
{
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",name]];
    
    self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",name]];
    
    if (self)
    {
        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:9];
        
        for (int i = 0; i < 9; i++)
        {
            NSString* file = [NSString stringWithFormat:@"%@%@%i.png", name, option,i];
            CCSpriteFrame* frame = [frameCache spriteFrameByName:file]; 
            [frames addObject:frame];
        }
        
        CCAnimation* anim = [CCAnimation animationWithFrames:frames delay:0.06f];
        CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
        CCCallFunc *func = [CCCallFunc actionWithTarget:self selector:@selector(animationComplete)];
        CCSequence *seq = [CCSequence actions:animate,func, nil];
        
        CCRepeatForever* repeat = [CCRepeatForever actionWithAction:seq];
        
        [self runAction:repeat];
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
