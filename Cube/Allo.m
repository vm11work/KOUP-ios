//
//  Allo.m
//

#import "Allo.h"

@implementation Allo

+ (void) i: (NSString*) format, ...
{
    @try
    {
        if (DEBUG_ECHO)
        {
            va_list args;
            va_start (args, format);
            NSString* message = [[NSString alloc] initWithFormat: format arguments: args];
            va_end (args);
            NSLog (@"%@ : %@", CUBE, message);
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

+ (void) t: (NSString*) format, ...
{
    @try
    {
        if (DEBUG_ECHO)
        {
            va_list args;
            va_start (args, format);
            NSString* message = [[NSString alloc] initWithFormat: format arguments: args];
            va_end (args);
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [controller.view makeToast: message];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

+ (void) toast: (NSString*) format, ...
{
    @try
    {
        va_list args;
        va_start (args, format);
        NSString* message = [[NSString alloc] initWithFormat: format arguments: args];
        va_end (args);
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        [controller.view makeToast: message];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
    
@end
