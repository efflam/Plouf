//
//  CrumblyRockTriangleTexture.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CrumblyRockTriangleTexture : CCNode 
{
    struct CGPoint ptts[3];
    struct CGPoint tex[3];
    CCTexture2D *image;
}
@property(nonatomic,retain) CCTexture2D *image;

-(id)initWithPoints:(float*)pts;
+(id)nodeWithPoints:(float*)pts;
-(void)enableTexture;

@end
