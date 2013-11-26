//
//  ETViewController.h
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETViewController;


@protocol ETViewControllerDelegate <NSObject>

//no = disconnect
-(void) ETViewControllerWantsSetConnectedOn:(BOOL)yesConnect withVC:(ETViewController*)vc;

@end

@interface ETViewController : UIViewController

@property (nonatomic, assign)BOOL canConnect;
@property (nonatomic, weak) id<ETViewControllerDelegate> delegate;



@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UISwitch *connectedSwitch;
- (IBAction)connectedSwitchFlipped:(id)sender;
- (IBAction)clearViewTapGestureRecognized:(id)sender;

-(void) addDataStringToView:(NSString*)dataString;

@end
