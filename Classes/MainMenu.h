//
//  MainMenu.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 25/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "Loader.h"
#import "EnvironmentMenu.h"

@interface MainMenu : CCNode {
    Loader *loader;
}
@property(nonatomic,retain)Loader *loader;

+(id)scene;

@end
