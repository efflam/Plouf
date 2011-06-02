//
//  IndiceSprite.m
//  ProtoMesh2
//
//  Created by Efflam on 02/06/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "IndiceSprite.h"


@implementation IndiceSprite

@synthesize indiceDescription;


-(void)dealloc
{
    [indiceDescription release];
    [super dealloc];
}

-(void)onExit
{
   [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(id)initWithTexture:(CCTexture2D *)texture andDescription:(NSString *)description
{
    self = [super initWithTexture:texture];
    if(self)
    {
        self.indiceDescription = description;
        [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
    }
    return self;
}

                
+(id)indiceSpriteWithTexture:(CCTexture2D *)texture andDescription:(NSString *)description
{
    return [[[IndiceSprite alloc]initWithTexture:texture andDescription:description] autorelease];
}


-(void)explode
{
    
    [self runAction:[CCFadeTo actionWithDuration:0.2 opacity:0]];
    [self runAction:[CCScaleTo actionWithDuration:0.2 scale:2]];
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.2],
                     [CCCallFunc actionWithTarget:self selector:@selector(onExploded)],
                     nil]];
}

-(void)onExploded
{
    [self removeFromParentAndCleanup:YES];
}
                

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [self convertTouchToNodeSpace:[touches anyObject]];
    
    float distance = ccpDistance(ccp(50,50), point);
    
    NSLog(@"indice clicked : %f",distance);
    
    if(distance < 60)
    {    
        NSLog(@"touched ? Fuck Me !");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"indiceTouched" object:self];
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        [self explode];
    }
}




@end
