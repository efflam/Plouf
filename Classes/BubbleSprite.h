//
//  BubbleSprite.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 12/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BubbleSprite : CCSprite <CCStandardTouchDelegate> {
    CCNode *target;
}
@property(nonatomic,retain) CCNode *target;

@end
