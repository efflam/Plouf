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

@interface CorridorView : CCNode<CCStandardTouchDelegate>
{
    b2World* world;
	GLESDebugDraw *debugDraw;
    BOOL moveToFinger;
    CGPoint fingerPos;

}

@property(nonatomic, assign) BOOL moveToFinger;
@property(nonatomic, assign) CGPoint fingerPos;

-(id)initWithLevelName:(NSString*)levelName;
+(id)corridorWithName:(NSString*)levelName;

/*
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity;
*/

@end
