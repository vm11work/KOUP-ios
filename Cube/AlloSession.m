//
//  AlloCookies.m
//

#import "AlloSession.h"

@implementation AlloSession

+ (void) set: (NSString*) name value: (NSString*) value
{
    [Allo i: @"set @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject: name forKey: NSHTTPCookieName];
        [cookieProperties setObject: value forKey: NSHTTPCookieValue];
        [cookieProperties setObject: COOKIE forKey: NSHTTPCookieDomain];
        [cookieProperties setObject: COOKIE forKey: NSHTTPCookieOriginURL];
        [cookieProperties setObject: @"/" forKey: NSHTTPCookiePath];
        [cookieProperties setObject: @"0" forKey: NSHTTPCookieVersion];
        [cookieProperties setObject: [[NSDate date] dateByAddingTimeInterval: (365 * 60 * 60 * 24)] forKey: NSHTTPCookieExpires];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties: cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie: cookie];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

+ (NSString*) get: (NSString*) name
{
    [Allo i: @"get @%@", [[self class] description]];

    NSString* value = @"";

    @try
    {
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            if ([[cookie name] isEqualToString: name]) value = [cookie value];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    return value;
}

+ (void) rotate: (DeviceInfo*) info
{
    [Allo i: @"rotate @%@", [[self class] description]];

    @try
    {
        [self set: APPS value: APPS_VALUE];
        [self set: TYPE value: TYPE_VALUE];
        // 20200716 앱에서 간편 로긴 정보 등록하는 것은 없에기로 했고, 웹에서 직접 등록 / 해지 처리하기로함 (이대영 부장, 정용희 과장)
        [self set: GUID value: [info guid]];
        // 최초 일반 로그인 이후 쿠키값 설정함
        // if ([info simpleStatus]) [self set: GUID value: [info guid]];
        // 디버깅 [self set: GUID value: [info guid]];

        // 20200826 김경구님 요청으로 향후를 위해 버전 및 빌드 정보 추가함
        [self set: BUILD value: [info build]];
        [self set: VERSION value: [info version]];

        // WKWebView 에서 쿠키 활용을 위해 통합요 (UIWebView 버전과 호환을 위함)
        if (@available (iOS 11.0, *))
        {
            [WKWebsiteDataStore.defaultDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull result) {
                for (NSHTTPCookie *cookie in result)
                {
                    [AlloSession set: [cookie name] value: [cookie value]];
                }
            }];
        }
        
        // 주석요 (필요시 디버깅)
        // [self dump];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

+ (void) dump
{
    [Allo i: @"dump @%@", [[self class] description]];

    @try
    {
        for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) [Allo i: @"cookie : %@", [cookie description]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

@end
