//
//  CorridorView.h
//  ProtoSV-GL
//
//  Created by Efflam on 26/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Navscene.h"

@interface CorridorView : CCNode<CCStandardTouchDelegate>
{
    b2World* world;
	GLESDebugDraw *debugDraw;
    BOOL moveToFinger;
    CGPoint fingerPos;
    b2Body* fish;
    NavScene navScene;
}

@property(nonatomic, assign) BOOL moveToFinger;
@property(nonatomic, assign) CGPoint fingerPos;
@property(nonatomic, assign) b2Body* fish;
@property(nonatomic, assign) b2World* world;
@property(nonatomic, assign) NavScene navScene;

+(id)corridorWithName:(NSString*)levelName;
-(id)initWithLevelName:(NSString*)levelName;
-(void)initNavMeshWithName:(NSString*)levelName;
-(void)initPhysics;
-(void)initCorridor:(float *)points count:(int)count;
-(void)initFishWithFile:(NSString *)file x:(float)x y:(float)y;
-(void)createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
-(void)counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity;
-(void)addNewSpriteWithCoords:(CGPoint)p;


@end
