//
// NSString+Addtions.m
//

#import "WKWebView+Addtions.h"

@implementation WKWebView (SynchronousEvaluateJavaScript)

- (NSString*) eval: (NSString*) script
{
    __block BOOL finished = NO;
    __block NSString* response = nil;

    [self evaluateJavaScript: script completionHandler: ^(id result, NSError *error) {
        if (nil == error)
        {
            if (nil != result)
            {
                response = [NSString stringWithFormat:@"%@", result];
            }
        }
        else
        {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    while (!finished) [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];

    return response;
}
@end
