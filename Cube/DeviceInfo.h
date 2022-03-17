//
//  ExtraInfo.h
//

#import <Foundation/Foundation.h>
#import "Allo.h"

@class DeviceInfo;

@interface DeviceInfo : NSObject

@property (readwrite) BOOL deviceStatus;
@property (readwrite) BOOL simpleStatus;
@property (nonatomic, retain) NSString* apps;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* user;
@property (nonatomic, retain) NSString* role;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* model;
@property (nonatomic, retain) NSString* number;
@property (nonatomic, retain) NSString* carrier;
@property (nonatomic, retain) NSString* version;
@property (nonatomic, retain) NSString* osVersion;
@property (nonatomic, retain) NSString* imei;
@property (nonatomic, retain) NSString* build;
@property (nonatomic, retain) NSString* manufacturer;

- (void) dump;

@end

