//
//  FIDataController.h
//  Lists
//
//  Created by Ethan Reesor on 10/4/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "definitions.h"

#import "SQLiteDB.h"
#import "FIDataControllerListener.h"

#import "NSArray+orNull.h"

@interface FIDataController : NSObject <DBListener> {
	SQLiteDB * master;
	NSMutableArray * listeners;
}

// Shared Instance Methods
+ (FIDataController *)defaultController;

// Lifecycle Methods
- (id)initWithPath:(NSString *)path;

// Database Methods
- (void)ensureOpen;
- (void)ensureClose;
- (NSArray *)execute:(NSString *)query, ... NS_FORMAT_FUNCTION(1,2);

// Listener Methods
- (void)addListener:(NSObject<FIDataControllerListener> *)listener;
- (void)removeListener:(NSObject<FIDataControllerListener> *)listener;

// Entry Methods
- (NSNumber *)validateEntry:(NSDictionary *)entry;

// Select Methods
- (NSArray *)columns:(NSString *)select ofEntriesOfType:(NSString *)type withID:(NSNumber *)_id andParent:(NSNumber *)parent where:(NSString *)where and:(NSString *)other;
- (NSArray *)entriesOfType:(NSString *)type withParent:(NSNumber *)parent;
- (NSInteger)countOfEntriesOfType:(NSString *)type withParent:(NSNumber *)parent;

// Index Methods
- (NSDictionary *)entryOfType:(NSString *)type forIndex:(NSIndexPath *)indexPath withParent:(NSNumber *)parent;
- (NSInteger)numberOfEntriesOfType:(NSString *)type forIndex:(NSIndexPath *)indexPath withParent:(NSNumber *)parent;

@end
