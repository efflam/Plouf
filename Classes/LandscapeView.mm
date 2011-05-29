//
//  LandscapeView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 18/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LandscapeView.h"

@implementation LandscapeView
@synthesize tiles;

-(void)dealloc
{
    [tiles release];
    [super dealloc];
}

-(void)onExit
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        [self setAnchorPoint:ccp(0,0)];
        
        NSString *path = [CCFileUtils fullPathFromRelativePath:[NSString stringWithFormat:@"%@.plist",levelName]];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *blanks = [dict objectForKey:@"blackTiles"];
        
        self.tiles = [NSMutableArray arrayWithCapacity:64];
        
        CCTexture2D *blankTex = [[CCTextureCache sharedTextureCache] addImage:@"blank.png"];
        
        
        for(int i = 0 ; i < 8 ; i++)
        {
            for(int j = 0; j < 8 ; j++)
            {
                NSString *tileNumber = [NSString stringWithFormat:@"%d_%d",i,j];
                BOOL blank = NO;
                
                for (uint k = 0 ; k < [blanks count]; k++) 
                {                    
                    if([tileNumber isEqualToString:[blanks objectAtIndex:k]])
                    {
                        blank = YES;
                    }
                }
                
                CCSprite *tile;
                
                if(blank) tile = [CCSprite spriteWithTexture:blankTex];
                else tile = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_%@.png",levelName,tileNumber]];
                
                [tile setVisible:NO];
                [tile setAnchorPoint:ccp(0,0)];
                [tile setPosition:ccp(512*i,(512*(7-j))-96)];
                [self addChild:tile];
                [self.tiles addObject:tile];
            }
        }
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    CGPoint visibleScreen = CGPointMake(2000-([[Camera standardCamera] position].x), 2000-([[Camera standardCamera] position].y));
    
    uint count = [self.tiles count];
    
    for(uint i = 0 ; i < count;i++)
    {
        CCSprite *tile = [tiles objectAtIndex:i];
        
        if (tile.position.x < visibleScreen.x + SCREEN_CENTER.x*2 && tile.position.x + 512 > visibleScreen.x &&
               tile.position.y < visibleScreen.y + SCREEN_CENTER.y*2 && tile.position.y + 512 > visibleScreen.y) 
        {
            tile.visible = YES;
        }
        else tile.visible = NO;
    }
}

+(id)landscapeWithName:(NSString*)levelName
{
    return [[[LandscapeView alloc] initWithLevelName:levelName] autorelease];
}

@end
