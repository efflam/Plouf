//
//  Fish.h
//  ProtoMesh2
//
//  Created by Efflam on 19/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "FishAnimated.h"
#import "Camera.h"
#import "BubbleView.h"
#import "BubbleSprite.h"
#import "Box2D.h"
#import "Actor.h"
#import "CorridorView.h"

@protocol FishDelegate;

@interface Fish:Actor <CCStandardTouchDelegate,BubbleTrackable>
{
    id <FishDelegate> delegate;
    b2Body *body;
    b2BodyDef *bodyDef;
    b2CircleShape *shapeDef;
    b2FixtureDef *fixtureDef;
    FishAnimated *sprite;
    CGPoint bubblePoint;
    BubbleSprite *bubbleSprite;
    NSString *name;
    BOOL spriteLinked;
    CCSprite *parcel;
    BOOL shipping;
}

@property (readwrite, assign) b2Body *body;
@property (readwrite, assign) b2BodyDef *bodyDef;
@property (readwrite, assign) b2CircleShape *shapeDef;
@property (readwrite, assign) b2FixtureDef *fixtureDef;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, retain) NSString *name;
@property(readwrite, assign) BOOL spriteLinked;
@property(nonatomic, retain) CCSprite *parcel;
@property (nonatomic, retain) FishAnimated *sprite;
@property(nonatomic,retain) BubbleSprite *bubbleSprite;
@property(readwrite,assign) CGPoint bubblePoint;
@property(nonatomic,retain) id <FishDelegate> delegate;
@property(readwrite,assign) BOOL shipping;

-(id)initWithFishName:(NSString*)fishName andPosition:(CGPoint)position;
+(id)fishWithName:(NSString*)fishName andPosition:(CGPoint)position;
- (BOOL)containsTouchLocation:(UITouch *)touch;
-(void)swimTo:(CGPoint)destination;
-(void)hit;
-(void)ship;
-(void)unship;

@end

@protocol FishDelegate <NSObject>

-(void)setSelectedFish:(Fish*)fish;

@end
