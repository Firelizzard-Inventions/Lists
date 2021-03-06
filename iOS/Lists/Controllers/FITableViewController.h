//
//  FIViewController.h
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FIDataController.h"

@interface FITableViewController : UITableViewController {
	FIDataController * model;
}

- (void)setup;

@end

@interface FITableViewController (Internal)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForError:(NSNumber *)error;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForEntry:(NSDictionary *)entry;

@end