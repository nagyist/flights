//
//  MDAppDelegate.h
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
