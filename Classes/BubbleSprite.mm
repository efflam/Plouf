//
//  BubbleSprite.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 12/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "BubbleSprite.h"


@implementation BubbleSprite
@synthesize target;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        //[self setAnchorPoint:ccp(0,0.5)];
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [self convertTouchToNodeSpace:[touches anyObject]];
    
    float distance = ccpDistance(ccp(50,50), point);
    
    if(distance < 60)
    {    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bubbleTouch" object:self];
    }
}

-(void)dealloc
{
    [target release];
    [super dealloc];
}

@end
