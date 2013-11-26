//
//  ETAppDelegate.h
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETBTLEManager.h"
#import "ETViewController.h"

@interface ETAppDelegate : UIResponder <UIApplicationDelegate, ETBTLEManagerDelegate, ETViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ETBTLEManager* btleManager;
@property (nonatomic, weak) ETViewController* etVC;


@end
