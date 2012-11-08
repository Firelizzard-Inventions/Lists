//
//  FIGroupsViewController.m
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIGroupsViewController.h"

#import "FIEditGroupController.h"

@implementation FIGroupsViewController

@synthesize parent, previousController;

#pragma mark - Lifecycle Methods

- (void)setup
{
	[super setup];
	[model addListener:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
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

#pragma mark - Action Methods

- (IBAction)done:(id)sender {
	NSDictionary * entry = [self entryForIndex:selected];
	if ([previousController isKindOfClass:[FIEditGroupController class]]) {
		((FIEditGroupController *)previousController).parent = [entry objectForKey:FIEntryKeyID];
	}
	[self.navigationController popToViewController:previousController animated:YES];
}

#pragma mark - View Controller Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSDictionary * entry = [self entryForIndex:selected];
	NSNumber * error = [model validateEntry:entry];
	
	if ([FIListsOpenGroupSegue isEqualToString:[segue identifier]]) {
		FIGroupsViewController * nextController = [segue destinationViewController];
		
		if (error == nil || [error isNull]) {
			nextController.parent = [entry objectForKey:FIEntryKeyID];
			nextController.title = [entry objectForKey:FIEntryKeyName];
		} else {
			nextController.parent = [NSNumber numberWithInteger:-1];
			nextController.title = @"Error";
			nextController.navigationItem.prompt = [error stringValue];
		}
	}
}

#pragma mark - Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return selected = indexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
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

#pragma mark - Database Listener Methods
- (void)executedChange:(NSString *)query onTable:(NSString *)table
{
	if ([@"_t_group" isEqualToString:table]) {
		entries = [model entriesOfType:FIEntryTypeAll withParent:parent];
		[self.tableView reloadData];
	}
}

@end
