//
//  CrumblyRock.m
//  ProtoMesh2
//
//  Created by Efflam on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "CrumblyRock.h"
#import "globals.h"
#import "CrumblyRockTriangle.h"

@implementation CrumblyRock

@synthesize game;

- (id)initWithGame:(CorridorView *) aGame andSVGPaths:(SVGPath **)aPaths numPaths:(int)aNumPaths bmin:(float *)bmin bmax:(float *)bmax
{
	self = [super init];
    if(self)
    {
        self.game = aGame;
        
        for(int i = 0; i < aNumPaths; i++)
        {
            float *pts = new float [aPaths[i]->npts * 2];
            storePath(pts, aPaths[i]->pts, aPaths[i]->npts, 1, bmin, bmax);
            CrumblyRockTriangle *tri = [CrumblyRockTriangle crumblyRockTriangle:pts];
            [game addActor:tri];
        }
        
    }
	return self;
}

+(id)crumblyRockWithGame:(CorridorView *) aGame andSVGPaths:(SVGPath **)aPaths numPaths:(int)aNumPaths bmin:(float *)bmin bmax:(float *)bmax
{
    return [[[CrumblyRock alloc] initWithGame:aGame andSVGPaths:aPaths numPaths:aNumPaths bmin:bmin bmax:bmax] autorelease];
}




@end
