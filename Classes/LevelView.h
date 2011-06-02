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
#import "PauseMenu.h"
#import "ScrollLevelView.h"
#import "Loader.h"
#import "LevelMenu.h"
#import "Camera.h"
#import "BubbleView.h"

@interface LevelView : CCNode {
    CCMenu *menu;
    PauseMenu *pause;
    ScrollLevelView *scrollView;
    BubbleView *bubbleView;
    CCLabelBMFont *indice;
    CCSprite *stripeName;
    CCLabelBMFont *fishName;
    CCLabelBMFont *timer;
    int secondTimer;
}
@property(nonatomic,retain)CCLabelBMFont *timer;
@property(nonatomic,retain)CCLabelBMFont *fishName;
@property(nonatomic,retain)CCSprite *stripeName;
@property(nonatomic,retain)CCLabelBMFont *indice;
@property(nonatomic,retain)BubbleView *bubbleView;
@property(nonatomic,retain)ScrollLevelView *scrollView;
@property(nonatomic,retain)CCMenu *menu;
@property(nonatomic,retain)PauseMenu *pause;

-(id)initWithLevelName:(NSString*)levelName;
+(id)levelWithName:(NSString*)levelName;
-(void)update:(ccTime)dt;
-(void)showName:(NSNotification*)notification;
-(void)winHandler:(NSNotification*)notification;
-(void)looseHandler:(NSNotification*)notification;
-(void)updateTimer:(ccTime)dt;

@end
