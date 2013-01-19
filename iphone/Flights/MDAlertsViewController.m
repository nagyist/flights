//
//  MDSecondViewController.m
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import "MDAlertsViewController.h"

@interface MDAlertsViewController ()

@end

@implementation MDAlertsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Alerts", @"Second");
		self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
