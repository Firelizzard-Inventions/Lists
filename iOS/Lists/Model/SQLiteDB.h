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
#define SQLITE_DB_NOLOCK	-1

#define	SQL_SELECT			@"SELECT"
#define SQL_INSERT			@"INSERT"
#define SQL_UPDATE			@"UPDATE"
#define SQL_DELETE			@"DELETE"

typedef void (^callback)(NSDictionary *);
typedef __strong callback*	callbackptr;

@interface NSObject (isNull)
- (BOOL)isNull;
@end

@interface NSString (isNull)
- (BOOL)isNull;
@end

@interface NSString (isNumber)
- (BOOL)isInteger;
@end

@protocol DBListener <NSObject>

@optional
- (void)executed:(NSString *)query;
- (void)executed:(NSString *)query onTable:(NSString *)table;

@end

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
	
	// This stores whether or not the connection is open
	BOOL is_open;
	
	// This stores all of the database activity listeners
	NSMutableArray * listeners;
}

// Lifecycle Methods
- (id)initWithFile:(NSString *)path;

// This is used for number conversion
+ (NSCharacterSet *)nonDigits;

// Path Methods - shouldn't be here
+ (NSString *)masterDBPath;
+ (NSString *)groupSQLPath;
+ (NSString *)listSQLPath;
+ (NSString *)allSQLPath;

// The callback function for sqlite3_exec()
int execcb(void * passed, int numcols, char **vals, char **cols);

// Listener Methods
- (void)addListener:(NSObject<DBListener> *)listener;
- (void)removeListener:(NSObject<DBListener> *)listener;

// SQLite Methods
- (int)open;
- (int)close;
- (BOOL)isOpen;
- (void)ensureOpen;
- (void)ensureClose;
- (int)execute:(NSString *)query, ... NS_FORMAT_FUNCTION(1,2);
- (int)execute:(NSString *)query with:(callback)block, ... NS_FORMAT_FUNCTION(1,3);
- (int)execute:(NSString *)queryf with:(callback)block varguments:(va_list)args NS_FORMAT_FUNCTION(1,0);

@end
