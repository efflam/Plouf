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
    
    float distance = ccpDistance(ccp(0,0), point);
    
    NSLog(@"clicked : %f",distance);
    
    if(distance < 100)
    {    
        NSLog(@"touched ? Fuck Me !");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bubbleTouch" object:self];
    }
}

@end
