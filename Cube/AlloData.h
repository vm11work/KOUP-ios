//
//  AlloData.h
//

#import <Foundation/Foundation.h>

#import "Allo.h"

#define CVERSION @"v1.0.0"
#define CUSERAGENT @"CafeWill AlloData v1.0.0"
#define CSLEEPINTERVAL 0.01

#define FORMDATA_CRLF @"\r\n"
#define FORMDATA_HYPHENS @"--"
#define FORMDATA_BOUNDARY @"@----------123456789@987654321----------@"
// #define FORMDATA_BOUNDARY @"#----------123456789#987654321----------#"

@interface AlloData : NSURLConnection
{
	NSString* name;
	NSString* version;
    NSMutableData* receivedData;
    BOOL receivedDone;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* version;
@property (nonatomic, retain) NSMutableData* receivedData;
@property (readwrite) BOOL receivedDone;

- (NSData*) get: (NSString*) url;
- (NSData*) post: (NSString*) url json: (NSString*) data;
- (NSData*) post: (NSString*) url data: (NSMutableData*) data;

@end

