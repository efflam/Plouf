//
//  RockFallSensor.m
//  ProtoMesh2
//
//  Created by Efflam on 23/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "RockFallSensor.h"
#import "Fish.h"

@implementation RockFallSensor

@synthesize rockFall;
@synthesize coins;

- (id)initFor:(RockFall *) aRockFall from:(CGPoint)a to:(CGPoint)b
{
	self = [super initFrom:a to:b];
    if(self)
    {
        self.rockFall = aRockFall;
        self.coins = 0;
    }
	return self;
}

+(id)rockFallSensorFor:(RockFall *) aRockFall from:(CGPoint)a to:(CGPoint)b
{
    return [[[RockFallSensor alloc] initFor:aRockFall from:a to:b] autorelease];
}

- (void)addContact:(Actor *)aContact
{
    [super addContact:aContact];
    if( [aContact isKindOfClass:[Fish class]])
    {
        coins++;
        if(coins == 1)
        {
            [[self rockFall] startEmission];
        }
        
        CCLOG(@"coins = %d", coins);
    }
}
         
         
- (void)removeContact:(Actor *)aContact   
{
    [super removeContact:aContact];
    
    if( [aContact isKindOfClass:[Fish class]])
    {
        coins--;
        if(coins == 0)
        {
            [[self rockFall] stopEmission];
        }
        
        CCLOG(@"coins = %d", coins);
    }
}



-(void)dealloc
{
    [rockFall release];
    [super dealloc];
}




@end
