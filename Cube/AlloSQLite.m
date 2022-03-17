//
//  AlloSQLite.m
//

#import "AlloSQLite.h"

@implementation AlloSQLite

+ (void) create
{
    [Allo i: @"create @%@", [[self class] description]];
    
    @try
    {
        /* data schema
            seq : 자동순번
            name : 유니크키
            date : 등록일시
            menu :
                시정조치요청 : correct-ask
                시정조치결과 : correct-report
                예방조치요청 : prevent-ask
                예방조치결과 : prevent-report
            data : json { title, content, deadline, image, voice, ... 필요시 추가하여 활용함 }
            thumb : 대표 이미지 썸네일 base64 encode 정보
         */

        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];

        sqlite3* database;
        NSString* create = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ ( seq INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, menu TEXT, name TEXT UNIQUE, data TEXT, thumb TEXT );", DB_TABLE];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            [Allo i: @"sqlite3_open success! [%@]", databasePath];
            
            if (SQLITE_OK == sqlite3_exec (database, [create UTF8String], NULL, NULL, NULL))
            {
                [Allo i: @"sqlite3_prepare success! [%@]", create];
            }
            else
            {
                [Allo i: @"sqlite3_prepare failure! [%@]", create];
            }
            sqlite3_close (database);
            database = nil;
        }
        else
        {
            [Allo i: @"sqlite3_open failure! [%@]", databasePath];
            sqlite3_close (database);
            database = nil;
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - SQLite Native API

+ (NSString*) del: (NSString*) list
{
    [Allo i: @"del @%@", [[self class] description]];
    
    BOOL status = NO;
    NSString* result = @"";
    NSString* message = @"no message";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    @try
    {
        sqlite3* database;
        sqlite3_stmt* statement;
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];

        NSString* delete = [NSString stringWithFormat: @"DELETE FROM %@ WHERE name in (%@)", DB_TABLE, list];
        // 20200724 모두 삭제하는 처리가 필요하다면 name = * 를 받아서 처리요
        if ([@"*" isEqualToString: list]) delete = [NSString stringWithFormat: @"DELETE FROM %@", DB_TABLE];
        message = [NSString stringWithFormat: @"del [%@]", delete];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            if (SQLITE_OK == sqlite3_prepare (database, [delete UTF8String], -1, &statement, NULL))
            {
                if (SQLITE_DONE == sqlite3_step (statement))
                {
                    status = YES;
                    [Allo i: @"sqlite3_step success! [%@]", delete];
                }
                else
                {
                    message = [NSString stringWithFormat: @"sqlite3_step failure [%@]", delete];
                    [Allo i: message];
                }
                sqlite3_finalize (statement);
            }
            else
            {
                message = [NSString stringWithFormat: @"sqlite3_prepare failure [%@]", delete];
                [Allo i: message];
            }
        }
        else
        {
            message = [NSString stringWithFormat: @"sqlite3_open failure [%@]", delete];
            [Allo i: message];
        }
        sqlite3_close (database);
        database = nil;
    } @catch (NSException* e) { message = [e reason]; NSLog ( @"error : %@ %@", [e name], [e reason]); }

    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

+ (NSString*) get: (NSString*) name
{
    [Allo i: @"get @%@", [[self class] description]];
    
    BOOL status = NO;
    NSString* result = @"";
    NSString* message = @"no message";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    @try
    {
        sqlite3* database;
        sqlite3_stmt* statement;
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];

        NSString* select = [NSString stringWithFormat: @"SELECT seq, date, menu, name, data, thumb FROM %@ WHERE name = %@", DB_TABLE, [name quotes]];
        message = [NSString stringWithFormat: @"get [%@]", select];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            if (SQLITE_OK == sqlite3_prepare (database, [select UTF8String], -1, &statement, NULL))
            {
                if (SQLITE_ROW == sqlite3_step (statement))
                {
                    status = YES;
                    int seq = (int) sqlite3_column_int (statement, 0);
                    NSString* date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 1)];
                    NSString* each = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 2)];
                    NSString* name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 3)];
                    NSString* data = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 4)];
                    NSString* thumb = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 5)];

                    NSMutableDictionary* line = [NSMutableDictionary dictionary];
                    [line setObject: [NSNumber numberWithInt: seq] forKey: @"seq"];
                    // [line setObject: [NSString stringWithFormat: @"%d", seq] forKey: @"seq"];
                    [line setObject: date forKey: @"date"];
                    [line setObject: each forKey: @"menu"];
                    [line setObject: name forKey: @"name"];
                    [line setObject: data forKey: @"data"];
                    [line setObject: thumb forKey: @"thumb"];
                    [response addObject: line];
                    
                    [Allo i: @"check data [%d][%@][%@][%@][%@]", seq, date, each, name, data];
                }
                else
                {
                    message = [NSString stringWithFormat: @"sqlite3_step failure [%@]", select];
                    [Allo i: message];
                }
                sqlite3_finalize (statement);
            }
            else
            {
                message = [NSString stringWithFormat: @"sqlite3_prepare failure [%@]", select];
                [Allo i: message];
            }
        }
        else
        {
            message = [NSString stringWithFormat: @"sqlite3_open failure [%@]", select];
            [Allo i: message];
        }
        sqlite3_close (database);
        database = nil;
    } @catch (NSException* e) { message = [e reason]; NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

+ (NSString*) set: (NSString*) menu name: (NSString*) name data: (NSString*) data thumb: (NSString*) thumb
{
    [Allo i: @"set @%@", [[self class] description]];
    
    BOOL status = NO;
    NSString* result = @"";
    NSString* message = @"no message";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    @try
    {
        if (nil == menu) menu = @"";
        if (nil == name) name = @"";
        if (nil == data) data = @"";
        if (nil == thumb) thumb = @"";

        // 20200805 \n 제거요
        data = [data stringByReplacingOccurrencesOfString: @"\n" withString: @""];
        thumb = [thumb stringByReplacingOccurrencesOfString: @"\n" withString: @""];

        sqlite3* database;
        sqlite3_stmt* statement;
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];
        
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate* now = [[NSDate alloc] init];
        NSString* date = [format stringFromDate: now];
        NSString* upsert = [NSString stringWithFormat: @"INSERT OR REPLACE INTO %@ (date, menu, name, data, thumb) VALUES (%@, %@, %@, %@, %@)", DB_TABLE, [date sqlescape], [menu sqlescape], [name sqlescape], [data sqlescape], [thumb sqlescape]];
        message = [NSString stringWithFormat: @"set [%@]", upsert];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            if (SQLITE_OK == sqlite3_prepare (database, [upsert UTF8String], -1, &statement, NULL))
            {
                if (SQLITE_DONE == sqlite3_step (statement))
                {
                    status = YES;
                }
                else
                {
                    message = [NSString stringWithFormat: @"sqlite3_step failure [%@]", upsert];
                    [Allo i: message];
                }
                sqlite3_finalize (statement);
            }
            else
            {
                message = [NSString stringWithFormat: @"sqlite3_prepare failure [%@]", upsert];
                [Allo i: message];
            }
        }
        else
        {
            message = [NSString stringWithFormat: @"sqlite3_open failure [%@]", upsert];
            [Allo i: message];
        }
        sqlite3_close (database);
        database = nil;
    } @catch (NSException* e) { message = [e reason]; NSLog ( @"error : %@ %@", [e name], [e reason]); }

    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

+ (NSString*) all: (NSString*) menu
{
    [Allo i: @"all @%@", [[self class] description]];
    
    BOOL status = NO;
    NSString* result = @"";
    NSString* message = @"no message";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    @try
    {
        sqlite3* database;
        sqlite3_stmt* statement;
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];
        
        NSString* whereMenu = @"";
        if (nil != menu) whereMenu = [NSString stringWithFormat: @" menu = %@ ", [menu quotes]];
        NSString* whereClause = @"";
        if (0 < [whereMenu length]) whereClause = [NSString stringWithFormat: @" WHERE %@ ", whereMenu];
        NSString* orderClause = @" ORDER BY seq DESC ";

        NSString* select = [NSString stringWithFormat: @"SELECT seq, date, menu, name, data, thumb FROM %@ %@ %@", DB_TABLE, whereClause, orderClause];
        message = [NSString stringWithFormat: @"all [%@]", select];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            if (SQLITE_OK == sqlite3_prepare (database, [select UTF8String], -1, &statement, NULL))
            {
                status = YES;
                while (SQLITE_ROW == sqlite3_step (statement))
                {
                    int seq = (int) sqlite3_column_int (statement, 0);
                    NSString* date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 1)];
                    NSString* each = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 2)];
                    NSString* name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 3)];
                    NSString* data = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 4)];
                    NSString* thumb = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 5)];

                    NSMutableDictionary* line = [NSMutableDictionary dictionary];
                    [line setObject: [NSNumber numberWithInt: seq] forKey: @"seq"];
                    [line setObject: date forKey: @"date"];
                    [line setObject: each forKey: @"menu"];
                    [line setObject: name forKey: @"name"];
                    [line setObject: data forKey: @"data"];
                    [line setObject: thumb forKey: @"thumb"];
                    [response addObject: line];

                    [Allo i: @"check data [%d][%@][%@][%@][%@]", seq, date, each, name, data];
                }
                sqlite3_finalize (statement);
            }
            else
            {
                message = [NSString stringWithFormat: @"sqlite3_prepare failure [%@]", select];
                [Allo i: message];
            }
        }
        else
        {
            message = [NSString stringWithFormat: @"sqlite3_open failure [%@]", select];
            [Allo i: message];
        }
        sqlite3_close (database);
        database = nil;
    } @catch (NSException* e) { message = [e reason]; NSLog ( @"error : %@ %@", [e name], [e reason]); }

    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

+ (NSString*) list: (NSString*) menu last: (int) last limit: (int) limit
{
    [Allo i: @"list @%@", [[self class] description]];
    
    BOOL status = NO;
    NSString* result = @"";
    NSString* message = @"no message";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    @try
    {
        if (0 > last) last = 0;
        if (0 > limit) limit = 0;

        sqlite3* database;
        sqlite3_stmt* statement;
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* databasePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: DB_NAME]];
        
        NSString* whereMenu = @"";
        if (nil != menu) whereMenu = [NSString stringWithFormat: @" menu = %@ ", [menu quotes]];
        NSString* whereLast = @"";
        if (0 < last)
        {
            whereLast = [NSString stringWithFormat: @" seq < %d ", last];
            if (0 < [whereMenu length]) whereLast = [NSString stringWithFormat: @" and seq < %d ", last];
        }
        NSString* whereClause = @"";
        if (0 < [whereMenu length] || 0 < [whereLast length]) whereClause = [NSString stringWithFormat: @" WHERE %@%@ ", whereMenu, whereLast];
        NSString* orderClause = @" ORDER BY seq DESC ";
        if (0 < limit) orderClause = [NSString stringWithFormat: @" ORDER BY seq DESC LIMIT 0, %d ", limit];

        NSString* select = [NSString stringWithFormat: @"SELECT seq, date, menu, name, data FROM %@ %@ %@", DB_TABLE, whereClause, orderClause];
        message = [NSString stringWithFormat: @"list [%@]", select];

        if (SQLITE_OK == sqlite3_open ([databasePath UTF8String], &database))
        {
            if (SQLITE_OK == sqlite3_prepare (database, [select UTF8String], -1, &statement, NULL))
            {
                status = YES;
                while (SQLITE_ROW == sqlite3_step (statement))
                {
                    int seq = (int) sqlite3_column_int (statement, 0);
                    NSString* date = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 1)];
                    NSString* each = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 2)];
                    NSString* name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 3)];
                    NSString* data = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text (statement, 4)];
                    
                    NSMutableDictionary* line = [NSMutableDictionary dictionary];
                    [line setObject: [NSNumber numberWithInt: seq] forKey: @"seq"];
                    [line setObject: date forKey: @"date"];
                    [line setObject: each forKey: @"menu"];
                    [line setObject: name forKey: @"name"];
                    [line setObject: data forKey: @"data"];
                    [response addObject: line];

                    [Allo i: @"check data [%d][%@][%@][%@][%@]", seq, date, each, name, data];
                }
                sqlite3_finalize (statement);
            }
            else
            {
                message = [NSString stringWithFormat: @"sqlite3_prepare failure [%@]", select];
                [Allo i: message];
            }
        }
        else
        {
            message = [NSString stringWithFormat: @"sqlite3_open failure [%@]", select];
            [Allo i: message];
        }
        sqlite3_close (database);
        database = nil;
    } @catch (NSException* e) { message = [e reason]; NSLog ( @"error : %@ %@", [e name], [e reason]); }

    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

+ (NSString*) submit: (NSString*) message
{
    [Allo i: @"submit @%@", [[self class] description]];
    
    BOOL status = YES;
    NSString* result = @"";
    NSMutableArray* response = [[NSMutableArray alloc] init];

    NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
    [mutable setObject: (status ? [NSNumber numberWithBool: TRUE] : [NSNumber numberWithBool: FALSE]) forKey: @"status"];
    [mutable setObject: message forKey: @"message"];
    [mutable setObject: response forKey: @"response"];

    NSError* error;
    NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: &error];
    result = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

    [Allo i: @"check result [%@]", result];

    return result;
}

@end

#pragma mark - NSString SQLite Addtions

@implementation NSString (SQLAddtions)

- (NSString*) quotes
{
    NSString* swap = self;
    NSString* escape = [NSString stringWithFormat: @"'%@'", swap];
    return (escape);
}

+ (NSString*) quotes: (NSString*) data
{
    NSString* swap = data;
    NSString* escape = [NSString stringWithFormat: @"'%@'", swap];
    return (escape);
}

- (NSString*) sqlescape
{
    NSString* swap = self;
    swap = [swap stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
    NSString* escape = [NSString stringWithFormat: @"'%@'", swap];
    return (escape);
}

+ (NSString*) sqlescape: (NSString*) data
{
    NSString* swap = data;
    swap = [swap stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
    NSString* escape = [NSString stringWithFormat: @"'%@'", swap];
    return (escape);
}

@end
