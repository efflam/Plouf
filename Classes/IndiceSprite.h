//
//  IndiceSprite.h
//  ProtoMesh2
//
//  Created by Efflam on 02/06/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface IndiceSprite : CCSprite <CCStandardTouchDelegate> 
{
    NSString *indiceDescription;
}

@property(nonatomic, retain) NSString *indiceDescription;

-(id)initWithTexture:(CCTexture2D *)texture andDescription:(NSString *)description;
+(id)indiceSpriteWithTexture:(CCTexture2D *)texture andDescription:(NSString *)description;

-(void)explode;

-(void)onExploded;



@end
