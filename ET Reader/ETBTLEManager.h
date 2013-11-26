//
//  ETBTLEManager.h
//  ET Reader
//
//  Created by Alexander Hoekje List on 11/24/13.
//  Copyright (c) 2013 ET Ears Group, Inc (MIT LICENSE). All rights reserved.
//

@class ETBTLEManager;

@protocol ETBTLEManagerDelegate <NSObject>
-(void ) managerYieldedData:(NSData*)yieldedData withManager:(ETBTLEManager*)manager;


@optional // and in fact, unimplimented!
//for peripherals
-(void ) managerDidConnect:(ETBTLEManager*)manager;
-(void ) managerFailedConnect:(ETBTLEManager*)manager withError:(NSError*)error;
-(void ) managerDidCloseConnection:(ETBTLEManager*)manager withError:(NSError*)error;


//generally
-(void ) managerDidStart:(ETBTLEManager*)manager;
-(void ) managerFailedStart:(ETBTLEManager*)manager withError:(NSError*)error;
-(void ) managerDidStop:(ETBTLEManager*)manager;
@end
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ETBTLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id<ETBTLEManagerDelegate> delegate; 

@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) NSMutableSet *peripherals;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

-(void)start;
-(void) connectPeripheral;
-(void) disconnectPeripheral;


+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;
+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

@end
