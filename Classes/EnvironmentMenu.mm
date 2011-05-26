//
//  EnvironmentMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "EnvironmentMenu.h"
#import "globals.h"

@implementation EnvironmentMenu
@synthesize environments;

- (id)init 
{
    self = [super init];
    
    if (self) 
    {
        [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        [self setAnchorPoint:ccp(0,0)];
        
        self.environments = [NSMutableArray arrayWithCapacity:4];
        
        [environments addObject:[CCSprite spriteWithFile:@"tropicEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"oceanEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"arcticEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"abyssalEnvironment.png"]];
        
        
        pageWidth = 512;
        
        for(int i = 0 ; i < 4 ; i++)
        {
            CCSprite *bubble = [environments objectAtIndex:i];
            [bubble setAnchorPoint:ccp(0,0)];
            [bubble setPosition:ccp(i*SCREEN_CENTER.x,0)];
            [self addChild:bubble];
        }
    }
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{        
    [self unscheduleUpdate];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    int currentBubble = max(0,min(round(-self.position.x / 512),3));
    int desiredBubbleIndex = currentBubble + (diff.x >= 0) ? -1 : 1;
    
    desiredX = desiredBubbleIndex * 512;
    
    //NSLog(@"currentBubble : %d / desiredBubbleIndex : %d / desiredX : %f",currentBubble,desiredBubbleIndex,desiredX);
    
    //[self scheduleUpdate];
}
/*
-(void)update:(ccTime)dt
{
    
    
    float newPos = self.position.x + (desiredX - self.position.x) * .1;
    
    float diffPos = fabsf(desiredX - newPos);
    
    if(diffPos > 1)
    {
        [self setPosition:ccp(newPos,self.position.y)];
    }
    else
    {
        [self unscheduleUpdate];
    }
     
}*/

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    CGPoint prevLocation = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:[touch view]]];
    CGPoint newTouch = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    diff = ccpSub(prevLocation, newTouch);
    diff.y = self.position.y;
    
    [self setPosition:ccpSub(self.position, diff)];
    
    NSLog(@"%@",NSStringFromCGPoint(self.position));
    NSLog(@"current bubble : %f",max(0,min(round(-self.position.x / 512),3)));
}

@end
