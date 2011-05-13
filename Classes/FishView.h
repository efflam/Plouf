//
//  FishView.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 04/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "FishAnimated.h"
#import "Camera.h"
#import "BubbleView.h"
#import "BubbleSprite.h"

@protocol FishViewDelegate;
@interface FishView : CCNode <CCStandardTouchDelegate,BubbleTrackable> {
    id <FishViewDelegate> delegate ;
    FishAnimated *fishSprite;
    struct b2Body *fishBody;
    struct b2World *world;
    
    CGPoint bubblePoint;
    BubbleSprite *bubbleSprite;
}

@property(nonatomic,retain) BubbleSprite *bubbleSprite;
@property(readwrite,assign) CGPoint bubblePoint;
@property(nonatomic,retain) id <FishViewDelegate> delegate;
@property(nonatomic,retain) FishAnimated *fishSprite;
@property(readwrite,assign) struct b2Body *fishBody;
@property(readwrite,assign) struct b2World *world;

-(id)initWithFishName:(NSString*)fishName andWorld:(struct b2World*)aWorld andPosition:(CGPoint)position;
+(id)fishWithName:(NSString*)fishName andWorld:(struct b2World*)aWorld andPosition:(CGPoint)position;
- (BOOL)containsTouchLocation:(UITouch *)touch;

@end

@protocol FishViewDelegate <NSObject>

-(void)setSelectedFish:(FishView*)fish;

@end
