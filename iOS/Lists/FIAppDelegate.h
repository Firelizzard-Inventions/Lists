//
//  FIAppDelegate.h
//  Lists
//
//  Created by Ethan Reesor on 10/3/12.
//  Copyright (c) 2012 Firelizzard Inventions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FIDataController.h"

@interface FIAppDelegate : UIResponder <UIApplicationDelegate> {
	FIDataController * model;
}

@property (strong, nonatomic) UIWindow *window;

@end
