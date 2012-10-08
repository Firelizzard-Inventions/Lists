//
//  FIAllViewController.m
//  Lists
//
//  Created by Ethan Reesor on 10/8/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIAllViewController.h"

@implementation FIAllViewController

#pragma mark - Lifecycle Methods

- (void)setup
{
	[super setup];
	groups = [model execute:@"SELECT * FROM _t_all WHERE type='group' ORDER BY name ASC"];
	lists = [model execute:@"SELECT * FROM _t_all WHERE type='list' ORDER BY name ASC"];
}

#pragma mark - Internal Methods

- (NSDictionary *)entryForIndex:(NSIndexPath *)indexPath
{
	if ([indexPath indexAtPosition:0] == 0) {
		return [groups objectAtIndexOrNil:[indexPath indexAtPosition:1]];
	} else if ([indexPath indexAtPosition:0] == 1) {
		return [lists objectAtIndexOrNil:[indexPath indexAtPosition:1]];
	} else {
		return [NSDictionary dictionaryWithObject:[[NSNumber numberWithInteger:FIViewEmptySectionError] stringValue] forKey:@"error"];
	}
}

#pragma mark - Datasource Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Groups";
	} else if (section == 1) {
		return @"Tables";
	} else {
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [groups count];
	} else if (section == 1) {
		return [lists count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView cellForEntry:[self entryForIndex:indexPath]];
}

@end
