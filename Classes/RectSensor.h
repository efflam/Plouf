//
//  RectSensor.h
//  ProtoMesh2
//
//  Created by Efflam on 16/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "CorridorView.h"    

@interface RectSensor:Actor 
{
    //@private
    b2Body *body;
    b2BodyDef *bodyDef;
    b2PolygonShape *shapeDef;
    b2FixtureDef *fixtureDef;
}


#pragma mark Physics Properties

@property (nonatomic, assign) b2Body *body;

@property (nonatomic, assign) b2BodyDef *bodyDef;

@property (nonatomic, assign) b2PolygonShape *shapeDef;

@property (nonatomic, assign) b2FixtureDef *fixtureDef;



@property (nonatomic, assign) CGPoint position;


@property (nonatomic, assign) CGFloat rotation;


- (id)initFrom:(CGPoint)a to:(CGPoint)b;
+(id)rectSensorFrom:(CGPoint)a to:(CGPoint)b;



@end
