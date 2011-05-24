//
//  HelloWorldScene.h
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"


// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	CCTexture2D *image;
}

@property(nonatomic,retain)CCTexture2D *image;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;



@end
