//
//  AppDelegate.m
//  Karma
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "AppDelegate.h"
#import "AWSMobileClient.h"
#import "AWSCore.h"
#import "KarmaListManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotification:[NSNotification notificationWithName:@"appDidEnterForeground" object:nil]];
}


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[AWSDDLog addLogger:AWSDDTTYLogger.sharedInstance];
	[AWSDDLog sharedInstance].logLevel = AWSDDLogLevelInfo;
	
	[[FBSDKApplicationDelegate sharedInstance] application:application
							 didFinishLaunchingWithOptions:launchOptions];
	return [[AWSMobileClient sharedInstance] interceptApplication:application didFinishLaunchingWithOptions:launchOptions];
}



- (BOOL)application:(UIApplication *)application
			openURL:(NSURL *)url
			options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
	
	BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
																  openURL:url
														sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
															   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
					];
	// Add any custom logic here.
	return handled;
}

@end
