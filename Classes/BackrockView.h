//
//  SVGNode.h
//  Proto4
//
//  Created by Clément RUCHETON on 02/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "nanosvg.h"
#import "tesselator.h"
#import "globals.h"

struct RockMemPool
{
	unsigned char* buf;
	unsigned int cap;
	unsigned int size;
};

@interface BackrockView : CCNode
{	
//	struct SVGPath* svgLevel;
	int nbVertices;
    		
//	int i,j;
    
//    struct CGPoint* verti;
    int nbPoints;
	
//	float t;
	TESSalloc ma;
	TESStesselator* tess;
	int nvp;
	struct RockMemPool pool;
	unsigned char mem[1024*512];
    
    struct CGPoint* verticesFixed;    
    int counterFixed;
	
}

+(id)backrockWithName:(NSString *)levelName;
-(id)initWithLevelName:(NSString *)levelName;
-(void)fixedArrays;

@end