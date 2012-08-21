//
//  RootViewController.h
//  Lists
//
//  Created by Ethan Reesor on 9/27/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface RootViewController : UITableViewController {
	IBOutlet DatabaseManager *dbmgr;
	NSArray *tables;
}

@end
