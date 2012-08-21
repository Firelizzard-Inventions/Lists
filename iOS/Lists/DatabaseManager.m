//
//  DatabaseManager.m
//  Lists
//
//  Created by Ethan Reesor on 9/24/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import "DatabaseManager.h"
#import "SQLiteDB.h"

@implementation DatabaseManager

- (id)init
{
	self = [super init];
	
	if (self) {
		master = [[SQLiteDB alloc] initWithFile:[self masterDBPath]];
		
		NSFileManager *manager = [NSFileManager defaultManager];
		if (![manager fileExistsAtPath:[self masterDBPath]]) {
			int status = 0;
			const char *query;
			
			
			if (!status) status = [master open];
			if (!status) status = [master execute:"CREATE TABLE IF NOT EXISTS t_group (name TEXT PRIMARY KEY, parent TEXT, FOREIGN KEY (parent) REFERENCES t_group(name))"];
			if (!status) status = [master execute:"CREATE TABLE IF NOT EXISTS t_list (name TEXT PRIMARY KEY, parent TEXT, is_primary INTEGER, list_table TEXT, FOREIGN KEY (parent) REFERENCES t_group(name), FOREIGN KEY (list_table) REFERENCES sqlite_master(name))"];
			if (!status) status = [master close];
			NSLog(@"Status: %d", status);
		}
		[manager release];
		
		[master open];
	}
	
	return self;
}

#pragma mark Exit Methods

- (void)dealloc
{
	[master close];
	[super dealloc];
}

#pragma mark Master DB Methods

- (NSString *)masterDBPath
{
	static NSString *path;
	if (path == NULL) {
		NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		path = [[NSString alloc] initWithString:[dir stringByAppendingPathComponent:@"master.db"]];
	}
	return path;
}

- (int)executeQueryOnMasterDB:(const char *)query
{
	return [master execute:query];
}

- (int)executeQueryOnMasterDB:(const char *)query with:(void (^)(NSDictionary *))block
{
	return [master execute:query with:block];
}

@end
