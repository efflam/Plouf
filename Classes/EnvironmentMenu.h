//
//  EnvironmentMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface EnvironmentMenu : CCNode <CCStandardTouchDelegate> {
    NSMutableArray *environments ;
    CGPoint diff ;
    float pageWidth;
    
    float desiredX;
}

@property(nonatomic,retain) NSMutableArray *environments;

@end
