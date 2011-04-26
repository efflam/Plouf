//
//  CorridorView.m
//  ProtoSV-GL
//
//  Created by Efflam on 26/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "CorridorView.h"


@implementation CorridorView

-(id)initWithLevelName:(NSString*)levelName
{
    self = [super init];
    
    if(self)
    {   
        
    }
    
    return self;
}

+(id)corridorWithName:(NSString*)levelName
{
    return [[[CorridorView alloc] initWithLevelName:levelName] autorelease];
}

@end
