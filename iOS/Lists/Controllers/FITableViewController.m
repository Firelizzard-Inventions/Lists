//
//  FIViewController.m
//  Lists
//
//  Created by Ethan Reesor on 10/5/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FITableViewController.h"

@implementation FITableViewController

#pragma mark - Lifecycle Methods

- (id)init
{
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	
	self = [super initWithStyle:style];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	model = [FIDataController defaultController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	[model ensureClose];
}

#pragma mark - Internal Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForError:(NSString *)error
{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FIListsErrorUIElem];
	cell.textLabel.text = @"Error";
	cell.textLabel.textColor = [UIColor redColor];
	cell.detailTextLabel.text = error;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForEntry:(NSDictionary *)entry
{
	UITableViewCell *cell;
	
	NSString * error = [model validateEntry:entry];
	
	if (error) {
		return [self tableView:tableView cellForError:error];
	}
	
	NSString * name = [entry objectForKey:FIEntryKeyName];
	NSString * type = [entry objectForKey:FIEntryKeyType];
	
	if ([FIEntryTypeGroup isEqualToString:type])
		cell = [tableView dequeueReusableCellWithIdentifier:FIListsGroupUIElem];
	else if ([FIEntryTypeList isEqualToString:type])
		cell = [tableView dequeueReusableCellWithIdentifier:FIListsListUIElem];
	
	cell.textLabel.text = name;
	
	return cell;
}

#pragma mark - Datasource Methods

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 // Return the number of sections.
 return 0;
 }
 */

/*
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 // Return the number of rows in the section.
 return 0;
 }
 */

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"Cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Delegate Methods

/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here. Create and push another view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 // ...
 // Pass the selected object to the new view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

@end
