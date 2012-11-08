//
//  FIDataController.m
//  Lists
//
//  Created by Ethan Reesor on 10/4/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "FIDataController.h"

@implementation FIDataController

static FIDataController *defaultController = nil;

#pragma mark - Shared Instance Methods

+ (FIDataController *)defaultController {
	@synchronized(self) {
		if (defaultController == nil) {
			defaultController = [[FIDataController alloc] initWithPath:[FIDataController masterDBPath]];
		}
	}
	return defaultController;
}

#pragma mark - Lifecycle Methods

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
		int status;
		
		master = [[SQLiteDB alloc] initWithFile:path];
		
		listeners = [[NSMutableArray alloc] init];
		
		NSFileManager *manager = [NSFileManager defaultManager];
		if (![manager fileExistsAtPath:path]) {
			
			NSString * groupq = [NSString stringWithContentsOfFile:[FIDataController groupSQLPath] encoding:NSASCIIStringEncoding error:nil];
			NSString * listq = [NSString stringWithContentsOfFile:[FIDataController listSQLPath] encoding:NSASCIIStringEncoding error:nil];
			NSString * linkq = [NSString stringWithContentsOfFile:[FIDataController linkSQLPath] encoding:NSASCIIStringEncoding error:nil];
			NSString * allq = [NSString stringWithContentsOfFile:[FIDataController allSQLPath] encoding:NSASCIIStringEncoding error:nil];
			
			status = 0;
			if (!status) status = [master open];
			if (!status) status = [master execute:@"%@", groupq];
			if (!status) status = [master execute:@"%@", listq];
			if (!status) status = [master execute:@"%@", linkq];
			if (!status) status = [master execute:@"%@", allq];
			if (!status) status = [master close];
		}
		
		master.foreignKeys = YES;
		[master addListener:self];
    }
    return self;
}

- (void)dealloc
{
	[self ensureClose];
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

+ (NSString *)linkSQLPath
{
	return [[NSBundle mainBundle] pathForResource:@"link" ofType:@"sql"];
}

+ (NSString *)allSQLPath
{
	return [[NSBundle mainBundle] pathForResource:@"all" ofType:@"sql"];
}

#pragma mark - Database Methods

- (void)ensureOpen
{
	[master ensureOpen];
}

- (void)ensureClose
{
	[master ensureClose];
}

- (NSArray *)execute:(NSString *)query, ...
{
	va_list args;
	__block NSMutableArray * results = [[NSMutableArray alloc] init];
	callback block = ^(NSDictionary * row) {
		[results addObject:[NSDictionary dictionaryWithDictionary:row]];
	};
	
	va_start(args, query);
	[master ensureOpen];
	int status = [master execute:query with:block	varguments:args];
	va_end(args);
	
	if (status) {
		[results addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[master lastError], [NSNumber numberWithInteger:status+FIDatabaseGenericError], nil]
													   forKeys:[NSArray arrayWithObjects:FIEntryKeyError, FIEntryKeyECode, nil]]];
	}
	
	return [NSArray arrayWithArray:results];
}

#pragma mark - Listener Methods
- (void)addListener:(id<FIDataControllerListener>)listener
{
	[listeners addObject:listener];
}

- (void)removeListener:(id<FIDataControllerListener>)listener
{
	[listeners removeObject:listener];
}


#pragma mark - Entry Methods

- (NSNumber *)validateEntry:(NSDictionary *)entry
{
	NSNumber * error =	[entry objectForKey:FIEntryKeyECode];
	NSNumber * _id =	[entry objectForKey:FIEntryKeyID];
	NSString * name =	[entry objectForKey:FIEntryKeyName];
	NSString * type =	[entry objectForKey:FIEntryKeyType];
//	NSNumber * parent =	[entry objectForKey:FIEntryKeyParent];
	
	if (entry == nil || [entry isNull]) {
		return [NSNumber numberWithInt:FIModelNullResultError];
	} else if (error != nil && ![error isNull]) {
		return error;
	} else if (_id == nil || [_id isNull]) {
		return [NSNumber numberWithInt:FIModelNullIDError];
	} else if (name == nil || [name isNull]) {
		return [NSNumber numberWithInt:FIModelNullNameError];
	} else if (type == nil || [type isNull]) {
		return [NSNumber numberWithInt:FIModelNullTypeError];
//	} else if (parent == nil || [parent isNull]) {
//		return [[NSNumber numberWithInt:FIModelNullParentError] stringValue];
	} else {
		if ([FIEntryTypeGroup isEqualToString:type]) {
			return nil;
		} else if ([FIEntryTypeList isEqualToString:type]) {
			return nil;
		} else {
			return [NSNumber numberWithInt:FIModelUnknownTypeError];
		}
	}
}

#pragma mark - Select Methods

- (NSArray *)columns:(NSString *)select ofEntriesOfType:(NSString *)type withID:(NSNumber *)_id andParent:(NSNumber *)parent where:(NSString *)where and:(NSString *)other
{
	NSString * table = [NSString stringWithFormat:@"_t_%@", type];
	
	NSString * temp = @"name!='_temp'";
	if (![FIEntryTypeAll isEqualToString:type]) {
		temp = [NSString stringWithFormat:@"%@_%@", type, temp];
	}
	
	if (where == nil || [where isNull]) {
		where = temp;
	} else {
		where = [NSString stringWithFormat:@"%@ AND %@", where, temp];
	}
	
	if (_id != nil && ![_id isNull]) {
		NSString * idstr = [NSString stringWithFormat:@"id=%@", _id];
		if (![FIEntryTypeAll isEqualToString:type]) {
			where = [NSString stringWithFormat:@"%@_%@", type, idstr];
		}
		where = [NSString stringWithFormat:@"%@ AND %@", where, idstr];
	}
	
	if (parent == nil || [parent isNull]) {
		where = [NSString stringWithFormat:@"%@ AND parent IS NULL", where];
	} else if ([parent integerValue]) {
		where = [NSString stringWithFormat:@"%@ AND parent=%@", where, parent];
	}
	
	if (other == nil || [other isNull]) {
		other = @"";
	}
	
	return [self execute:@"SELECT %@ FROM %@ WHERE %@ %@", select, table, where, other];
}

- (NSArray *)entriesOfType:(NSString *)type withParent:(NSNumber *)parent
{
	NSString * order = @"name";
	if (![FIEntryTypeAll isEqualToString:type]) {
		order = [NSString stringWithFormat:@"%@_%@", type, order];
	}
	
	return [self columns:@"*" ofEntriesOfType:type withID:nil andParent:parent where:nil and:[NSString stringWithFormat:@"ORDER BY %@ ASC", order]];
}

- (NSInteger)countOfEntriesOfType:(NSString *)type withParent:(NSNumber *)parent
{
	return [[[[self columns:@"COUNT(*) AS n" ofEntriesOfType:type withID:nil andParent:parent where:nil and:nil] objectAtIndexOrNil:0] objectForKey:@"n"] integerValue];
}

#pragma mark - Index Methods

- (NSDictionary *)entryOfType:(NSString *)type forIndex:(NSIndexPath *)indexPath withParent:(NSNumber *)parent
{
	return [self entryOfType:type forIndex:indexPath atPosition:1 withParent:parent];
}

- (NSInteger)numberOfEntriesOfType:(NSString *)type forIndex:(NSIndexPath *)indexPath withParent:(NSNumber *)parent
{
	if (indexPath == nil)
		return [self countOfEntriesOfType:type withParent:parent];
	else {
		NSDictionary * entry = [self entryOfType:type forIndex:indexPath atPosition:1 withParent:parent];
		NSNumber * error = [self validateEntry:entry];
		if (error == nil || [error isNull]) {
			return [self countOfEntriesOfType:type withParent:[entry objectForKey:FIEntryKeyID]];
		} else {
			return 0;
		}
	}
}

- (NSDictionary *)entryOfType:(NSString *)type forIndex:(NSIndexPath *)indexPath atPosition:(NSUInteger)position withParent:(NSNumber *)parent
{
	NSDictionary * entry = [[self entriesOfType:type withParent:parent] objectAtIndexOrNil:[indexPath indexAtPosition:position++]];
	NSNumber * error = [self validateEntry:entry];
	if (error != nil && ![error isNull]) {
		return [NSDictionary dictionaryWithObject:error forKey:FIEntryKeyECode];
	} else if (position < [indexPath length]) {
		return [self entryOfType:type forIndex:indexPath atPosition:position withParent:[entry objectForKey:FIEntryKeyID]];
	} else {
		return entry;
	}
}

#pragma mark - Database Listener Methods
- (void)executed:(NSString *)query
{
	for (NSObject<FIDataControllerListener> * listener in listeners) {
		if ([listener respondsToSelector:@selector(executed:)]) {
			[listener executed:query];
		}
	}
}

- (void)executed:(NSString *)query onTable:(NSString *)table
{
	for (NSObject<FIDataControllerListener> * listener in listeners) {
		if ([listener respondsToSelector:@selector(executed:onTable:)]) {
			[listener executed:query onTable:table];
		}
		
		if (query == SQL_SELECT && [listener respondsToSelector:@selector(executedSelectOnTable:)]) {
			[listener executedSelectOnTable:table];
		} else if (query == SQL_INSERT && [listener respondsToSelector:@selector(executedInsertOnTable:)]) {
			[listener executedInsertOnTable:table];
		} else if (query == SQL_UPDATE && [listener respondsToSelector:@selector(executedUpdateOnTable:)]) {
			[listener executedUpdateOnTable:table];
		} else if (query == SQL_DELETE && [listener respondsToSelector:@selector(executedDeleteOnTable:)]) {
			[listener executedDeleteOnTable:table];
		}
		
		if ((query == SQL_INSERT || query == SQL_UPDATE || query == SQL_DELETE) && [listener respondsToSelector:@selector(executedChange:onTable:)]) {
			[listener executedChange:query onTable:table];
		}
	}
}

@end
