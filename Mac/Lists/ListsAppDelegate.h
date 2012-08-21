//
//  ListsAppDelegate.h
//  Lists
//
//  Created by Ethan Reesor on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ListsAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	UINavigationBar *navbar;
	UINavigationBar *navbar;
	UITableView *navbar;
}
@property (nonatomic, retain) IBOutlet UITableView *navbar;
@property (nonatomic, retain) IBOutlet UINavigationBar *navbar;
@property (nonatomic, retain) IBOutlet UINavigationBar *navbar;

@property (assign) IBOutlet NSWindow *window;

@end
