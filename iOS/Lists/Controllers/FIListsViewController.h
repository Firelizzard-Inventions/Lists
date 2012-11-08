//
//  FIListsViewController.h
//  Lists
//
//  Created by Ethan Reesor on 10/4/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FITableViewController.h"

@interface FIListsViewController : FITableViewController <FIDataControllerListener> {
	NSIndexPath * selected;
	NSArray * entries;
	
	BOOL updating;
}

@property (strong) NSNumber * parent;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButtonItem;


@end

@interface FIListsViewController (Internal)

- (NSDictionary *)entryForIndex:(NSIndexPath *)indexPath;

@end