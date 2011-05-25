//
//  Anemone.h
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "AnemoneAnimated.h"

@interface Anemone : Actor
{
    b2Body *body;
    b2BodyDef *bodyDef;
    b2PolygonShape *shapeDef;
    b2FixtureDef *fixtureDef;
    AnemoneAnimated *sprite;
    BOOL eaten;
}

@property (readwrite, assign) b2Body *body;
@property (readwrite, assign) b2BodyDef *bodyDef;
@property (readwrite, assign) b2PolygonShape *shapeDef;
@property (readwrite, assign) b2FixtureDef *fixtureDef;
@property(nonatomic, retain) AnemoneAnimated *sprite;
@property(readwrite, assign) BOOL eaten;

+(id)anemoneAtPosition:(CGPoint)aPosition andRotation:(float)aRotation;

- (id)initAtPosition:(CGPoint)aPosition andRotation:(float)aRotation;

-(void)ate;

@end
