//
//  LandscapeView.h
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 18/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "Camera.h"

@interface LandscapeView : CCNode {
    BOOL hasChild[16][16];
    CGPoint tilePosition;
    CGPoint lastTilePosition;
    NSString *level;
    NSMutableArray *positions;
}

-(id)initWithLevelName:(NSString*)levelName;
+(id)landscapeWithName:(NSString*)levelName;

@end
