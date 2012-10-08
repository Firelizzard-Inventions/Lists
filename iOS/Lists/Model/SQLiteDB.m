//
//  SQLiteDB.m
//  Lists
//
//  Created by Ethan Reesor on 9/28/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import "SQLiteDB.h"

@implementation NSObject (isNull)

- (BOOL)isNull
{
	return self == [NSNull null];
}

@end

@implementation NSString (isNull)

- (BOOL)isNull
{
	if ([super isNull]) {
		return YES;
	} else {
		return [self isEqualToString:@""];
	}
}

@end

@implementation NSString (isNumber)

- (BOOL)isInteger
{
	NSRange range = [self rangeOfCharacterFromSet:[SQLiteDB nonDigits]];
	return NSNotFound == range.location;
}

@end

@implementation SQLiteDB

#pragma mark - Lifecycle Methods

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
		
		listeners = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark - Protocol Methods

+ (NSCharacterSet *)nonDigits
{
	static NSCharacterSet * nonDigits = nil;
	if (nonDigits == nil)
		nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	return nonDigits;
}

#pragma mark - Location Methods

+ (NSString *)masterDBPath
{
	NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return [dir stringByAppendingPathComponent:@"master.db"];
}

+ (NSString *)groupSQLPath
{
	return [[NSBundle mainBundle] pathForResource:@"group" ofType:@"sql"];
}

+ (NSString *)listSQLPath
{
	return [[NSBundle mainBundle] pathForResource:@"list" ofType:@"sql"];
}

+ (NSString *)allSQLPath
{
	return [[NSBundle mainBundle] pathForResource:@"all" ofType:@"sql"];
}

#pragma mark - SQLite Callback Function

int execcb(void * passed, int numcols, char **vals, char **cols)
{
	// Initialize and fill a mutable dictionary for the row
	NSMutableDictionary *mrow = [[NSMutableDictionary alloc] initWithCapacity:numcols];
	for (int i = 0; i < numcols; i++) {
		id val = nil;
		if (!vals[i]) {
			val = [NSNull null];
		} else {
			val = [NSString stringWithCString:vals[i] encoding:NSASCIIStringEncoding];
			if ([val isInteger]) {
				NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
				[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
				val = [formatter numberFromString:val];
			}
		}
		id col = [NSString stringWithCString:cols[i] encoding:NSASCIIStringEncoding];
		[mrow setObject:val forKey:col];
	}
	
	// Check if the block is non-null and pass it the dictionary
	if (passed != NULL) {
		(*(callbackptr)passed)(mrow);
	}
	
	return 0;
}

#pragma mark - Listener Methods
- (void)addListener:(NSObject<DBListener> *)listener
{
	[listeners addObject:listener];
}

- (void)removeListener:(NSObject<DBListener> *)listener
{
	[listeners removeObject:listener];
}

#pragma mark - SQLite Methods

- (int)open
{
	int status;
	
	// Try to open the database
	status = sqlite3_open([databasePath UTF8String], &internaldb);
	
	// If the database opened, unlock `open`
	if (status == SQLITE_OK) {
		[open unlock];
		is_open = YES;
	}
	
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
	if (status == SQLITE_OK)
		is_open = ![open tryLock];
	
	return status;
}

- (BOOL)isOpen
{
	return is_open;
}

- (void)ensureOpen
{
	if (![self isOpen])
		[self open];
}

- (void)ensureClose
{
	if ([self isOpen]) {
		[exec lock];
		[self close];
		[exec unlock];
	}
}

- (int)execute:(NSString *)query, ...
{
	int status;
	va_list args;
	
	va_start(args, query);
	status = [self execute:query with:NULL varguments:args];
	va_end(args);
	
	return status;
}

- (int)execute:(NSString *)query with:(callback)block, ...
{
	int status;
	va_list args;
	
	va_start(args, block);
	status = [self execute:query with:NULL varguments:args];
	va_end(args);
	
	return status;
}

- (int)execute:(NSString *)queryf with:(callback)block varguments:(va_list)args
{
	static NSRegularExpression * _query, * select, * insert, * update, * delete;
	if (_query == nil || [_query isNull]) {
		int options = NSRegularExpressionCaseInsensitive;
		_query = [NSRegularExpression regularExpressionWithPattern:@"[^;]+" options:options error:NULL];
		select = [NSRegularExpression regularExpressionWithPattern:@"^SELECT .+ FROM (\\w+).+$" options:options error:NULL];
		insert = [NSRegularExpression regularExpressionWithPattern:@"^INSERT INTO (\\w+).+$" options:options error:NULL];
		update = [NSRegularExpression regularExpressionWithPattern:@"^UPDATE (\\w+).+$" options:options error:NULL];
		delete = [NSRegularExpression regularExpressionWithPattern:@"^DELETE FROM (\\w+).+$" options:options error:NULL];
	}
	
	int status;
	char * err;
	NSString * query = [[NSString alloc] initWithFormat:queryf arguments:args];
	
	if ([exec tryLock]) {
		if ([open tryLock]) {
			if (block != NULL) status = sqlite3_exec(internaldb, [query cStringUsingEncoding:NSASCIIStringEncoding], &execcb, &block, &err);
			else status = sqlite3_exec(internaldb, [query cStringUsingEncoding:NSASCIIStringEncoding], &execcb, NULL, &err);
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
	} else {
		for (NSTextCheckingResult * result in [_query matchesInString:query options:0 range:NSMakeRange(0, [query length])]) {
			NSArray * selectrs = [select matchesInString:query options:0 range:[result range]];
			NSArray * insertrs = [insert matchesInString:query options:0 range:[result range]];
			NSArray * updaters = [update matchesInString:query options:0 range:[result range]];
			NSArray * deleters = [delete matchesInString:query options:0 range:[result range]];
			
			NSString * queryt, * table;
			
			if ([selectrs count] > 0) {
				queryt = SQL_SELECT;
				table = [query substringWithRange:[[selectrs objectAtIndex:0] rangeAtIndex:1]];
			} else if ([insertrs count] > 0) {
				queryt = SQL_INSERT;
				table = [query substringWithRange:[[insertrs objectAtIndex:0] rangeAtIndex:1]];
			} else if ([updaters count] > 0) {
				queryt = SQL_UPDATE;
				table = [query substringWithRange:[[updaters objectAtIndex:0] rangeAtIndex:1]];
			} else if ([deleters count] > 0) {
				queryt = SQL_DELETE;
				table = [query substringWithRange:[[deleters objectAtIndex:0] rangeAtIndex:1]];
			} else {
				queryt = [query substringWithRange:[result range]];
				table = nil;
			}
			
			for (NSObject<DBListener> * listener in listeners) {
				if ([listener respondsToSelector:@selector(executed:)]) {
					[listener executed:queryt];
				}
				if ((table != nil || ![table isNull]) && [listener respondsToSelector:@selector(executed:onTable:)]) {
					[listener executed:queryt onTable:table];
				}
			}
		}
	}
	
	return status;
}

@end
