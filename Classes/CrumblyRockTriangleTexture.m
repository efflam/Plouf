//
//  CrumblyRockTriangleTexture.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 24/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "CrumblyRockTriangleTexture.h"


@implementation CrumblyRockTriangleTexture
@synthesize image;

-(id)initWithPoints:(float*)pts
{
    self = [super init];
    
    if(self)
    {
        for(int i = 0; i < 6; i+=2)
        {
            ptts[i/2] = ccp(pts[i],pts[i+1]);
            
            //NSLog(@"Point ROCK : %@",NSStringFromCGPoint(ptts[i/2]));
            
            tex[i/2] = ccp(pts[i]/64,pts[i+1]/64);
            self.image = [[CCTextureCache sharedTextureCache] addImage:@"motifRoche.png"];
        }
    }
    
    return self;
}

+(id)nodeWithPoints:(float *)pts
{
    return [[[CrumblyRockTriangleTexture alloc] initWithPoints:pts] autorelease];
}

-(void)enableTexture
{    
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	GLuint texture[1];
	glGenTextures(1, &texture[0]);
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    GLuint width = 64;
    GLuint height = 64;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
//    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
	
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
    CGContextRelease(context);
	
    free(imageData);
}

-(void)draw
{
//    [self enableTexture];
    
    //glPushMatrix();
	//glTranslatef(0, 0, 0);
    
//	glEnable(GL_LINE_SMOOTH);
    //glShadeModel(GL_LINE_SMOOTH);
	glBindTexture(GL_TEXTURE_2D, self.image.name);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	
    glVertexPointer(2, GL_FLOAT, 0, ptts);
	glTexCoordPointer(2, GL_FLOAT, 0, tex);
    
	glDrawArrays(GL_TRIANGLES, 0, 3);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
	//glEnableClientState(GL_COLOR_ARRAY);
    
    /*
    glTexCoordPointer(2, GL_FLOAT, 0, tex);
    glVertexPointer(2, GL_FLOAT, 0, ptts);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
     */
    
    //glPopMatrix();
    
    //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
