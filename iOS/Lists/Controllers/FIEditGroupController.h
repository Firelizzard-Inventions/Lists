//
//  FIEditGroupController.h
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FITableViewController.h"

@interface FIEditGroupController : FITableViewController {
	NSLock * _internal;
}

@property (strong) NSNumber * group, * parent;
@property (weak, nonatomic) IBOutlet UILabel * parentLabel;
@property (weak, nonatomic) IBOutlet UITextField * nameField;

- (IBAction)done:(id)sender;

@end
