//
//  MDSearchViewController.m
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import "MDSearchViewController.h"

@interface MDSearchViewController ()

@end

@implementation MDSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.title = NSLocalizedString(@"Search", @"First");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
