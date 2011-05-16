//
//  Camera.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 11/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Camera.h"

@implementation Camera

@synthesize delegate, position;

-(void)setPosition:(CGPoint)position
{
    self.currentPosition = position;
    
    NSLog(@"CameraPosition");
    
    [self.delegate setPosition:self.position];
}

-(void)dealloc
{
    [delegate release];
    [super dealloc];
}

@end
