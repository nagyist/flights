//
//  MDAppDelegate.m
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import "MDAppDelegate.h"

#import "MDHomeViewController.h"
#import "MDAlertsViewController.h"
#import "MDSearchViewController.h"
#import "MDSettingsViewController.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>

// The name of the database the app will use.
#define kDatabaseName @"flights"

@implementation MDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError* error;
    TDServer* tdServer = [[TDServer alloc] initWithDirectory:@"/tmp/touchdb_empty_app"
                                                        error:&error];
    NSAssert(tdServer, @"Couldn't create server: %@", error);
    [TDURLProtocol setServer:tdServer];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	UIViewController *viewController1 = [[MDHomeViewController alloc] initWithNibName:@"MDHomeViewController" bundle:nil];
	UIViewController *viewController2 = [[MDAlertsViewController alloc] initWithNibName:@"MDAlertsViewController" bundle:nil];
	UIViewController *viewController3 = [[MDSearchViewController alloc] initWithNibName:@"MDSearchViewController" bundle:nil];
	UIViewController *viewController4 = [[MDSettingsViewController alloc] initWithNibName:@"MDSettingsViewController" bundle:nil];
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[viewController1, viewController2, viewController3, viewController4];
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
