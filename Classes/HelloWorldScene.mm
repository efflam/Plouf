//
//  HelloWorldScene.mm
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "HelloWorldScene.h"
#import "LevelView.h"

@implementation HelloWorld

+(id) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [LevelView levelWithName:@"level1"]];
        
	return scene;
}

@end
