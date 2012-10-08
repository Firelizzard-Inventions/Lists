//
//  FIEditListController.h
//  Lists
//
//  Created by Ethan Reesor on 10/8/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FITableViewController.h"

@interface FIEditListController : FITableViewController

@property (weak, nonatomic) IBOutlet UITextField * nameField;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray * tableLabels;

- (IBAction)done:(id)sender;

@end
