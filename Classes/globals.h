//
//  config.h
//  oStruch
//
//  Created by Clément RUCHETON on 15/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

extern float MAP_WIDTH;
extern float MAP_HEIGHT;
extern int PTM_RATIO;
extern float CAM_RADIUS;
extern CGPoint SCREEN_CENTER;

#define SCREEN_TO_WORLD(n) ((n) / PTM_RATIO)
#define WORLD_TO_SCREEN(n) ((n) * PTM_RATIO)

#define DEGREES_TO_RADIANS(n) ((n) * (b2_pi / 180.0f))
#define RADIANS_TO_DEGREES(n) ((n) * (180.0f / b2_pi))
