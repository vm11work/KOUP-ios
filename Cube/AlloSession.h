//
//  AlloCookies.h
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "Allo.h"
#import "DeviceInfo.h"

@class DeviceInfo;

@interface AlloSession : NSObject

+ (NSString*) get: (NSString*) name;
+ (void) set: (NSString*) name value: (NSString*) value;

+ (void) dump;
+ (void) rotate: (DeviceInfo*) info;

@end

