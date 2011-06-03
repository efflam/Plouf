//
//  LoseMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"

@interface LoseMenu : CCNode {
    CCSprite *parcel;
}

@property(nonatomic,retain) CCSprite *parcel;
-(void) setOpacity: (GLubyte) opacity;

@end
