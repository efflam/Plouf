//
//  LandscapeView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 18/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LandscapeView.h"

@implementation LandscapeView

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        [self setAnchorPoint:ccp(0,0)];
        
        CCSprite *level1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-1.png",levelName]];
        CCSprite *level2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-2.png",levelName]];
        CCSprite *level3 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-3.png",levelName]];
        CCSprite *level4 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-4.png",levelName]];
                
        [level1 setAnchorPoint:ccp(0,0)];
        [level2 setAnchorPoint:ccp(0,0)];
        [level3 setAnchorPoint:ccp(0,0)];
        [level4 setAnchorPoint:ccp(0,0)];
        
        [level1 setPosition:ccp(0,MAP_HEIGHT/2)];
        [level2 setPosition:ccp(MAP_WIDTH/2,MAP_HEIGHT/2)];
        [level3 setPosition:ccp(MAP_WIDTH/2,0)];
        [level4 setPosition:ccp(0,0)];
        
        [self addChild:level1];
        [self addChild:level2];
        [self addChild:level3];
        [self addChild:level4];
        
        /*
        
        level = levelName;
        
        for(int i = 0 ; i < 16 ; i++)
        {
            for(int j = 0; j < 16 ; j++)
            {
                hasChild[i][j] = NO;
            }
        }
        
        lastTilePosition.x = roundf(4000 - ([[Camera standardCamera] position].x + 2000)/256);
        lastTilePosition.y = roundf(4000 - ([[Camera standardCamera] position].y + 2000)/256);
        
        positions = [[NSMutableArray alloc] init];
        
        [self scheduleUpdate];
         
        */
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    tilePosition.x = fmaxf((roundf(([[Camera standardCamera] position].x + 2000)/256)-3),0);
    tilePosition.y = fmaxf((roundf(([[Camera standardCamera] position].y + 2000)/256)-3),0);
    
    if(!ccpFuzzyEqual(tilePosition, lastTilePosition, 0))
    {
        NSLog(@"Different !");
        
        for(int i = tilePosition.x ; i < tilePosition.x + 6 ; i ++)
        {
            for(int j = tilePosition.y ; j < tilePosition.y + 6 ; j++)
            {
                if(!hasChild[i][j])
                {
                    [[CCTextureCache sharedTextureCache] addImageAsync:[NSString stringWithFormat:@"%@_%d_%d.png",level,i,j] target:self selector:@selector(addSprite:)];
                    
                    [positions addObject:[NSValue valueWithCGPoint:ccp(i*256,(15-j)*256)]];
                    
                    hasChild[i][j] = YES;
                    
                }
            }
        }
        
        lastTilePosition = tilePosition;
    }
}

-(void)addSprite:(CCTexture2D*)tex
{
    CCSprite *tile = [CCSprite spriteWithTexture:tex];
    [tile setAnchorPoint:ccp(0,0)];
    [tile setPosition:[[positions objectAtIndex:0] CGPointValue]];
    [positions removeObjectAtIndex:0];
    [self addChild:tile];
}

+(id)landscapeWithName:(NSString*)levelName
{
    return [[[LandscapeView alloc] initWithLevelName:levelName] autorelease];
}

@end
