//
//  PauseMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 28/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PauseMenu : CCNode {
    CCMenuItemImage *soundButton;
    CCMenu *menu;
    BOOL soundOn;
}
@property(nonatomic,retain)CCMenuItemImage *soundButton;
@property(nonatomic,retain)CCMenu *menu;
@property(readwrite,assign)BOOL soundOn;

@end
