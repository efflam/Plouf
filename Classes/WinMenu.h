//
//  WinMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"

@interface WinMenu : CCNode {
    NSMutableArray *animatedObjects;
}
@property(nonatomic,retain) NSMutableArray *animatedObjects;

-(id)initWithTime:(int)t sacrifices:(int)s indices:(int)i;
+(id)winWithTime:(int)t sacrifices:(int)s indices:(int)i;
-(void)loopAnimation;

@end
