//
//  CrumblyRock.h
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "CorridorView.h"
#import "nanosvg.h"

@interface CrumblyRock : NSObject
{
    CorridorView *game;
}

@property(nonatomic, retain) CorridorView  *game;

- (id)initWithGame:(CorridorView *) aGame andSVGPaths:(SVGPath **)aPaths numPaths:(int)aNumPaths bmin:(float *)bmin bmax:(float *)bmax;

+(id)crumblyRockWithGame:(CorridorView *) aGame andSVGPaths:(SVGPath **)aPaths numPaths:(int)aNumPaths bmin:(float *)bmin bmax:(float *)bmax;

@end
