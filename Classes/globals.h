//
//  config.h
//  oStruch
//
//  Created by Clément RUCHETON on 15/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//
#import "mathutil.h"

extern float MAP_WIDTH;
extern float MAP_HEIGHT;
extern int PTM_RATIO;
extern float CAM_RADIUS;
extern CGPoint SCREEN_CENTER;

#define SCREEN_TO_WORLD(n) ((n) / PTM_RATIO)
#define WORLD_TO_SCREEN(n) ((n) * PTM_RATIO)

#define DEGREES_TO_RADIANS(n) ((n) * (b2_pi / 180.0f))
#define RADIANS_TO_DEGREES(n) ((n) * (180.0f / b2_pi))


static void reversePoly(float* poly, const int npoly)
{
	int i = 0;
	int j = npoly-1;
	while (i < j)
	{
		swap(poly[i*2+0], poly[j*2+0]);
		swap(poly[i*2+1], poly[j*2+1]);
		i++;
		--j;
	}
}

static void convertPoint(float* dst, const float* src,
						 const float s, const float* bmin, const float* bmax)
{
	dst[0] = (src[0] - bmin[0])*s;
	dst[1] = (bmax[1] - src[1])*s;
}

static void storePath(float* dst, const float* src, const int npts,
					  const float s, const float* bmin, const float* bmax)
{
	for (int i = 0; i < npts; ++i)
		convertPoint(&dst[i*2], &src[i*2], s, bmin, bmax);
	if (polyarea(dst, npts) < 0.0f)
		reversePoly(dst, npts);
}

