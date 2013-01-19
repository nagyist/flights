//
//  MDFirstViewController.m
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import "MDHomeViewController.h"

@interface MDHomeViewController ()

@end

@implementation MDHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.title = NSLocalizedString(@"Home", @"First");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}


@end
