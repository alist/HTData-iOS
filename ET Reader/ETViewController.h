//
//  ETViewController.h
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETBTLEManager.h"
#import "ETDataManager.h"

@class ETViewController;


@protocol ETViewControllerDelegate <NSObject>

//no = disconnect
-(void) ETViewControllerWantsSetConnectedOn:(BOOL)yesConnect withVC:(ETViewController*)vc;

@end

@interface ETViewController : UIViewController <ETBTLEManagerDataDelegate, ETDataManagerDelegate,UIActivityItemSource>

@property (nonatomic, assign)BOOL canConnect;
@property (nonatomic, weak) id<ETViewControllerDelegate> delegate;

@property (strong, nonatomic) ETBTLEManager* btleManager;
@property (strong, nonatomic) ETDataManager * dataManager;

@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UISwitch *connectedSwitch;

@property (nonatomic, strong) NSMutableString * displayString;

- (IBAction)connectedSwitchFlipped:(id)sender;
- (IBAction)clearViewTapGestureRecognized:(id)sender;
- (IBAction)versionRequestButtonPressed:(id)sender;
- (IBAction)flagButtonPressed:(id)sender;
- (IBAction)exportButtonPressed:(id)sender;

-(void) addDataStringToView:(NSString*)dataString;

@end
