//
//  NSString+isNumber.m
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "NSString+isNumber.h"

@implementation NSString (isNumber)

- (BOOL)isInteger
{
	static NSCharacterSet * nonDigits = nil;
	if (nonDigits == nil)
		nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	
	NSRange range = [self rangeOfCharacterFromSet:nonDigits];
	return NSNotFound == range.location;
}

@end
