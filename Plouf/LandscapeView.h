//
//  LandscapeView.h
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 18/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"

@interface LandscapeView : CCNode {
    
}

-(id)initWithLevelName:(NSString*)levelName;
+(id)landscapeWithName:(NSString*)levelName;

@end
