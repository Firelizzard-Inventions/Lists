//
//  FIAddEntryController.m
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIAddEntryController.h"

#import "FIEditGroupController.h"

@implementation FIAddEntryController

@synthesize parent;

#pragma mark - Action Methods

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View Controller Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([FIListsAddGroupSegue isEqualToString:[segue identifier]]) {
		FIEditGroupController * nextController = [segue destinationViewController];
		nextController.parent = parent;
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	parent = nil;
}

@end
