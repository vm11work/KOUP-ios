//
// NSString+Addtions.h
//

#import <Foundation/Foundation.h>

@interface NSString (UserAddtions)

- (BOOL) isEmpty;
- (BOOL) contains: (NSString*) text insensitive: (BOOL) needed;
- (int) indexOf: (NSString*) text;

- (NSString*) trim;
- (NSString*) quotes;
+ (NSString*) quotes: (NSString*) data;
- (NSString*) urlencode;
+ (NSString*) urlencode: (NSString*) data;
- (NSString*) sqlescape;
+ (NSString*) sqlescape: (NSString*) data;
- (NSString*) jsonescape;
+ (NSString*) jsonescape: (NSString*) data;

@end
