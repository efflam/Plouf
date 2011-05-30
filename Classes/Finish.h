//
//  Finish.h
//  ProtoMesh2
//
//  Created by Efflam on 30/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RectSensor.h"
#import "BubbleView.h"
#import "BubbleSprite.h"

@interface Finish : RectSensor  <BubbleTrackable>
{
    CGPoint bubblePoint;
    BubbleSprite *bubbleSprite;
    BOOL visible;
}


@property(nonatomic,retain) BubbleSprite *bubbleSprite;
@property(readwrite,assign) CGPoint bubblePoint;
@property(readwrite, assign) BOOL visible;

- (id)initFrom:(CGPoint)a to:(CGPoint)b;
+(id)finishFrom:(CGPoint)a to:(CGPoint)b;


@end
