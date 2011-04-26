//
//  AppDelegate.h
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 22/03/11.
//  Copyright Gobelins 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
