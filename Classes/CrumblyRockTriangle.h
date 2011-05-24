//
//  CrumblyRockTriangle.h
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Box2D.h"


@interface CrumblyRockTriangle : Actor
{
    b2Body *body;
    b2BodyDef *bodyDef;
    b2PolygonShape *shapeDef;
    b2FixtureDef *fixtureDef;
    float *points;
}

@property (readwrite, assign) b2Body *body;
@property (readwrite, assign) b2BodyDef *bodyDef;
@property (readwrite, assign) b2PolygonShape *shapeDef;
@property (readwrite, assign) b2FixtureDef *fixtureDef;
@property (nonatomic, assign) float *points;


+(id)crumblyRockTriangle:(float *)aPts;
- (id)init:(float *)pts;
-(void)destroy;



@end
