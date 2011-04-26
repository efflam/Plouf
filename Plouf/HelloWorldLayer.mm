//
//  HelloWorldLayer.mm
//  Plouf
//
//  Created by Efflam on 26/04/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "LevelView.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	[scene addChild: [LevelView levelWithName:@"level1"]];
	
	// return the scene
	return scene;
}

/*
-(void) draw
{
    
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
     
}
 */




- (void) dealloc
{
    [super dealloc];
}
@end
