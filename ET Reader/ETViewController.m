//
//  ETViewController.m
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import "ETViewController.h"
#import "PerformSelectorWithDebounce.h"

@interface ETViewController ()

@end

@implementation ETViewController



-(void ) managerYieldedData:(NSData*)yieldedData withManager:(ETBTLEManager*)manager{
//    NSString * dataString = [[NSString alloc] initWithData:yieldedData encoding:NSUTF8StringEncoding];
//    [self addDataStringToView:dataString];
    [self.dataManager feedData:yieldedData];
}



-(ETDataManager*) dataManager{
    if (_dataManager == nil){
        _dataManager = [[ETDataManager alloc] init];
        [_dataManager setAllowFlags:TRUE];
        [_dataManager setInterestingIndexes:[NSSet setWithArray:@[@(1),@(2),@(3)]]];
        [_dataManager setDelegate:self];
        [_dataManager setCsvColumnCount:4];
    }
    return _dataManager;
}

- (void)viewDidLoad
{
    self.displayString = [@"" mutableCopy];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    [self.btleManager sendDataToPeripheral:[@"version;" dataUsingEncoding:NSUTF8StringEncoding ]];
}

- (IBAction)flagButtonPressed:(id)sender {
    [self.dataManager setNextDataPointFlag:ETDataFlagNormal];
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


-(void) displayGraph{
    
}

-(void) updateRawDataDisplay{
    NSArray * lines = self.dataManager.uptoFiftyLastRawCSVRows;
    NSInteger displayLineCount = MIN(30, lines.count);
    NSArray * lastLines = [lines subarrayWithRange:NSMakeRange(lines.count - displayLineCount, displayLineCount)];
    NSString * lastLinesString = [lastLines componentsJoinedByString:@"\n"];
    
    self.outputView.text = lastLinesString;
}


//ETDataManagerDelegate
-(void)ETDataManagerDelegateDidUpdateData:(ETDataManager*)dataManager{
    [self performSelector:@selector(updateRawDataDisplay) withDebounceDuration:.15];

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
