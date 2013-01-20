//
//  MDFirstViewController.h
//  Flights
//
//  Created by Max Desyatov on 19/01/13.
//  Copyright (c) 2013 Max Desyatov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CouchUITableSource, CouchDatabase, CouchPersistentReplication;

@interface MDHomeViewController : UIViewController <UITableViewDelegate>
{
    CouchPersistentReplication *_pull;
    CouchPersistentReplication *_push;
}

@property (strong, nonatomic) IBOutlet CouchUITableSource *dataSource;
@property (strong, nonatomic) CouchDatabase *database;

-(void)useDatabase:(CouchDatabase*)theDatabase;

@end
