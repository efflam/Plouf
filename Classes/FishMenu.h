//
//  FishMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"

@interface FishMenu : CCNode <CCStandardTouchDelegate> {
    CCSprite *image1;
    CCSprite *image2;
    
    BOOL turned;
    BOOL isTurning;
}

@property(nonatomic,assign) BOOL isTurning;
@property(nonatomic,assign) BOOL turned;
@property(nonatomic,retain) CCSprite *image1;
@property(nonatomic,retain) CCSprite *image2;

-(void)loopAnimation;

@end
