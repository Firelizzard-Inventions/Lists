//
//  DBEntry.h
//  Lists
//
//  Created by Ethan Reesor on 10/13/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBGroup;

@interface DBEntry : NSObject {
@protected
	NSString *name;
	DBGroup *parent;
}

@property (readonly) NSString *name;
@property (readonly) DBGroup *parent;

@end
