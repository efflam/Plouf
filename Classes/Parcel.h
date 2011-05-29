//
//  Parcel.h
//  ProtoMesh2
//
//  Created by Efflam on 29/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"

@interface Parcel : Actor
{
    b2Body *body;
    b2BodyDef *bodyDef;
    b2CircleShape *shapeDef;
    b2FixtureDef *fixtureDef;
    CCSprite *sprite;
}

@property (readwrite, assign) b2Body *body;
@property (readwrite, assign) b2BodyDef *bodyDef;
@property (readwrite, assign) b2CircleShape *shapeDef;
@property (readwrite, assign) b2FixtureDef *fixtureDef;
@property(nonatomic, retain) CCSprite *sprite;

+(id)parcelAtPosition:(CGPoint)aPosition;
- (id)initAtPosition:(CGPoint)aPosition;


@end
