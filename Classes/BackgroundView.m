//
//  BackgroundView.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 28/04/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "BackgroundView.h"


@implementation BackgroundView

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {
        [self setAnchorPoint:ccp(0,0)];
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-background.png",levelName]];
        [background setAnchorPoint:ccp(0,0)];
        //[background setColor:ccc3(255.0, 255.0, 0.0)];
        [self addChild:background];
    }
    
    return self;
}

+(id)backgroundWithName:(NSString*)levelName
{
    return [[[BackgroundView alloc] initWithLevelName:levelName] autorelease];
}

@end
