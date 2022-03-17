//
// NSString+Addtions.h
//

#import <WebKit/WebKit.h>

@interface WKWebView (SynchronousEvaluateJavaScript)
- (NSString*) eval: (NSString*) script;
@end

