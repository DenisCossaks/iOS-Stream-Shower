//
//  SteamyBikiniAppDelegate.m
//  SteamyBikini
//
//  Created by Robert on 8/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SteamyBikiniAppDelegate.h"
#import "GLFunViewController.h"

@implementation SteamyBikiniAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	

    
    if ([UIScreen mainScreen].bounds.size.height >= 568) {
        self.bIPHONE5 = TRUE;
        NSLog(@"IPhone 5 : TRUE");
    }
    else {
        self.bIPHONE5 = FALSE;
        NSLog(@"IPhone 5 : FALSE");
    }
    
	// Override point for customization after app launch	
//    [window addSubview: viewController.view];
    self.window.rootViewController = self.viewController;
	[window makeKeyAndVisible];
    
}

- (void)dealloc {
    [viewController release];
	[window release];
	[super dealloc];
    
    
}

@end
