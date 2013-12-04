//
//  ETViewController.m
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import "ETViewController.h"

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


//ETDataManagerDelegate
-(void)ETDataManagerDelegateDidUpdateData:(ETDataManager*)dataManager{
    NSArray * lines = [dataManager.rawCSVString componentsSeparatedByString:@"\n"];
    NSInteger max50LineCount = MIN(50, lines.count);
    NSArray * lastLines = [lines subarrayWithRange:NSMakeRange(lines.count - max50LineCount, max50LineCount)];
    NSString * lastLinesString = [lastLines componentsJoinedByString:@"\n"];
    
    self.outputView.text = lastLinesString;

}
@end
