//
//  ETDataManager.h
//  ET Reader
//
//  Created by Alexander Hoekje List on 12/4/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETBTLEManager.h"


@class ETDataManager;

@protocol ETDataManagerDelegate <NSObject>
-(void)ETDataManagerDelegateDidUpdateData:(ETDataManager*)dataManager;
@end

typedef enum{
    ETDataFlagNone = 0, //ETDataFlagNone before the next datapoint is available will cause an empty string to be passed
    ETDataFlagNormal = 1
}ETDataFlag;

@interface ETDataManager : NSObject //<ETBTLEManagerDataDelegate>



//deletes all old data, keeps all the settings
//keeps existing buffer data
-(void) newSession;

//adds the data to bufferString, then parses to see whether it's either a JSON infogram or a CSV data point
-(void) feedData:(NSData*)data;


//if set, then add an extra column to the CSV for ETDataFlag integers
//this column will be added to the rawCSVString, and is accessable in indexedDataArrays by specifying the index in interesting indexes
//if not set, then no column will be added
@property (nonatomic, assign) BOOL allowFlags;

//next data point will have the flag specified in the flag column described on BOOL allowFlags
//if not called before data point, an empty string is inserted in column and indexedDataArrays, if relevant
//if passed a flag before next data point, passing another flag will replace
//property is reset after including flag in datapoint
@property (nonatomic, assign) ETDataFlag nextDataPointFlag;

//if you set it to non-zero, then we will throw out data that do not have this quantity of columns
//you can set zero, in which case no check is made to determine count of columns
//pre-modification by allowFlags
@property (nonatomic, assign) NSInteger csvColumnCount;

//takes input, slaps it on here
//new lines cause an input line to be parsed
//we either expect csv, or we expect json
@property (nonatomic, strong) NSMutableString* bufferString;

//this is the output of the rawCSV w/o labels
@property (nonatomic, strong) NSMutableString* rawCSVString;

//just keeps the last data points, about 50 of em' around
@property (nonatomic, strong) NSMutableArray * uptoFiftyLastRawCSVRows;

//these are the indexes of the CSV that should be broken out as their own array
//NSNumber-NSIntegerNumber subtype
@property (nonatomic, strong) NSSet * interestingIndexes;

//this is a dictionary of mutable data arrays, corresponding to the NSNumber index from "interestingIndexes"
//the quantity of elements in each array at this time are guaranteed equal
@property (nonatomic, strong) NSMutableDictionary * indexedDataArrays;


@property (nonatomic, weak) id<ETDataManagerDelegate> delegate;



-(void) _parseBuffer;
-(void)_processCSVMessage:(NSString*)csvMessage;
-(void)_processJSONMessage:(NSString*)jsonMessage;
@end
