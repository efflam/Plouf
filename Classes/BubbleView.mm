//
//  BubbleView.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 12/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "BubbleView.h"


@implementation BubbleView
@synthesize bubblesTrackable;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self setAnchorPoint:ccp(0,0)];
        
        self.bubblesTrackable = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMe:) name:@"showMe" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackMe:) name:@"trackMe" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unTrackMe:) name:@"unTrackMe" object:nil];
    }
    
    return self;
}

-(void)showMe:(NSNotification*)notification
{
    id <BubbleTrackable> bubbleTrackable = [notification object];
    [self addChild:[bubbleTrackable bubbleSprite]];
    
    [[bubbleTrackable bubbleSprite] setScale:0.0];
    [[bubbleTrackable bubbleSprite] runAction:[CCScaleTo actionWithDuration:0.3 scale:1.0]];
        
    [[bubbleTrackable bubbleSprite] setPosition:[bubbleTrackable bubblePoint]];
    [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:[bubbleTrackable bubbleSprite] priority:1];
    
    [self.bubblesTrackable addObject:bubbleTrackable];
}

//-(void)trackMe:(NSNotification*)notification
//{
//    id <BubbleTrackable> bubbleTrackable = [notification object];
//    [[bubbleTrackable bubbleSprite] setPosition:[bubbleTrackable bubblePoint]];
//}

-(void)update:(ccTime)dt
{
    for(id <BubbleTrackable> item in bubblesTrackable)
    {
        [[item bubbleSprite] setPosition:[item bubblePoint]];
    }
}

-(void)unTrackMe:(NSNotification*)notification
{
    id <BubbleTrackable> bubbleTrackable = [notification object];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:[bubbleTrackable bubbleSprite]];
    
    CCCallFuncND *func = [CCCallFuncN actionWithTarget:self selector:@selector(removeBubble:)];
    CCSequence *seq = [CCSequence actions:[CCScaleTo actionWithDuration:0.2 scale:0.0], func,nil];
    
    [[bubbleTrackable bubbleSprite] runAction:seq];
    
    [self.bubblesTrackable removeObject:bubbleTrackable];
    //[self removeChild:[bubbleTrackable bubbleSprite] cleanup:NO]
}

-(void)removeBubble:(id)node
{
    [self removeChild:node cleanup:NO];
}

-(void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for(id <BubbleTrackable> item in bubblesTrackable)
    {
        [[item bubbleSprite] setTarget:nil];
    }
    [bubblesTrackable removeAllObjects];
    [bubblesTrackable release];
    [super dealloc];
}

@end
