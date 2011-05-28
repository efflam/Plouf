//
//  PauseMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 28/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PauseMenu : CCSprite {
    CCMenuItemImage *soundButton;
    CCMenu *menu;
    CCSprite *background;
    BOOL soundOn;
}
@property(nonatomic,retain)CCMenuItemImage *soundButton;
@property(nonatomic,retain)CCMenu *menu;
@property(nonatomic,retain)CCSprite *background;
@property(readwrite,assign)BOOL soundOn;

-(void)pause:(BOOL)p;

@end
