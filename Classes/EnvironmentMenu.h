//
//  EnvironmentMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelMenu.h"

@interface EnvironmentMenu : CCNode <CCStandardTouchDelegate> {
    NSMutableArray *environments ;
    CGPoint diff ;
    float pageWidth;
    
    float desiredX;
    CCNode *bubblesHolder;
    int currentBubbleIndex;
    CGPoint origin;
    BOOL changed;
    BOOL moved;
    
    CCSprite *backButton;
    
    CCLabelBMFont *currentLegend;
    NSArray *legendes;
}

@property(nonatomic, retain) NSArray *legendes;
@property(nonatomic, retain) CCLabelBMFont *currentLegend;
@property(nonatomic, retain) CCSprite *backButton;
@property(nonatomic,retain) NSMutableArray *environments;
@property(nonatomic, retain) CCNode *bubblesHolder;
@property(readwrite, assign) int currentBubbleIndex;
@property(nonatomic, assign) CGPoint origin;
@property(readwrite, assign) BOOL changed;
@property(readwrite, assign) BOOL moved;

@end
