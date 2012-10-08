//
//  FIEditGroupController.m
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIEditGroupController.h"

#import "FIGroupsViewController.h"

@implementation FIEditGroupController

@synthesize group, parent, nameField, parentLabel;

#pragma mark - Lifecycle Methods

- (void)setup
{
	[super setup];
	_internal = [[NSLock alloc] init];
}

#pragma mark - Action Methods

- (void)done:(id)sender
{
	if (nameField.text) {
		[self updateName];
		[self updateParent];
	}
	if (self.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - Database Methods

- (void)updateName
{
	[model execute:@"UPDATE _t_group SET group_name='%@' WHERE group_id=%@", nameField.text, group];
}

- (void)updateParent
{
	if (parent == nil || [parent isNull])
		[model execute:@"UPDATE _t_group SET parent=NULL WHERE group_id=%@", group];
	else
		[model execute:@"UPDATE _t_group SET parent=%@ WHERE group_id=%@", parent, group];
}

#pragma mark Accessor Methods

- (NSNumber *)parent
{
	[_internal lock];
	id result = self.parent;
	[_internal unlock];
	return result;
}

- (void)setParent:(NSNumber *)theParent
{
	[_internal lock];
	parent = theParent;
	[_internal unlock];
}

#pragma mark - View Controller Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([FIListsEditGroupParentSegue isEqualToString:[segue identifier]]) {
		FIGroupsViewController * nextController = [segue destinationViewController];
		nextController.previousController = self;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	NSDictionary * entry;
	
	if (parent != nil && ![parent isNull]) {
		entry = [[model columns:@"*" ofEntriesOfType:FIEntryTypeAll withID:parent andParent:nil where:@"type='group'" and:nil] objectAtIndexOrNil:0];
		if ([model validateEntry:entry]) {
			[self setParent:nil];
			parentLabel.text = nil;
		} else {
			parentLabel.text = [entry objectForKey:FIEntryKeyName];
		}
	}
	
	entry = [[model columns:@"*" ofEntriesOfType:FIEntryTypeAll withID:group andParent:nil where:@"type='group'" and:nil] objectAtIndexOrNil:0];
	if (group == nil || [group isNull] || [model validateEntry:entry]) {
		nameField.text = nil;
		[model execute:@"INSERT INTO _t_group (group_name) VALUES ('_temp')"];
		group = [[[model execute:@"SELECT group_id AS id FROM _t_group WHERE group_name='_temp'"] objectAtIndexOrNil:0] objectForKey:@"id"];
	} else {
		nameField.text = [entry objectForKey:FIEntryKeyName];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[model execute:@"DELETE FROM _t_group WHERE group_name='_temp'"];
	group = parent = nil;
	nameField.text = parentLabel.text = nil;
}

@end
