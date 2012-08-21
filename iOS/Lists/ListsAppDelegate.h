//
//  ListsAppDelegate.h
//  Lists
//
//  Created by Ethan Reesor on 9/27/11.
//  Copyright 2011 Firelizzard Inventions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface ListsAppDelegate : NSObject <UIApplicationDelegate> {
	UITabBarController *_tabBarController;
	IBOutlet DatabaseManager *dbmgr;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
