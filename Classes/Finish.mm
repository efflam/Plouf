//
//  Finish.m
//  ProtoMesh2
//
//  Created by Efflam on 30/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Finish.h"
#import "globals.h"
#import "Camera.h"

@implementation Finish

@synthesize bubblePoint;
@synthesize bubbleSprite;
@synthesize visible;

- (id)initFrom:(CGPoint)a to:(CGPoint)b
{
	self = [super initFrom:a to:b];
    if(self)
    {
        self.visible = YES;
	}
	return self;
}

+(id)finishFrom:(CGPoint)a to:(CGPoint)b
{
    return [[[Finish alloc] initFrom:a to:b] autorelease];
}

-(void)dealloc
{
    [bubbleSprite setTarget:nil];
    [bubbleSprite release];
    [super dealloc];
}

- (void)actorDidAppear 
{	
	[super actorDidAppear];
    self.bubbleSprite = [BubbleSprite spriteWithFile:@"parcelBubble.png"];
    self.bubbleSprite.target = self;
}


- (void)actorWillDisappear 
{
    [self.bubbleSprite setTarget:nil];
	[super actorWillDisappear]; 
}


- (void)worldDidStep 
{
	[super worldDidStep];
    
    CGPoint posForLevel =self.position;    
    
    posForLevel.x = 2000 - posForLevel.x + SCREEN_CENTER.x;
    posForLevel.y = 2000 - posForLevel.y + SCREEN_CENTER.y;
    
    
    CGPoint posForCamera = ccpSub([[Camera standardCamera] position], posForLevel);
    float bubbleHalfSize = self.bubbleSprite.contentSize.width * 0.5;
    float bubblePadding = 13;
    float bubbleOffset = bubbleHalfSize - bubblePadding;
    
    if(fabsf(posForCamera.x) > SCREEN_CENTER.x || fabsf(posForCamera.y) > SCREEN_CENTER.y)
    {
        float angle = atan2f(posForCamera.y, posForCamera.x);
        
        CGPoint circlePoint = ccp(CAM_RADIUS*cosf(angle),CAM_RADIUS*sinf(angle));
        CGPoint bubblePointForCam = ccp(fminf(SCREEN_CENTER.x - bubbleOffset, fmaxf(-SCREEN_CENTER.x + bubbleOffset, circlePoint.x)),fminf(SCREEN_CENTER.y - bubbleOffset, fmaxf(-SCREEN_CENTER.y + bubbleOffset, circlePoint.y)));
        
        self.bubblePoint = ccp(SCREEN_CENTER.x + bubblePointForCam.x, SCREEN_CENTER.y + bubblePointForCam.y);
        
        if(self.visible) 
        {
            self.visible = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showMe" object:self];
        }
    }
    else if(!self.visible)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unTrackMe" object:self];
        self.visible = YES;
    }
}

- (CGPoint)position
{
	if([self body]) return ccp(WORLD_TO_SCREEN(body->GetPosition().x), WORLD_TO_SCREEN(body->GetPosition().y));
	else return ccp(WORLD_TO_SCREEN(bodyDef->position.x), WORLD_TO_SCREEN(bodyDef->position.y));
}



@end
