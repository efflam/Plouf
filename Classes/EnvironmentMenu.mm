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
@synthesize bubblesHolder;
@synthesize currentBubbleIndex;
@synthesize origin;
@synthesize changed, moved;
@synthesize backButton;

-(void)dealloc
{
    [bubblesHolder release];
    [environments release];
    [super dealloc];
}

-(void)onExit
{
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
}

-(void)onEnter
{
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
}

- (id)init 
{
    self = [super init];
    
    if (self) 
    {
        
        [self setAnchorPoint:ccp(0,0)];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"backgroundMenu.png"];
        [bg setAnchorPoint:ccp(0,0)];
        [self addChild:bg];
        
        self.environments = [NSMutableArray arrayWithCapacity:4];
        
        [environments addObject:[CCSprite spriteWithFile:@"tropicEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"oceanEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"arcticEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"abyssalEnvironment.png"]];
        
        self.origin = ccpSub(SCREEN_CENTER, ccp(256, 256));
        
        self.bubblesHolder = [CCNode node];
        [self addChild:self.bubblesHolder];
        [[self bubblesHolder] setPosition:origin];
        
        pageWidth = 650;
        
        for(int i = 0 ; i < 4 ; i++)
        {
            CCSprite *bubble = [environments objectAtIndex:i];
            [bubble setAnchorPoint:ccp(0,0)];
            [bubble setPosition:ccp(i*pageWidth,0)];
            [[self bubblesHolder] addChild:bubble];
        }
        
        self.currentBubbleIndex = 0;
        
        self.backButton = [CCSprite spriteWithFile:@"backButton.png"];
        
        //[menu setPosition:ccp(-SCREEN_CENTER.x,-SCREEN_CENTER.y)];
        
        [backButton setAnchorPoint:ccp(0.5,0.5)];
        [backButton setPosition:ccp(73,74)];
        
        [self addChild:backButton];

    }
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{        
    diff = ccp(0.0f, 0.0f);
    self.changed = NO;
    self.moved = NO;
    [self unscheduleUpdate];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if(!moved)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPos = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        CCSprite *item = [[bubblesHolder children] objectAtIndex:currentBubbleIndex];
        CGPoint itemPos = ccpAdd([bubblesHolder position], [item position]);
        itemPos = ccpAdd(itemPos, ccp(256,256));
                        
        float dist = ccpDistance(itemPos, touchPos);
            
        if(dist < 256.0)
        {
            NSLog(@"EnvironmentMenu");
            
            CCScene *scene = [CCScene node];
            LevelMenu *levelMenu = [LevelMenu node];
            
            [scene addChild:levelMenu];
            
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
            
            return;
        }
        
        dist = ccpDistance(touchPos, backButton.position);
        
        if(dist < 74.0)
        {
            [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5];
        }
        
        
    }
    
    float limit;
    if(self.changed)
        limit = 50.0f;
    else
        limit = 5.0f;

    if(fabs(diff.x) >= limit)
    {
        if(diff.x < 0)
        {
            self.currentBubbleIndex--;
        }
        else
        {
            self.currentBubbleIndex++;
        }       
    }
    self.currentBubbleIndex = max(0, min(3, self.currentBubbleIndex));
    
    desiredX = -self.currentBubbleIndex * 650 + origin.x;
    
   //NSLog(@"currentBubble : %d / desiredBubbleIndex : %d /diffX: %f / desiredX : %f",currentBubble,desiredBubbleIndex, diff.x, desiredX);
    
    [self scheduleUpdate];
        
    //[[self bubblesHolder]setPosition:ccp(desiredX,self.bubblesHolder.position.y)];
}

-(void)update:(ccTime)dt
{
    float newPos = self.bubblesHolder.position.x + (desiredX - self.bubblesHolder.position.x) * .1;
    
    float diffPos = fabsf(desiredX - newPos);
    
    if(diffPos > 1)
    {
        [[self bubblesHolder]setPosition:ccp(newPos,self.bubblesHolder.position.y)];
    }
    else
    {
        [self unscheduleUpdate];
    }
     
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moved = YES;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    CGPoint prevLocation = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:[touch view]]];
    CGPoint newTouch = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    diff = ccpSub(prevLocation, newTouch);
    //diff.y = self.bubblesHolder.position.y;
    
    CGPoint pos = ccpSub(self.bubblesHolder.position, diff);
    pos.y =  self.bubblesHolder.position.y;
    
    
    [[self bubblesHolder] setPosition:pos];
    
    int newIndex = max(0,min(floor((origin.x-self.bubblesHolder.position.x + 256) / 650),3));

    if(self.currentBubbleIndex != newIndex)
    {
        self.currentBubbleIndex = newIndex;
        self.changed = YES;
    }
    
    //NSLog(@"%@",NSStringFromCGPoint(self.bubblesHolder.position));
    //NSLog(@"current bubble : %f",max(0,min(floor(-self.bubblesHolder.position.x / 650),3)));
}

@end
