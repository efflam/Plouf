//
//  ProtoMesh2AppDelegate.h
//  ProtoMesh2
//
//  Created by Efflam on 01/03/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ProtoMesh2AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
