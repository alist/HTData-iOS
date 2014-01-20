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
#import "GraphView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@class ETViewController;


@protocol ETViewControllerDelegate <NSObject>

//no = disconnect
-(void) ETViewControllerWantsSetConnectedOn:(BOOL)yesConnect withVC:(ETViewController*)vc;

@end

@interface ETViewController : UIViewController <ETBTLEManagerDataDelegate, ETDataManagerDelegate,UIActivityItemSource>

@property (nonatomic, assign)BOOL canConnect;
@property (nonatomic, weak) id<ETViewControllerDelegate> delegate;


@property (nonatomic, strong) AVAudioPlayer * triggerAudio;
@property (nonatomic, strong) AVAudioSession * triggerAudioSession;

@property (nonatomic, assign) double triggerThreshold;
@property (nonatomic, assign) double maxTrigger;

@property (strong, nonatomic) ETBTLEManager* btleManager;
@property (strong, nonatomic) ETDataManager * dataManager;

@property (nonatomic, assign)BOOL enableTriggers;

@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UISwitch *connectedSwitch;
@property (weak, nonatomic) IBOutlet UISlider *triggerThresholdSlider;
@property (weak, nonatomic) IBOutlet UILabel *triggerThresholdLabel;

@property (nonatomic, strong) GraphView * graphView;

@property (nonatomic, strong) NSMutableString * displayString;

- (IBAction)connectedSwitchFlipped:(id)sender;
- (IBAction)clearViewTapGestureRecognized:(id)sender;
- (IBAction)versionRequestButtonPressed:(id)sender;
- (IBAction)flagButtonPressed:(id)sender;
- (IBAction)exportButtonPressed:(id)sender;
- (IBAction)triggerThresholdSliderChanged:(id)sender;


-(void) updateTriggerThresholdWithValue:(double)threshold;

-(void) addDataStringToView:(NSString*)dataString;

-(BOOL) setupAudioSession;

-(void)_updateRawDataDisplay;
-(void)_updateGraphView;

@end
