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
    NSMutableArray *tiles;
}
@property(nonatomic,retain) NSMutableArray *tiles;

-(id)initWithLevelName:(NSString*)levelName;
+(id)landscapeWithName:(NSString*)levelName;
-(void)update:(ccTime)dt;

@end
