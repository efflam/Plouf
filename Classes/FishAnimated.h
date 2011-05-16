//
//  FishAnimated.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 10/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FishAnimation.h"

@interface FishAnimated : CCNode {
    CCSprite *eyes;
    FishAnimation *eye;
}
@property(nonatomic,retain) FishAnimation *eye;

+(id) fishWithName:(NSString*)name;
-(id) initWithFishName:(NSString*)name;
-(void) setFlipX:(BOOL)flip;

@end
