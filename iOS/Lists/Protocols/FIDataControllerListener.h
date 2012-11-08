//
//  FIDataControllerListener.h
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FIDataControllerListener <NSObject>

@optional
- (void)executed:(NSString *)query;

- (void)executed:(NSString *)query onTable:(NSString *)table;
- (void)executedSelectOnTable:(NSString *)table;
- (void)executedInsertOnTable:(NSString *)table;
- (void)executedUpdateOnTable:(NSString *)table;
- (void)executedDeleteOnTable:(NSString *)table;
- (void)executedChange:(NSString *)query onTable:(NSString *)table;

@end