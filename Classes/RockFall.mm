//
//  RockFall.m
//  ProtoMesh2
//
//  Created by Efflam on 17/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "RockFall.h"
#import "Rock.h"
#import "CorridorView.h"

@implementation RockFall

@synthesize emissionPoint;
@synthesize game;
@synthesize frequency;
@synthesize timer;
@synthesize maxRocks;
@synthesize rocks;
@synthesize emitting;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer release];
    [game release];
    [rocks release];
	[super dealloc];
}

- (id)initWithGame:(CorridorView *)aGame
{
	self = [super init];
    if(self)
    {
		[self setGame:aGame];
        [self setMaxRocks:60];
        [self setFrequency:0.1f];
        [self setRocks:[NSMutableArray array]];
        
        CCTexture2D *texCailloux = [[CCTextureCache sharedTextureCache] addImage:@"cailloux.png"];
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithTexture:texCailloux capacity:[self maxRocks]];
		[[self game] addChild:batch z:0 tag:999];
        self.emitting = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopEmission) name:@"pauseLevel" object:nil];
    }
	return self;
}

+(id)rockFallWithGame:(CorridorView *)aGame
{
    return [[[RockFall alloc] initWithGame:aGame] autorelease];
}

-(void)startEmission
{
    if(self.emitting) return;
    [self setTimer:[NSTimer scheduledTimerWithTimeInterval:([self frequency]) target:self selector:@selector(onTimer) userInfo:nil repeats:YES]];
    self.emitting = YES;
}


-(void)stopEmission
{
    if(!self.emitting) return;
    [self setTimer:nil];
    self.emitting = NO;
}

-(void)toggleEmission
{
    self.emitting ? [self stopEmission] : [self startEmission];
}

-(void)setTimer:(NSTimer *)aTimer 
{
	if(timer != aTimer) 
    {
		[timer invalidate];
		[timer release];
		timer = [aTimer retain];
	}
}

- (void)onTimer 
{
    CGPoint offset = ccp(rand() %100 - 50.0f, rand() % 20 - 10.0f);
	[self emitRockAt:ccpAdd(emissionPoint, offset)];
}

-(void)emitRockAt:(CGPoint)p
{
    //CCLOG(@"%d", [[self rocks] count] );
    
    
    if([[self rocks] count] >= [self maxRocks])
    {
        Rock *rock = [rocks objectAtIndex:0];
        [game removeActor:rock];
        [rocks removeObject:rock];
    }
    
    Rock *newRock;
    
    newRock = [[Rock alloc] init];
    [newRock setPosition:p];
    [game addActor:newRock];
    [rocks addObject:newRock];
    [newRock release];
}


@end
