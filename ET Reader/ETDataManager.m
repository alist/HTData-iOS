//
//  ETDataManager.m
//  ET Reader
//
//  Created by Alexander Hoekje List on 12/4/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import "ETDataManager.h"

@implementation ETDataManager

static NSString * messageDelimiter = @"\n";

-(id)init{
    if (self =[super init]){
        self.bufferString = [@"" mutableCopy];

        [self newSession];
    }
    return self;
}

-(void) newSession{
    self.rawCSVString = [@"" mutableCopy];
    self.indexedDataArrays = [@{} mutableCopy];
    self.uptoFiftyLastRawCSVRows = [@[] mutableCopy];
}

-(void) feedData:(NSData*)data{
    //we're all utf8 here, right guys?
    NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.bufferString appendString:dataString];
    EXOLog(@"DATA STRING: %@",dataString);

    [self _parseBuffer];
}

-(void) _parseBuffer{
    NSInteger newLineLoc = [self.bufferString rangeOfString:messageDelimiter].location;
    if (newLineLoc == NSNotFound || newLineLoc == 0) //no new line OR immediate new line
        return;
    
    NSString * uptoNewline = [self.bufferString substringToIndex:newLineLoc];
    [self.bufferString deleteCharactersInRange:NSMakeRange(0, newLineLoc + messageDelimiter.length)]; //toss it
    
    if ([[uptoNewline substringToIndex:1] isEqualToString:@"{"] && [[uptoNewline substringFromIndex:uptoNewline.length-1] isEqualToString:@"}"]){
        //yay it's JSON!
        [self _processJSONMessage:uptoNewline];
        
    }else { //assume it's CSV!
        
        [self _processCSVMessage:uptoNewline];

    }
}

-(void)_processJSONMessage:(NSString*)jsonMessage{
    EXOLog(@"YAY JSON: %@",jsonMessage);
    
    [[[UIAlertView alloc] initWithTitle:nil message:jsonMessage delegate:nil cancelButtonTitle:@"yo" otherButtonTitles:nil] show];
}


-(void)_processCSVMessage:(NSString*)csvMessage{
    NSInteger expectedColumnCount = self.csvColumnCount;
    
    NSMutableString * dataString = [csvMessage mutableCopy];
    if (self.allowFlags == TRUE){
        expectedColumnCount += 1; //we're adding one column
        
        [dataString appendString:@","]; //let's add the column to the data
        if (self.nextDataPointFlag > 0){ //only add a data point if flag non-zero
            [dataString appendString:@(self.nextDataPointFlag).stringValue]; //add the flag data
            self.nextDataPointFlag = 0; //now reset the flag
        }
    }
    
    NSArray * commaComponents = [dataString componentsSeparatedByString:@","];//not csvMessage anymore
    //if column checking enabled, and number of columns plus flag column added doesn't equal the number of columns found
    if (self.csvColumnCount > 0 && [commaComponents count] != expectedColumnCount){
        EXOLog(@"bad datapoint thrown-out: %@", csvMessage);
        return;
    }
    
    //now add the datastring to display buffer
    [self.uptoFiftyLastRawCSVRows addObject:[dataString copy]];
    if (self.uptoFiftyLastRawCSVRows.count > 50){
        [self.uptoFiftyLastRawCSVRows removeObjectAtIndex:0];
    }
    
    [dataString appendString:messageDelimiter]; //it has to be csv again, after all, so add a new line
    [self.rawCSVString appendString:dataString];
    
    for (NSNumber * interestingIndex in self.interestingIndexes){
        NSMutableArray * indexDataArray = [self.indexedDataArrays objectForKey:interestingIndex];
        if (indexDataArray == nil){
            indexDataArray = [[NSMutableArray alloc] init];
            [self.indexedDataArrays setObject:indexDataArray forKey:interestingIndex];
        }
        
        [indexDataArray addObject:[commaComponents objectAtIndex:interestingIndex.integerValue]];
        
    }
    
    [self.delegate ETDataManagerDelegateDidUpdateData:self];
}


//do you pretend to be a real person

@end
