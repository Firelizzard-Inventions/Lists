//
//  FIGroupsViewController.h
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FITableViewController.h"

@interface FIGroupsViewController : FITableViewController <FIDataControllerListener> {
	NSIndexPath * selected;
	NSArray * entries;
}

@property (strong) NSNumber * parent;
@property (strong) FITableViewController * previousController;

- (IBAction)done:(id)sender;

@end
