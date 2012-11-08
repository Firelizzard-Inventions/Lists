//
//  DBListener.h
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBListener <NSObject>

@optional
- (void)executed:(NSString *)query;
- (void)executed:(NSString *)query onTable:(NSString *)table;

@end
