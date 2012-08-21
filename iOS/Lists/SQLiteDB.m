//
//  SQLiteDB.m
//  Lists
//
//  Created by Ethan Reesor on 9/28/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//
//	Please read the comments in the associated header.
//

#import "SQLiteDB.h"


@implementation SQLiteDB

- (id)initWithFile:(NSString *)path
{
	self = [super init];
	if (self) {
		// Take ownership of the path string
		databasePath = [path copy];
		
		// Initialize locks
		open = [[NSLock alloc] init];
		exec = [[NSLock alloc] init];
		
		// Add discriptive names to the locks
		[open setName:@"DB Open Status"];
		[exec setName:@"DB Executing Status"];
		
		// Lock `open` so no queries are run without the database being open
		[open lock];
	}
	
	return self;
}

- (void)dealloc
{
	// Release ownership of the pass string
	[databasePath release];
	
	[super dealloc];
}

#pragma mark SQLite Callback Function

int execcb(void * passed, int numcols, char **vals, char **cols)
{
	// Initialize and fill a mutable dictionary for the row
	NSMutableDictionary *mrow = [[NSMutableDictionary alloc] initWithCapacity:numcols];
	for (int i = 0; i < numcols; i++)
		[mrow setObject:[NSString stringWithCString:vals[i] encoding:NSASCIIStringEncoding]
				 forKey:[NSString stringWithCString:cols[i] encoding:NSASCIIStringEncoding]];
	
	// Check if the block is non-null and pass it the dictionary
	if (passed != NULL) {
		(*((void (^*)(NSDictionary *))passed))([NSDictionary dictionaryWithDictionary:mrow]);
	}
	
	return 0;
}

#pragma mark SQLite Methods

- (int)open
{
	int status;
	
	// Try to open the database
	status = sqlite3_open([databasePath UTF8String], &internaldb);
	
	// If the database opened, unlock `open`
	if (status == SQLITE_OK) [open unlock];
	
	return status;
}

- (int)close
{
	int status;
	
	// Try to get the lock on `exec`
	if ([exec tryLock]) {
		status = sqlite3_close(internaldb);
		[exec unlock];
	} else {
		status = SQLITE_DB_NOLOCK;
	}
	
	// If the database was closed, lock `open`
	if (status == SQLITE_OK) [open tryLock];
	
	return status;
}

- (int)execute:(const char *)query
{
	// This might do more later
	return [self execute:query with:NULL];
}

- (int)execute:(const char *)query with:(void (^)(NSDictionary * row))block
{
	int status;
	char *err;
	
	if ([exec tryLock]) {
		if ([open tryLock]) {
			if (block != NULL) status = sqlite3_exec(internaldb, query, &execcb, &block, &err);
			else status = sqlite3_exec(internaldb, query, &execcb, NULL, &err);
			[open unlock];
		} else {
			status = SQLITE_DB_NOLOCK;
		}
		[exec unlock];
	} else {
		status = SQLITE_DB_NOLOCK;
	}
	
	if (status != SQLITE_OK) {
		if (err != NULL) sqlite3_free(err);
	}
	
	return status;
}

@end
