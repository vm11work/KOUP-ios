//
//  AlloSQLite.h
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#import "Allo.h"

@interface AlloSQLite : NSObject

+ (void) create;

+ (NSString*) all: (NSString*) menu;
+ (NSString*) del: (NSString*) name;
+ (NSString*) get: (NSString*) name;
+ (NSString*) set: menu name: (NSString*) name data: (NSString*) data thumb: (NSString*) thumb;

+ (NSString*) submit: (NSString*) message;
+ (NSString*) list: (NSString*) menu last: (int) last limit: (int) limit;

@end

@interface NSString (SQLAddtions)

- (NSString*) quotes;
+ (NSString*) quotes: (NSString*) data;
- (NSString*) sqlescape;
+ (NSString*) sqlescape: (NSString*) data;

@end

