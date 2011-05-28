//
//  Loader.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 25/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Loader : CCNode {
    CCScene *playScene;
    CCMenuItemImage *playButton;
}

@property(nonatomic,retain) CCScene *playScene;
@property(nonatomic,retain) CCMenuItemImage *playButton;

+(id)scene;

@end
