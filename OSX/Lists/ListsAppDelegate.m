//
//  ListsAppDelegate.m
//  Lists
//
//  Created by Ethan Reesor on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListsAppDelegate.h"

@implementation ListsAppDelegate

@synthesize fart;
@synthesize table;
@synthesize navbar;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (void)dealloc {
    [table release];
    [fart release];
    [navbar release];
    [super dealloc];
}
@end
