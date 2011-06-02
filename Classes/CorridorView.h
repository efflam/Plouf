//
//  Level.h
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RockFall.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "nanosvg.h"
#import "navmesh.h"
#import "globals.h"
#import "Fish.h"
#import "Camera.h"
#import "MyContactListener.h"
#import "Murene.h"
#import "Parcel.h"


@class Fish;
@class RockFall;

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

@protocol FishDelegate;
@interface CorridorView : CCNode <CCStandardTouchDelegate,FishDelegate,RockFallDelegate>
{    
    b2World *world;
	GLESDebugDraw *debugDraw;
    BOOL moveToFinger;
    CGPoint fingerPos;
    CGPoint previousCamPos;
    NavScene navScene;
    NSMutableArray *fishes;
    Fish *currentFish;
    Fish *shippingFish;
    NSMutableSet *actorSet;
	b2ContactListener *contactListener;
    BOOL travelling;
    Murene *murene;
    Parcel *parcel;
    RockFall *fall;
    Actor *currentActor;
    
    BOOL hasBubbleTouch;
}

@property(nonatomic, retain) RockFall *fall;
@property(nonatomic, assign) BOOL moveToFinger;
@property(nonatomic, assign) CGPoint fingerPos;
@property(nonatomic, assign) NavScene navScene;
@property (nonatomic, retain) NSMutableSet *actorSet;
@property (nonatomic, readwrite) b2ContactListener *contactListener;
@property (nonatomic, assign) b2World *world;
@property(nonatomic, retain) Murene *murene;
@property(nonatomic, retain) Parcel *parcel;
@property(readwrite, assign) int numIndices;
@property(readwrite, assign) int numSacrifices;

+(id)corridorWithName:(NSString *)levelName;
-(id)initWithLevelName:(NSString *)levelName;
-(SVGPath*)loadMesh:(NSString*)levelName;
-(void)initMesh:(NSString*)levelName;
-(void)initPhysics;
-(void)initCorridor:(float *)vertices count:(int)count;
//-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) createEdge:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
-(void) counterGravity:(b2Body*)body antiGravity:(b2Vec2)antiGravity;
//-(void)drawNavMesh;
-(CGPoint)convertVertToCGPoint:(float*)v;
-(void)setSelectedFish:(Fish *)fish;
-(void)setShippingFish:(Fish *)fish;
-(CGPoint)convertToScreenCenter:(CGPoint)point;
-(void)mureneEat;
-(void)removeActorHandler:(NSNotification*)notification;
-(void)update:(ccTime)dt;
-(void)giveParcelHandler:(NSNotification*)notification;
-(void)fishOnFinish;
-(void)win;
-(CGPoint)currentFishPosition;
-(Fish*)getCurrentFish;

-(void)indiceTouchedHandler;

#pragma mark Actor Methods

-(void)addActor:(Actor *)anActor;
-(void)removeActor:(Actor *)anActor;
-(void)removeAllActors;
-(void)fishEatenByMurene;

-(void)removeFish:(Fish *)aFish;

-(void)loose;
@end
