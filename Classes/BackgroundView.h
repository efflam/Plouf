//
//  BackgroundView.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 28/04/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BackgroundView : CCNode {
    
}

-(id)initWithLevelName:(NSString*)levelName;
+(id)backgroundWithName:(NSString*)levelName;

@end
