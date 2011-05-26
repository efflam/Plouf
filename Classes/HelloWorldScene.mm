//
//  HelloWorldScene.mm
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "HelloWorldScene.h"
//#import "LevelView.h"
#import "MainMenu.h"

@implementation HelloWorld
//@synthesize image;

+(id) scene
{
	CCScene *scene = [CCScene node];
//	[scene addChild: [LevelView levelWithName:@"level1"]];
	[scene addChild: [MainMenu scene]];
//    [scene addChild:[HelloWorld node]];
            
	return scene;
}

/*
-(id) init
{
	if( (self=[super init] )) {
        
		self.image = [[CCTextureCache sharedTextureCache] addImage: @"motifRoche.png"];
	}
	return self;
}*/

/*
- (void) draw {
	GLfloat PointVertices[6] = {0.0f, 320.0f, 0.0f, 0.0f, 480.0f, 160.0f};
	GLfloat PointTexture[6];
	for (int j = 0; j < 6; j++) {
		PointTexture[j] = PointVertices[j] * (1.0f/self.image.pixelsWide);
	}
	//GLfloat PointTexture[6] =  {0.0f, 0.0f, 0.0f, 320.0f, 480.0f, 160.0f};
    
	glEnable(GL_LINE_SMOOTH);
	glBindTexture(GL_TEXTURE_2D, self.image.name);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	glVertexPointer(2, GL_FLOAT, 0, PointVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, PointTexture);
    
	glDrawArrays(GL_TRIANGLES, 0, 3);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
	glEnableClientState(GL_COLOR_ARRAY);
    
    [super draw];
}
 */

@end
