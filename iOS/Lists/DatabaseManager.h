//
//  DatabaseManager.h
//  Lists
//
//  Created by Ethan Reesor on 9/24/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <sqlite3.h>

@class SQLiteDB;

@interface DatabaseManager : NSObject {
	SQLiteDB *master;
}

- (NSString *)masterDBPath;
- (int)executeQueryOnMasterDB:(const char *)query;
- (int)executeQueryOnMasterDB:(const char *)query with:(void (^)(NSDictionary * row))block;

@end
