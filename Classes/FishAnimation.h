//
//  FishAnimation.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FishAnimation : CCSprite {
    BOOL listen;
}
@property(readwrite,assign) BOOL listen;

+(id) fishWithName:(NSString*)name andOption:(NSString*)option;
-(id) initWithFishName:(NSString*)name andOption:(NSString*)option;

@end
