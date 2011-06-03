//
//  AnimationHelper.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol AnimationHelperDelegate;
@interface AnimationHelper : CCSprite {
    id <AnimationHelperDelegate> delegate;
    BOOL listen;
    CCAction *action;
}
@property(nonatomic,retain) id <AnimationHelperDelegate> delegate;
@property(readwrite,assign) BOOL listen;
@property(nonatomic,retain) CCAction* action;

//+(CCAnimate*) animateWithName:(NSString*)name option:(NSString*)option frameNumber:(int)frameNumber;
+(id) animationWithName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber;
-(id) initWithAnimationName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber;

@end

@protocol AnimationHelperDelegate <NSObject>

-(void)animationComplete;

@end
