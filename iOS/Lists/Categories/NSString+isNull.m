//
//  NSString+isNull.m
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "NSString+isNull.h"

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
