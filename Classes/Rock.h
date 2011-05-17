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
#import "CorridorView.h"    

@interface Rock:Actor 
{
    @private
        b2Body *body;
        b2BodyDef *bodyDef;
        b2CircleShape *shapeDef;
        b2FixtureDef *fixtureDef;
        CCSprite *rockSprite;
}


#pragma mark Physics Properties

@property (nonatomic, assign) b2Body *body;

@property (nonatomic, assign) b2BodyDef *bodyDef;

@property (nonatomic, assign) b2CircleShape *shapeDef;

@property (nonatomic, assign) b2FixtureDef *fixtureDef;



@property (nonatomic, assign) CGPoint position;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat rotation;


#pragma mark View Properties

@property (nonatomic, retain) CCSprite *rockSprite;
    


@end
