//
//  FIListsViewController.m
//  Lists
//
//  Created by Ethan Reesor on 10/4/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIListsViewController.h"

#import "FIEditGroupController.h"
#import "FIAddEntryController.h"

@implementation FIListsViewController

@synthesize parent;

#pragma mark - Lifecycle Methods

- (void)setup
{
	[super setup];
	updating = NO;
	[model addListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	entries = [model entriesOfType:FIEntryTypeAll withParent:parent];
}

#pragma mark - Internal Methods

- (NSDictionary *)entryForIndex:(NSIndexPath *)indexPath
{
	if ([indexPath indexAtPosition:0] == 0) {
		if ([indexPath length] > 2) {
			return [model entryOfType:FIEntryTypeAll forIndex:indexPath withParent:parent];
		} else {
			return [entries objectAtIndexOrNil:[indexPath indexAtPosition:1]];
		}
	} else {
		return [NSDictionary dictionaryWithObject:[[NSNumber numberWithInteger:FIViewEmptySectionError] stringValue] forKey:@"error"];
	}
}

#pragma mark - View Controller Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	if (editing) {
		[super setEditing:editing animated:animated];
		self.navigationItem.rightBarButtonItem = self.addButtonItem;
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	} else {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.navigationItem.leftBarButtonItem = nil;
		[super setEditing:editing animated:animated];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	if (updating) {
		entries = [model entriesOfType:FIEntryTypeAll withParent:parent];
		[self.tableView endUpdates];
		updating = NO;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSDictionary * entry = [model entryOfType:FIEntryTypeAll forIndex:selected withParent:parent];
	NSString * error = [model validateEntry:entry];
	
	if ([FIListsOpenGroupSegue isEqualToString:segue.identifier]) {
		FIListsViewController * nextController = segue.destinationViewController;
		
		if (error == nil || [error isNull]) {
			nextController.parent = [entry objectForKey:FIEntryKeyID];
			nextController.title = [entry objectForKey:FIEntryKeyName];
		} else {
			nextController.parent = [NSNumber numberWithInteger:-1];
			nextController.title = @"Error";
			nextController.navigationItem.prompt = error;
		}
	} else if ([FIListsEditGroupSegue isEqualToString:segue.identifier]) {
		FIEditGroupController * nextController = segue.destinationViewController;
		
		if (error == nil || [error isNull]) {
			nextController.group = [entry objectForKey:FIEntryKeyID];
			nextController.title = [entry objectForKey:FIEntryKeyName];
			nextController.parent = parent;
		} else {
			nextController.group = [NSNumber numberWithInteger:-1];
			nextController.title = @"Error";
			nextController.navigationItem.prompt = error;
		}
		
		updating = YES;
		[self.tableView beginUpdates];
	} else if ([FIListsAddSegue isEqualToString:segue.identifier]) {
		UINavigationController * navController = segue.destinationViewController;
		FIAddEntryController * nextController = [navController.viewControllers objectAtIndex:0];
		nextController.parent = parent;
		
		updating = YES;
		[self.tableView endUpdates];
	}
}

#pragma mark - Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	selected = indexPath;
	if (self.editing) {
		NSDictionary * entry = [self entryForIndex:indexPath];
		if ([FIEntryTypeGroup isEqualToString:[entry objectForKey:FIEntryKeyType]]) {
			[self performSegueWithIdentifier:FIListsEditGroupSegue sender:nil];
		} else if ([FIEntryTypeList isEqualToString:[entry objectForKey:FIEntryKeyType]]) {
			[self performSegueWithIdentifier:FIListsEditListSegue sender:nil];
		}
	}
	return selected;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (self.editing) {
		NSDictionary * entry = [self entryForIndex:(selected = indexPath)];
		if ([FIEntryTypeGroup isEqualToString:[entry objectForKey:FIEntryKeyType]]) {
			[self performSegueWithIdentifier:FIListsEditGroupSegue sender:nil];
		} else if ([FIEntryTypeList isEqualToString:[entry objectForKey:FIEntryKeyType]]) {
			[self performSegueWithIdentifier:FIListsEditListSegue sender:nil];
		}
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary * entry = [model entryOfType:FIEntryTypeAll forIndex:indexPath withParent:parent];
	
	if ([model validateEntry:entry]) {
		return UITableViewCellEditingStyleNone;
	} else {
		return UITableViewCellEditingStyleDelete;
	}
}

#pragma mark - Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [entries count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView cellForEntry:[self entryForIndex:indexPath]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary * entry = [self entryForIndex:indexPath];
	NSString * error = [model validateEntry:entry];
	if (error == nil || [error isNull]) {
		NSString * type = [entry objectForKey:FIEntryKeyType];
		if ([FIEntryTypeGroup isEqualToString:type]) {
			[model execute:@"DELETE FROM _t_group WHERE group_id=%@", [entry objectForKey:FIEntryKeyID]];
		} else if ([FIEntryTypeList isEqualToString:type]) {
			[model execute:@"DELETE FROM _t_list WHERE list_id=%@", [entry objectForKey:FIEntryKeyID]];
		}
		[self refreshControl];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([model validateEntry:[self entryForIndex:indexPath]]) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Database Listener Methods
- (void)executedChange:(NSString *)query onTable:(NSString *)table
{
	if (([@"_t_group" isEqualToString:table] || [@"_t_list" isEqualToString:table]) && !updating) {
		entries = [model entriesOfType:FIEntryTypeAll withParent:parent];
		[self.tableView reloadData];
	}
}

@end
