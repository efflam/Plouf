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
#import "nanosvg.h"
#import "navmesh.h"
#import "globals.h"
#import "FishView.h"

static const float AGENT_RAD = 20.0f;
static const int MAX_NAV_AGENTS = 16;

struct NavScene
{
	float* boundary;
	int nboundary;
	float* walkable;
    float* edge;
    int nedge;
	int nwalkable;
	NavmeshAgent agents[MAX_NAV_AGENTS];
	int nagents;
	Navmesh* nav;
	float dim[2];
};

@protocol CorridorViewDelegate;
@interface CorridorView : CCNode<CCStandardTouchDelegate,FishViewDelegate>
{
    id <CorridorViewDelegate> delegate;
    
    b2World* world;
	GLESDebugDraw *debugDraw;
    BOOL moveToFinger;
    CGPoint fingerPos;
    NavScene navScene;
    NSMutableArray *fishes;
    FishView *currentFish;
}



@property(nonatomic, retain) id <CorridorViewDelegate> delegate;
@property(nonatomic, assign) BOOL moveToFinger;
@property(nonatomic, assign) CGPoint fingerPos;
@property(nonatomic, assign) NavScene navScene;

+(id)corridorWithName:(NSString *)levelName;
-(id)initWithLevelName:(NSString *)levelName;
-(SVGPath*)loadMesh:(NSString*)levelName;
-(void)initMesh:(NSString*)levelName;
-(void)initPhysics;
-(void)initCorridor:(float *)vertices count:(int)count;
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity;
-(void)drawNavMesh;
-(CGPoint)convertVertToCGPoint:(float*)v;
-(void)setSelectedFish:(FishView *)fish;

@end

@protocol CorridorViewDelegate <NSObject>

-(CGPoint)position;
-(void)setPosition:(CGPoint)newPosition;

@end
