//
//  SteamyBikiniAppDelegate.h
//  SteamyBikini
//
//  Created by Robert on 8/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import <UIKit/UIKit.h>

@class GLFunViewController;

@interface SteamyBikiniAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet GLFunViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) GLFunViewController *viewController;

@property (nonatomic, assign) BOOL bIPHONE5;


@end
