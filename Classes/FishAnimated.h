//
//  FishAnimated.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AnimationHelper.h"

@interface FishAnimated : CCNode {
    AnimationHelper *body;
    AnimationHelper *eye;
    AnimationHelper *hit;
    
    BOOL listen;
    
    BOOL wound;
}

@property(nonatomic,assign) BOOL listen;

@property(nonatomic,assign) BOOL wound;
@property(nonatomic,retain) AnimationHelper *eye;
@property(nonatomic,retain) AnimationHelper *hit;
@property(nonatomic,retain) AnimationHelper *body;

+(id) fishWithName:(NSString*)name;
-(id) initWithFishName:(NSString*)name;
-(void) setFlipX:(BOOL)flip;
-(void)changeEyes;
-(void)punch;

@end
