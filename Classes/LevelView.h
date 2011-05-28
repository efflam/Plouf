//
//  LevelView.h
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 19/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BubbleView.h"

@interface LevelView : CCNode {
    CCMenu *menu;
}
@property(nonatomic,retain)CCMenu *menu;

-(id)initWithLevelName:(NSString*)levelName;
+(id)levelWithName:(NSString*)levelName;

@end
