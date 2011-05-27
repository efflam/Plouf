//
//  GameLayer.h
//  Proto4
//
//  Created by Clément RUCHETON on 01/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "Camera.h"
#import "LandscapeView.h"
#import "CorridorView.h"
#import "BackrockView.h"

@interface ScrollLevelView : CCParallaxNode <CCStandardTouchDelegate, CameraDelegate>
{
//	SVGNode *mapSVG;
	/*
	CGSize mapSize;
	CGSize winSize;
	float scaleMin;
    	
	BOOL isScrolling;
	BOOL isScaling;
	
	CGPoint inertiaVector;
	CGPoint touchOffset;
	
	float delta;
    */
    
    BackrockView *rocks;
    LandscapeView *landscape;
    CorridorView *corridor;
}

@property(nonatomic,retain)BackrockView *rocks;
@property(nonatomic,retain)LandscapeView *landscape;
@property(nonatomic,retain)CorridorView *corridor;

/*
@property(readwrite, assign) CGSize mapSize;
@property(readwrite, assign) CGSize winSize;
@property(readwrite, assign) float scaleMin;
@property(readwrite, assign) BOOL isScrolling;
@property(readwrite, assign) BOOL isScaling;
*/

//-(void)handlePinch:(NSSet *)touches withEvent:(UIEvent *)event;
-(id)initWithLevelName:(NSString*)levelName;
+(id)levelWithName:(NSString*)levelName;

@end
