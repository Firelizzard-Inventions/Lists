//
//  SQLiteDB.h
//  Lists
//
//  Created by Ethan Reesor on 9/28/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

// This defines the error code that denotes there was an issue getting a lock
#define SQLITE_DB_NOLOCK -1

@interface SQLiteDB : NSObject {
	// This is the internal SQLite database structure
	sqlite3 *internaldb;
	
	// This is the path to the database
	NSString *databasePath;
	
	// These locks ensure that:
	// A) No queries are executed before the database is open
	// B) Only one query at a time is executed
	// C) The database is not closed while a query is being run
	NSLock *open;
	NSLock *exec;
}

// This is the only initializer that should be used
// The only argument is the path to the database file
- (id)initWithFile:(NSString *)path;

// The callback function for sqlite3_exec()
int execcb(void * passed, int numcols, char **vals, char **cols);

// This opens the database
- (int)open;

// This closes the database
- (int)close;

// This executes a query, discarding the results
- (int)execute:(const char *)query;

// This executes a query and passes each result row to
// the passed block as an instance of NSDictionary
- (int)execute:(const char *)query with:(void (^)(NSDictionary * row))block;

@end
