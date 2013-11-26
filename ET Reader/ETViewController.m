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

- (void)viewDidLoad
{
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
}

- (IBAction)clearViewTapGestureRecognized:(id)sender{
    [self.outputView setText:@""];
} 


-(void) addDataStringToView:(NSString*)dataString{
    self.outputView.text = [self.outputView.text stringByAppendingString: dataString];
//    CGPoint bottomOffset = CGPointMake(0, self.outputView.contentSize.height - self.outputView.bounds.size.height);
//    [self.outputView setContentOffset:bottomOffset animated:FALSE];
}
@end
