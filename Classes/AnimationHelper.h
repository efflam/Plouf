//
//  AnimationHelper.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimationHelper : CCSprite {
    BOOL listen;
    CCAction *action;
}
@property(readwrite,assign) BOOL listen;
@property(nonatomic,retain) CCAction* action;

//+(CCAnimate*) animateWithName:(NSString*)name option:(NSString*)option frameNumber:(int)frameNumber;
+(id) animationWithName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber;
-(id) initWithAnimationName:(NSString*)name andOption:(NSString*)option frameNumber:(int)frameNumber;

@end
