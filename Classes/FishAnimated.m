//
//  FishAnimated.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "FishAnimated.h"


@implementation FishAnimated
@synthesize eye;

+(id) fishWithName:(NSString*)name
{
    return [[[FishAnimated alloc] initWithFishName:name] autorelease];
}

-(id) initWithFishName:(NSString*)name
{
    self = [super init];
    
    if(self)
    {
        self.eye = [FishAnimation fishWithName:name andOption:@"Eye"];        
        
        [self addChild:[FishAnimation fishWithName:name andOption:@""] z:0 tag:0];
        [self addChild:self.eye z:1 tag:1];
        
        [(FishAnimation*)[self getChildByTag:0] setListen:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEyes) name:@"animationComplete" object:nil];
    }
    
    return self;
}

-(void)changeEyes
{
    int rd = rand() % 100 ;
    if(rd > 75)
    {
        self.eye.visible = NO;
    }
    else
    {
        self.eye.visible = YES;
    }
}

-(void) setFlipX:(BOOL)flip
{
    for (uint i = 0; i < [[self children] count]; i++) 
    {
        [[[self children] objectAtIndex:i] setFlipX:flip];
    }
}

@end
