//
//  NSArray+orNull.m
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "NSArray+orNull.h"

@implementation NSArray (orNull)

- (id)objectAtIndexOrNil:(NSUInteger)index
{
	if (index < [self count]) {
		return [self objectAtIndex:index];
	} else {
		return nil;
	}
}

@end
