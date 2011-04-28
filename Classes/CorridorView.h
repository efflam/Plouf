//
//  Level.h
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    NavScene navScene;
}


@property(nonatomic, assign) BOOL moveToFinger;
@property(nonatomic, assign) CGPoint fingerPos;
@property(nonatomic, assign) NavScene navScene;

+(id)corridorWithName:(NSString *)levelName;
-(id)initWithLevelName:(NSString *)levelName;
-(void)initNavMesh:(NSString*)levelName;
-(void)initPhysics;
-(void)initCorridor:(float *)vertices count:(int)count;
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity;
-(void) touchAtPosition:(CGPoint)point;
-(void) moveAtPosition:(CGPoint)point;

@end
