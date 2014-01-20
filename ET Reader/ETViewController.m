//
//  ETViewController.m
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import "ETViewController.h"
#import "PerformSelectorWithDebounce.h"
#import <AudioToolbox/AudioServices.h>

@interface ETViewController ()

@end

@implementation ETViewController

//orientation speicifc code
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
        [self.view addSubview:self.graphView];
    }else{
        [self.graphView removeFromSuperview];
    }
}


-(void ) managerYieldedData:(NSData*)yieldedData withManager:(ETBTLEManager*)manager{
    [self.dataManager feedData:yieldedData];
}



-(ETDataManager*) dataManager{
    if (_dataManager == nil){
        _dataManager = [[ETDataManager alloc] init];
        [_dataManager setAllowFlags:TRUE];
        [_dataManager setInterestingIndexes:[NSSet setWithArray:@[@(0)]]];
        [_dataManager setDelegate:self];
        [_dataManager setCsvColumnCount:1];
    }
    return _dataManager;
}


-(BOOL) setupAudioSession{
    
    //activate
    NSError *activationError = nil;
    BOOL success = [self.triggerAudioSession setActive: YES error: &activationError];
    if (!success) { /* handle the error in activationError */
        EXOLog(@"Session activate error: %@", activationError);
        return FALSE;
    }
    
    //set category
    NSError *setCategoryError = nil;
    success = [self.triggerAudioSession
               setCategory: AVAudioSessionCategoryPlayback
               withOptions:AVAudioSessionCategoryOptionMixWithOthers error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */
        EXOLog(@"Session set category error: %@", activationError);
        return FALSE;
    }

    return TRUE;
}
-(AVAudioSession*) triggerAudioSession; {
    if (_triggerAudioSession == nil){
        _triggerAudioSession = [AVAudioSession sharedInstance];
        
    }
    return _triggerAudioSession;
}



-(void) updateTriggerThresholdWithValue:(double)threshold{
    self.triggerThreshold = threshold; //default threshold
    
    [self.triggerThresholdLabel setText:[NSString stringWithFormat:NSLocalizedString(@"threshold: %f", @"threshold string"), self.triggerThreshold]];
    self.triggerThresholdSlider.value = self.triggerThreshold/self.maxTrigger;
    
}

-(GraphView*) graphView{
    if (_graphView == nil){
        _graphView = [[GraphView alloc] initWithFrame:CGRectMake(180, 70, 375, 240)];

//        [_graphView setManualY:1024];//this is the 10bit dac from the arduino
//        [self.view addSubview:_graphView];
    }
    
    return _graphView;
}

- (void)viewDidLoad
{
    self.displayString = [@"" mutableCopy];
 
    self.maxTrigger = 1025;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupAudioSession];
    
    [self updateTriggerThresholdWithValue:self.maxTrigger];
    self.enableTriggers = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectedSwitchFlipped:(UISwitch*)senderSwitch {
    
    [self.delegate ETViewControllerWantsSetConnectedOn:[senderSwitch isOn] withVC:self];
    
    if ([senderSwitch isOn] == FALSE){ //just show everything if stopped
        self.outputView.text = [self.dataManager rawCSVString];
    }
    
}

- (IBAction)clearViewTapGestureRecognized:(id)sender{
    [self.outputView setText:@""];
    [self.dataManager newSession];
} 

- (IBAction)versionRequestButtonPressed:(id)sender {
    [self.btleManager sendDataToPeripheral:[@"flash;" dataUsingEncoding:NSUTF8StringEncoding ]];
}

- (IBAction)flagButtonPressed:(id)sender {
    [self.dataManager setNextDataPointFlag:ETDataFlagNormal];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (IBAction)exportButtonPressed:(id)sender {
    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // The file extension is important so that some mime magic happens!
    NSString *filePath = [docsPath stringByAppendingPathComponent:@"examresults.csv"];
    NSURL *fileUrl     = [NSURL fileURLWithPath:filePath];
    
    [[[self.dataManager rawCSVString] dataUsingEncoding:NSUTF8StringEncoding] writeToURL:fileUrl atomically:YES]; // save the file
    
    
//    __weak ETViewController * thisVC = self;
    NSString * resultsDateString = [NSString stringWithFormat:NSLocalizedString(@"ET Exam Results from %@", @"resultsDateString"), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[resultsDateString,fileUrl] applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];

}

- (IBAction)triggerThresholdSliderChanged:(id)sender {
    [self updateTriggerThresholdWithValue: [self.triggerThresholdSlider value]*self.maxTrigger];
}
- (IBAction)makeSessionActiveButtonPressed:(id)sender {
    [self.btleManager sendDataToPeripheral:[@"startSession;" dataUsingEncoding:NSUTF8StringEncoding ]];
}
- (IBAction)makeSessionIdleButtonPressed:(id)sender {
    [self.btleManager sendDataToPeripheral:[@"endSession;" dataUsingEncoding:NSUTF8StringEncoding ]];
}


-(void) addDataStringToView:(NSString*)dataString{
    
   [self.displayString appendString:dataString];
    self.outputView.text = self.displayString;
}



-(void) _updateRawDataDisplay{
    NSArray * lines = self.dataManager.uptoFiftyLastRawCSVRows;
    NSInteger displayLineCount = MIN(25, lines.count);
    NSArray * lastLines = [lines subarrayWithRange:NSMakeRange(lines.count - displayLineCount, displayLineCount)];
    NSString * lastLinesString = [lastLines componentsJoinedByString:@"\n"];
    
    self.outputView.text = lastLinesString;
}

-(void) _updateGraphView{
    //see https://github.com/alist/Arduino-Brain-Library
    //0 state
    //1 data millis
    //2 quality
    //3 for readMeditation
    //4 for attention
    //5 low beta higher when you're alert and focused
    //6 low gamma multi-sensory processing
    NSArray * series = [[self.dataManager indexedDataArrays] objectForKey:@(0)];
    //each point is spaced equally if in active mode
    
    NSInteger displayPointCount = MIN(1000, series.count);
    
    NSMutableArray * floatedArray = [NSMutableArray array];
    for (NSString* item in [series subarrayWithRange:NSMakeRange(series.count - displayPointCount, displayPointCount)]){
        [floatedArray addObject:@(item.floatValue)];
    }
    
    [self.graphView setArray:floatedArray];
}


-(void)_checkDataForTriggers{
    
    NSNumber * triggerSeries = @(0);//4=attention
    
    NSArray * series = [[self.dataManager indexedDataArrays] objectForKey:triggerSeries];
    
    NSInteger displayPointCount = MIN(2, series.count);
    
    BOOL doesTrigger = FALSE;
    for (NSString* item in [series subarrayWithRange:NSMakeRange(series.count - displayPointCount, displayPointCount)]){
//        EXOLog(@"Item: %i", [item integerValue]);
        if ([item integerValue] >= self.triggerThreshold){
            doesTrigger = TRUE;
        }
    }

    
    if (doesTrigger == TRUE){
        [self performSelector:@selector(_playTriggerSound) withDebounceDuration:.5];
    }
}

-(void)_playTriggerSound{
    
//    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"ow"];

    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [synth speakUtterance:utterance];

    
    
//    self.triggerAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Narrative-Jibberish-goodpoint" ofType:@"wav" inDirectory:@"/"]] error:nil];
//	self.triggerAudio.volume = .7;
//	self.triggerAudio.numberOfLoops = 1;
//	int64_t delayInSeconds = 0.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[self.triggerAudio play];
//	});

}

//ETDataManagerDelegate
-(void)ETDataManagerDelegateDidUpdateData:(ETDataManager*)dataManager{
    [self performSelector:@selector(_updateRawDataDisplay) withDebounceDuration:.15];
    
    [self performSelector:@selector(_updateGraphView) withDebounceDuration:.15];

    if (self.enableTriggers){
        [self performSelector:@selector(_checkDataForTriggers) withDebounceDuration:.15];
    }
}



//UIActivityItemSource //maybe not even needed
// called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController{
    return self.dataManager.rawCSVString;
}

// called to fetch data after an activity is selected. you can return nil
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType{
    return self.dataManager.rawCSVString;
}

@end
