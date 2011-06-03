//
//  RockFall.m
//  ProtoMesh2
//
//  Created by Efflam on 17/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "RockFall.h"

@implementation RockFall

@synthesize emissionPoint;
@synthesize frequency;
@synthesize timer;
@synthesize maxRocks;
@synthesize rocks;
@synthesize emitting;
@synthesize delegate;

- (void)dealloc
{
    NSLog(@"dealloc rockFall");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer release];
    [delegate release];
    [rocks release];
	[super dealloc];
}

- (id)initWithDelegate:(id)del
{
	self = [super init];
    if(self)
    {
        self.delegate = del;
        
        [self setMaxRocks:60];
        [self setFrequency:0.1f];
        [self setRocks:[NSMutableArray array]];
        
        CCTexture2D *texCailloux = [[CCTextureCache sharedTextureCache] addImage:@"cailloux.png"];
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithTexture:texCailloux capacity:[self maxRocks]];
		[[self delegate] addChild:batch z:0 tag:999];
        self.emitting = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopEmission) name:@"pauseLevel" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destroyRockHandler:) name:@"destroyRock" object:nil];

    }
	return self;
}

-(void)destroyRockHandler:(NSNotification *)notification
{
    Rock *rock = (Rock *) [notification object];
    if(rock)
        [self destroyRock:rock];
}

-(void)destroyRock:(Rock *)rock
{
    if(rock && [[self rocks] containsObject:rock])
    {
        [delegate removeActor:rock];
        [rocks removeObject:rock];
    }
}

+(id)rockFallWithDelegate:(id)del
{
    return [[[RockFall alloc] initWithDelegate:del] autorelease];
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
        [self destroyRock:rock];
    }
    
    Rock *newRock;
    
    newRock = [[Rock alloc] init];
    [newRock setPosition:p];
    [delegate addActor:newRock];
    [rocks addObject:newRock];
    [newRock release];
}


@end
