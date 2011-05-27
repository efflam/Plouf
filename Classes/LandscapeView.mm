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

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        [self setAnchorPoint:ccp(0,0)];
        
        /*
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
         */
        
        /*
        
        level = levelName;
        */
        
        
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
                    //NSLog(@"blanks : %@",[blanks objectAtIndex:k]);
                    
                    if([tileNumber isEqualToString:[blanks objectAtIndex:k]])
                    {
                        //NSLog(@"Nop : %@",tileNumber);
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
        
        
        //lastTilePosition.x = roundf(4000 - ([[Camera standardCamera] position].x + 2000)/512);
        //lastTilePosition.y = roundf(4000 - ([[Camera standardCamera] position].y + 2000)/512);
        
        
        //positions = [[NSMutableArray alloc] init];
        
        //[self scheduleUpdate];
    }
    
    return self;
}


//-(void)update:(ccTime)dt
-(void)update:(ccTime)dt
{
    CGPoint visibleScreen = CGPointMake(2000-([[Camera standardCamera] position].x), 2000-([[Camera standardCamera] position].y));
    
    //NSLog(@"Rect Tile : %@",NSStringFromCGRect(visibleScreen));
    
    
    uint count = [self.tiles count];
//    int j = 0;
    
    for(uint i = 0 ; i < count;i++)
    {
        CCSprite *tile = [tiles objectAtIndex:i];
        
        if (tile.position.x < visibleScreen.x + SCREEN_CENTER.x*2 && tile.position.x + 512 > visibleScreen.x &&
               tile.position.y < visibleScreen.y + SCREEN_CENTER.y*2 && tile.position.y + 512 > visibleScreen.y) 
        {
            tile.visible = YES;
//            j++;
        }
        else tile.visible = NO;
    }
    
//    [super draw];
    
//    NSLog(@"tiles : %i",j);
    
    //tilePosition.x = fmaxf((roundf(([[Camera standardCamera] position].x + 2000)/512)-2),0);
    //tilePosition.y = fmaxf((roundf(([[Camera standardCamera] position].y + 2000)/512)-2),0);
    
    /*
    for(int i = tilePosition.x ; i < tilePosition.x + 2 ; i++)
    {

    }
     */
}

/*
-(void)addSprite:(CCTexture2D*)tex
{
    CCSprite *tile = [CCSprite spriteWithTexture:tex];
    [tile setAnchorPoint:ccp(0,0)];
    [tile setPosition:[[positions objectAtIndex:0] CGPointValue]];
    [positions removeObjectAtIndex:0];
    [self addChild:tile];
}
*/
+(id)landscapeWithName:(NSString*)levelName
{
    return [[[LandscapeView alloc] initWithLevelName:levelName] autorelease];
}

@end
