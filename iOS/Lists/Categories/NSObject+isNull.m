//
//  NSObject+isNull.m
//  Lists
//
//  Created by Ethan Reesor on 10/11/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import "NSObject+isNull.h"

@implementation NSObject (isNull)

- (BOOL)isNull
{
	return self == [NSNull null];
}

@end
