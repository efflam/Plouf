//
//  Rock.h
//  ProtoMesh2
//
//  Created by Efflam on 16/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Box2D.h"
#import "cocos2d.h"  

@interface Rock:Actor 
{
    b2Body *body;
    b2BodyDef *bodyDef;
    b2CircleShape *shapeDef;
    b2FixtureDef *fixtureDef;
    CCSprite *rockSprite;
}


#pragma mark Physics Properties

@property (readwrite, assign) b2Body *body;
@property (readwrite, assign) b2BodyDef *bodyDef;
@property (readwrite, assign) b2CircleShape *shapeDef;
@property (readwrite, assign) b2FixtureDef *fixtureDef;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat rotation;
- (void)setPosition:(CGPoint)aPosition;
-(void)destroy;


#pragma mark View Properties

@property (nonatomic, retain) CCSprite *rockSprite;
    


@end
