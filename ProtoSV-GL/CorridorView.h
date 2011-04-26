//
//  CorridorView.h
//  ProtoSV-GL
//
//  Created by Efflam on 26/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CorridorView : CCNode {
    
}

-(id)initWithLevelName:(NSString*)levelName;
+(id)corridorWithName:(NSString*)levelName;

@end
