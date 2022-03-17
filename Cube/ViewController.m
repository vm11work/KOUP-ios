//
//  ViewController.m
//

#import "ViewController.h"
@import FirebaseCore;
@import FirebaseFirestore;

@interface ViewController ()
//@property (nonatomic, readwrite) FIRFirestore *db;
@end


@implementation ViewController

static Reachability* cnn;

@synthesize isOffline;
@synthesize topStatus;
@synthesize scrollStatus;

@synthesize web;
@synthesize refreshControl;

@synthesize deviceInfo;
@synthesize indicator;
@synthesize imageInfo;
@synthesize voiceInfo;

@synthesize player;

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.db = [FIRFirestore firestore];

    [Allo i: @"viewDidLoad @%@", [[self class] description]];

    [Allo i: @"check define COOKIE [%@]", COOKIE];
    [Allo i: @"check define SITE_ONLINE [%@]", SITE_ONLINE];
    [Allo i: @"check define SITE_OFFLINE [%@]", SITE_OFFLINE];

    @try
    {
        [self.view setAutoresizesSubviews: YES];
        [self.view setBackgroundColor: [UIColor whiteColor]];
        [self.view setAutoresizingMask: (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];

        // 향후 다크모드 커스텀 필요시 활용요
        if (@available(iOS 12.0, *))
        {
            if (UIUserInterfaceStyleDark == self.traitCollection.userInterfaceStyle)
            {
                [Allo i: @"viewDidLoad => UIUserInterfaceStyleDark"];
            }
            else
            {
                [Allo i: @"viewDidLoad => UIUserInterfaceStyleLight"];
            }
        } else { [Allo i: @"viewDidLoad => UIUserInterfaceStyleDefault"]; }

        // 기본 백그라운드 설정함
        // (노치 영역 포함, 흰색 컬러는 다크 모드시 동일 컬러로 인해 콘텐츠가 안보일 수 있음)
        [self.view setBackgroundColor: UIColorFromRGB (0x344c72)];

        cnn = [Reachability reachabilityForInternetConnection];
        [cnn startNotifier];

        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = true;
        configuration.mediaTypesRequiringUserActionForPlayback = true;
        [configuration.preferences setValue: @"TRUE" forKey: @"allowFileAccessFromFileURLs"];
        web = [[WKWebView alloc] initWithFrame: [self.view bounds] configuration: configuration];

        // web = [[WKWebView alloc] initWithFrame: [self.view bounds]];
        [web setAutoresizingMask: (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [web setHidden: NO];
        [web setUIDelegate: self];
        [web setNavigationDelegate: self];
        [web setBackgroundColor: [UIColor whiteColor]];
        [web setAutoresizesSubviews: YES];
        [web setMultipleTouchEnabled: YES];
        [web setUserInteractionEnabled: YES];
        [web setAllowsLinkPreview: NO]; // long press disabled (이미지 다운로드 방지용)
        [web setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [web.scrollView setDelegate: self];
        [web.scrollView setDecelerationRate: UIScrollViewDecelerationRateNormal];
        [self.view addSubview: web];
        
        web.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 11, *))
        {
            UILayoutGuide* guide = self.view.safeAreaLayoutGuide;
            [web.topAnchor constraintEqualToAnchor: guide.topAnchor].active = YES;
            [web.bottomAnchor constraintEqualToAnchor: guide.bottomAnchor].active = YES;
            [web.leadingAnchor constraintEqualToAnchor: guide.leadingAnchor].active = YES;
            [web.trailingAnchor constraintEqualToAnchor: guide.trailingAnchor].active = YES;
        }
        else
        {
            UILayoutGuide* margins = self.view.layoutMarginsGuide;
            [web.leadingAnchor constraintEqualToAnchor: margins.leadingAnchor].active = YES;
            [web.trailingAnchor constraintEqualToAnchor: margins.trailingAnchor].active = YES;
            [web.topAnchor constraintEqualToAnchor: self.topLayoutGuide.bottomAnchor].active = YES;
            [web.bottomAnchor constraintEqualToAnchor: self.bottomLayoutGuide.topAnchor].active = YES;
        }
        [self.view layoutIfNeeded];
        // [self.web layoutIfNeeded];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl setTintColor: [UIColor whiteColor]];
        [self.refreshControl setBackgroundColor: UIColorFromRGB (0x344c72)];
        [self.refreshControl addTarget: self action: @selector (actionHitTopDelay) forControlEvents: UIControlEventValueChanged];
        [web.scrollView addSubview: self.refreshControl];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        if (@available(iOS 13.0, *))
        {
            [indicator setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleLarge];
        }
        [indicator setHidden: YES];
        [indicator stopAnimating];
        [indicator setCenter: [self.view center]];
        // [indicator setColor: [UIColor blackColor]];
        [indicator setColor: UIColorFromRGB(0x344c72)];
        [self.view addSubview: indicator];
        
        // 좌우로 스크롤해서 이전 다음 페이지 이동용 (iphone 은 android 처럼 back 버튼이 없음)
        UISwipeGestureRecognizer* swipeGesture;
        swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget: self action: @selector (handleSwipeGesture:)];
        swipeGesture.delegate = self;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [web addGestureRecognizer: swipeGesture];
        swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget: self action: @selector (handleSwipeGesture:)];
        swipeGesture.delegate = self;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [web addGestureRecognizer: swipeGesture];

        deviceInfo = [[DeviceInfo alloc] init];
        [self rotateInfo];
        [AlloSession rotate: [self deviceInfo]];
        [self rotateFirebase];

        // 오프라인 모드 초기화
        // (단, 페이지 로딩시 디바이스가 오프라인 이라면 다시 오프라인 모드 설정됨)
        isOffline = [self getOffline];
        if (isOffline) { [self loadOffline]; } else { [self loadOnline]; }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) setOffline: (BOOL) status
{
    [Allo i: @"setOffline @%@", [[self class] description]];

    @try
    {
        [[NSUserDefaults standardUserDefaults] setBool: status forKey: OFFLINE];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (BOOL) getOffline
{
    [Allo i: @"getOffline @%@", [[self class] description]];

    BOOL status = false;
    @try
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey: OFFLINE]) status = [[NSUserDefaults standardUserDefaults] boolForKey: OFFLINE];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
    return status;
}

- (void) rotateInfo
{
    [Allo i: @"rotateInfo @%@", [[self class] description]];

    @try
    {
        [deviceInfo setApps: APPS_VALUE];
        [deviceInfo setType: TYPE_VALUE];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* value;
        NSString* guid = @"sims";
        value = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey: GUID]];
        if (nil != value)
        {
            guid = value;
        }
        else
        {
        // #if !(TARGET_IPHONE_SIMULATOR)
            guid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        // #endif
            [defaults setObject: [NSKeyedArchiver archivedDataWithRootObject: guid] forKey: GUID];
        }
        [deviceInfo setGuid: guid];
        if (nil != [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey: GUID_STATUS]]) [deviceInfo setSimpleStatus: YES];
        
        NSString* model = @"";
        if (nil != [[UIDevice currentDevice] model]) model = [[UIDevice currentDevice] model];
        [deviceInfo setModel: model];
        NSString* build = @"";
        if (nil != [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]) build = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
        [deviceInfo setBuild: build];
        
        NSString* version = @"";
        if (nil != [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"]) version = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
        [deviceInfo setVersion: version];
        
        NSString* osVersion = @"";
        if (nil != [[UIDevice currentDevice] systemVersion]) osVersion = [[UIDevice currentDevice] systemVersion];
        [deviceInfo setOsVersion: osVersion];

        NSString* carrier = @"";
        CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrierInfo;
        if (@available(iOS 12, *))
        {
            if (@available(iOS 12.1, *))
            {
                NSDictionary<NSString *, CTCarrier *> *carriers = [telephonyNetworkInfo serviceSubscriberCellularProviders];
                carrierInfo = [self getCarrier: carriers];
            }
            else if (@available(iOS 12, *))
            {
                NSDictionary<NSString *, CTCarrier *> *carriers = [telephonyNetworkInfo valueForKey: @"serviceSubscriberCellularProvider"];
                carrierInfo = [self getCarrier: carriers];
            }
        }
        if (nil != [carrierInfo carrierName]) carrier = [carrierInfo carrierName];
        [deviceInfo setCarrier: carrier];

        // 디버깅
        // [deviceInfo dump];

        [Allo i: @"check device info [%@][%@][%@]", [deviceInfo guid], [deviceInfo version], [deviceInfo build]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) rotateFirebase
{
    [Allo i: @"rotateFirebase @%@", [[self class] description]];

    @try
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                              selector: @selector(rotateToken:)
                                              name: @"FCMToken" object: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
- (void) rotateStatus
{
    [Allo i: @"rotateStatus @%@", [[self class] description]];

    @try
    {
        /*
        69  : song.y.s  송요순 (현장소장)
        126 : shinjk    신종길 (부장)
        184 : jerry0118 정동균 (차장)
        */
        // NSString* user = @"20200625"; // 테스트
        
        NSString* user = [AlloSession get: USER];
        NSString* role = [AlloSession get: ROLE];

        [Allo i: @"check login user => [%@][%@]", user, role];

        if (![user isEmpty])
        {
            [deviceInfo setUser: user];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* value = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey: USER]];
            if (nil == value)
            {
                [Allo i: @"check login 신규 로긴 [신규 : %@]", user];
                [defaults setObject: [NSKeyedArchiver archivedDataWithRootObject: user] forKey: USER];
            }
            if (nil != value)
            {
                if (![user isEqual: value])
                {
                    [Allo i: @"check login 교체 로긴 [신규 : %@][이전 : %@]", user, value];
                    [deviceInfo setDeviceStatus: NO];
                    [defaults setObject: [NSKeyedArchiver archivedDataWithRootObject: user] forKey: USER];
                }
            }

            // 오프라인 모드 페이지 구성요 역할 정보도 함께 설정요 (1: 감리, 2: 협력업체, 3: KCC)
            if (![role isEmpty])
            {
                [deviceInfo setRole: role];
                [defaults setObject: [NSKeyedArchiver archivedDataWithRootObject: role] forKey: ROLE];
            }
        }

        // 20200716 앱에서 간편 로긴 정보 등록하는 것은 없에기로 했고, 웹에서 직접 등록 / 해지 처리하기로함 (이대영 부장, 정용희 과장)
        // 로그인 및 GUID 정보가 유효하면 서버에 1회 등록함 (앱 설치후 최초 로그인 후 1번만 등록함)
        /*
        if (![info simpleStatus] && ![[info user] isEmpty])
        {
            [Allo i: @"check login registSimple [등록 : %@]", user];
            [info setSimpleStatus: YES];
            CGFloat delay = 3.200;
            // [self registSimple];
            [self performSelector: @selector (registSimple) withObject: nil afterDelay: delay];
        }
        */

        // 로그인 및 푸시 알림 토큰이 유효하면 서버에 1회 등록함 (멀티 로그인의 경우 계정이 바뀌면 등록함)
        // 20200805 동일 사용자 SeqNo 에 대해서 upsert 처리함, 이대영 부장 및 클라이언트 협의후 적용함
        // (KccApiMapper.xml => upsertUserDeviceInfo)
        if (![deviceInfo deviceStatus] && ![[deviceInfo user] isEmpty] && ![[deviceInfo token] isEmpty])
        {
            [Allo i: @"check login registInfo [등록 : %@]", user];
            CGFloat delay = 3.200;
            [self performSelector: @selector (registInfo) withObject: nil afterDelay: delay];
            [deviceInfo setDeviceStatus: YES];
        }
        
        
        
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}


- (void) rotateToken:(NSNotification *) notification {
    [Allo i: @"rotateToken [%@] @%@", [notification userInfo][@"token"], [[self class] description]];

    @try
    {
        NSString* token = [notification userInfo][@"token"];
        [deviceInfo setToken: token];

        // 20200813 사용하지 않음 (테스트 용도)
        // CGFloat delay = 3.200;
        // [self registDevice];
        // [self performSelector: @selector (registDevice) withObject: nil afterDelay: delay];

        //20211106 김건엽 추가.디바이스의 token정보 확인을 위해 firestore를 사용하였다.추후 삭제가능.)
//        [[[self.db collectionWithPath:@"Device"] documentWithPath:[deviceInfo guid]] setData:@{ @"token": token }];

        
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) registDevice
{
    [Allo i: @"registDevice @%@", [[self class] description]];
    
    @try
    {
        // KOUP 에서는 rotateStatus 및 registInfo 사용함
        
        // 사이트 개발 완료되기 전까지는 setdata 로 등록된 푸시 알림 토큰으로 테스트
        NSString* request = [NSString stringWithFormat:  @"%@?type=i&token=%@&model=%@&carrier=%@",
                             SITE_SET_DATA,
                             [NSString urlencode: [deviceInfo token]],
                             [NSString urlencode: [deviceInfo model]],
                             [NSString urlencode: [deviceInfo carrier]]];
        
        [Allo i: @"check request [%@]", request];

        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net get: request];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
        [Allo i: @"check response [%@]", responseText];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) registInfo
{
    [Allo i: @"registInfo @%@", [[self class] description]];

    @try
    {
        NSString* request = [NSString stringWithFormat:  @"%@?user=%@&type=%@&token=%@&version=%@&build=%@&number=%@&imei=%@&model=%@&carrier=%@&manufacturer=%@&sender=%@",
                             SITE_SET_USERDEVICE,
                             [deviceInfo user],
                             [[deviceInfo type] urlencode],
                             [[deviceInfo token] urlencode],
                             [[deviceInfo version] urlencode],
                             [[deviceInfo build] urlencode],
                             [[deviceInfo number] urlencode],
                             [[deviceInfo imei] urlencode],
                             [[deviceInfo model] urlencode],
                             [[deviceInfo carrier] urlencode],
                             [[deviceInfo manufacturer] urlencode],
                             TYPE_SENDER];
        
        [Allo i: @"check request [%@]", request];
        
        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net get: request];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
        [Allo i: @"check response [%@]", responseText];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) registSimple
{
    [Allo i: @"registSimple @%@", [[self class] description]];

    @try
    {
        NSString* request = [NSString stringWithFormat:  @"%@?user=%@&guid=%@",
                             SITE_SET_SIMPLELOGIN,
                             [deviceInfo user],
                             [[deviceInfo guid] urlencode]];
        
        [Allo i: @"check request [%@]", request];
        
        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net get: request];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
        [Allo i: @"check response [%@]", responseText];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) rotateNotification: (NSDictionary*) info
{
    [Allo i: @"rotateNotification @%@", [[self class] description]];

    @try
    {
        // 푸시 알림 기본 데이터
        NSDictionary* aps = [info objectForKey: @"aps"];
        NSDictionary* alert = [aps objectForKey: @"alert"];
        NSString* title = [alert objectForKey: @"title"];
        NSString* message = [alert objectForKey: @"body"];
        
        // 추가 데이터 (바로가기 링크)
        NSString* link = [info objectForKey: @"link"];

        [Allo i: @"check notification => [%@][%d][%d]", title, message, link];

        if ([link hasPrefix: SITE_ONLINE])
        {
            [self loadLink: link];
        }
        else
        {
            // 외부 링크라면 브라우저 새창으로 띄움
            [self openLink: link];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) showIndicator
{
    [Allo i: @"showIndicator @%@", [[self class] description]];

    @try
    {
        [indicator setHidden: NO];
        [indicator startAnimating];
        
        // 인디케이터는 1200 후 자동으로 없어짐 (로드가 빨리된다면 그전에 onPageFinished 에서 처리됨)
        // 간혹 웹페이지에서 로드 불가한 (css, js 등) 리소스로 인해 계속 로딩중 상태가 지속되는걸 방지하기 위함
        CGFloat delay = 1.500;
        [self performSelector: @selector (hideIndicator) withObject: nil afterDelay: delay];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) hideIndicator
{
    [Allo i: @"hideIndicator @%@", [[self class] description]];

    @try
    {
        [indicator setHidden: YES];
        [indicator stopAnimating];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - WKWebView UIDelegate

// https://developer.apple.com/documentation/webkit/wkuidelegate?language=objc
// https://developer.apple.com/documentation/webkit/wkuidelegate/1641952-webview?language=objc
// https://sourcegraph.com/github.com/WebKit/webkit/-/blob/Source/WebKit/UIProcess/API/Cocoa/WKUIDelegate.h
// #if !TARGET_OS_IPHONE (... ...) #endif 로 구현되어 있음 (아이폰에선 지원 안됨) 
- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> *URLs))completionHandler;
{
    [Allo i: @"webView / runOpenPanelWithParameters / initiatedByFrame / completionHandler @%@", [[self class] description]];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [Allo i: @"webView / runJavaScriptAlertPanelWithMessage / initiatedByFrame / completionHandler @%@", [[self class] description]];
    
    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString (@"title_alert", @"Alert") message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler();
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    [Allo i: @"webView / runJavaScriptConfirmPanelWithMessage / initiatedByFrame / completionHandler @%@", [[self class] description]];

    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString (@"title_confirm", @"Confirm") message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completionHandler(YES);
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(NO);
        }]];
        [self presentViewController: alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    [Allo i: @"webView / runJavaScriptTextInputPanelWithPrompt / defaultText / initiatedByFrame / completionHandler @%@", [[self class] description]];

    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
            completionHandler(input);
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(nil);
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - WKWebView WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [Allo i: @"webView / didStartProvisionalNavigation [%@] @%@", web.URL, [[self class] description]];
    
    @try
    {
        // 20200720 온라인 / 오프라인 케이스 정리요
        // 오프라인에서 온라인 전환은 명시적으로 메뉴를 터치하여 전환요
        // 오프라인 플래그가 설정 되어 있다면 온라인 상태더라도 오프라인 모드로 유지요
        // (오프라인 플래그가 설정 되어 있지 않은) 온라인 상태에서 오프라인이 되면 오프라인 모드 실행 및 오프라인 플래그 설정요

        // 오프라인 상태가 되면 오프라인 페이지 로딩함 (단, 이미 오프라인 상태라면 스킵함)
        if (isOffline) if (nil != player) [player stop];
        if (![self isOnline] && !isOffline) [self loadOffline];

        [self showIndicator];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [Allo i: @"webView / didFinishNavigation [%@] @%@", web.URL, [[self class] description]];
    
    @try
    {
        // 오프라인 상태가 되면 오프라인 페이지 로딩함 (단, 이미 오프라인 상태라면 스킵함)
        if (![self isOnline] && !isOffline) [self loadOffline];

        
        //        [self rotateStatus];
        //최초로그인직후에 약간의 딜레이가 있어야 쿠키에서 유저ID를 가져올 수 있다. 20211230 김건엽 수정.
        [self performSelector:@selector(rotateStatus) withObject:nil afterDelay:0.1];

        // 20200813 이전, 다음 등 페이지 이동시 인디케이터가 잠깐 나타나는 등 효과가 미비하다는 언급이 있기에 고정으로 수초 적용함
        // [self hideIndicator];
        [AlloSession rotate: [self deviceInfo]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [Allo i: @"webView / didFailNavigation [%@] @%@", web.URL, [[self class] description]];

    @try
    {
        // 20200813 이전, 다음 등 페이지 이동시 인디케이터가 잠깐 나타나는 등 효과가 미비하다는 언급이 있기에 고정으로 수초 적용함
        // [self hideIndicator];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [Allo i: @"webView / decidePolicyForNavigationAcśion / decisionHandler [%@] @%@", navigationAction.request.URL.absoluteString, [[self class] description]];

    @try
    {
        NSString *requestString = navigationAction.request.URL.absoluteString;

        if ([requestString containsString: ACTION_CHECK])
        {
            // 디버깅
            [Allo i: @"isOnline? %@", ([self isOnline] ? @"Y" : @"N")];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        if ([requestString containsString: ACTION_EXEC])
        {
            [self actionExec];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_ROLE])
        {
            [self actionRole];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_OPEN])
        {
            NSString* link = [requestString substringFromIndex: [ACTION_OPEN length] + 1];
            [self openLink: link];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_ONLINE])
        {
            // 오프라인 모드 클리어
            // (단, 페이지 로딩시 디바이스가 오프라인 이라면 다시 오프라인 모드 설정됨)
            isOffline = NO; [self setOffline: isOffline];
            [self loadOnline];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_OFFLINE])
        {
            // 오프라인 모드 설정함
            // (명시적 오프라인 모드 설정뿐 아니라 페이지 로딩시 디바이스가 오프라인 이라면 다시 오프라인 모드 설정하기에 loadOffline 메소드에서 처리함)
            // isOffline = YES; [self setOffline: isOffline];

            [self loadOffline];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        if ([requestString containsString: ACTION_IMAGE_THUMB])
        {
            [self actionImageThumb];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_IMAGE_PHOTO])
        {
            // 오프라인 모드 처리용
            // (온라인 모드시에는 <input type="file" ... accept="image/*" capture="camera" /> 로 처리됨)
            
            [self actionImagePhoto];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_IMAGE_CAMERA])
        {
            // 오프라인 모드 처리용
            // (온라인 모드시에는 <input type="file" ... accept="image/*" capture="camera" /> 로 처리됨)
            
            [self actionImageCamera];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_IMAGE_SUBMIT])
        {
            [self actionImageSubmit];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        if ([requestString containsString: ACTION_DATA_ALL])
        {
            [self actionDataAll];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_DATA_GET])
        {
            [self actionDataGet];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_DATA_SET])
        {
            [self actionDataSet];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_DATA_DEL])
        {
            [self actionDataDel];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_DATA_LIST])
        {
            [self actionDataList];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_DATA_SUBMIT])
        {
            [self actionDataSubmit];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        if ([requestString containsString: ACTION_VOICE_PLAY])
        {
            [self actionVoicePlay];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_VOICE_STOP])
        {
            [self actionVoiceStop];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        if ([requestString containsString: ACTION_VOICE_RECORD])
        {
            [self actionVoiceRecord];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }
        if ([requestString containsString: ACTION_VOICE_SUBMIT])
        {
            [self actionVoiceSubmit];
            decisionHandler (WKNavigationActionPolicyCancel);
            return;
        }

        decisionHandler (WKNavigationActionPolicyAllow);
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - CUSTOMIZE

- (BOOL) isOnline
{
    BOOL online = YES;
    if (NotReachable == [cnn currentReachabilityStatus]) online = NO;

    return (online);
}

-(void) voiceControllerDidCancel
{
    [Allo i: @"voiceControllerDidCancel @%@", [[self class] description]];

    @try
    {
        [self onVoiceRecordCallback: NO response: @"canceled"];
        [self dismissViewControllerAnimated: YES completion: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

-(void) voiceControllerDidFinishWithInfo: (NSDictionary*) info
{
    [Allo i: @"voiceControllerDidFinishWithInfo @%@", [[self class] description]];

    @try
    {
        // 음성녹취 정보 설정요
        voiceInfo = info;
        [self onVoiceRecordCallback: YES response: voiceInfo];
        [self dismissViewControllerAnimated: YES completion: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (CTCarrier *) getCarrier: (NSDictionary <NSString *, CTCarrier *> *) carriers
{
    [Allo i: @"getCarrier @%@", [[self class] description]];

    @try
    {
        for (NSString *key in carriers)
        {
            if (nil != carriers [key].carrierName) return carriers [key];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    return nil;
}

- (void) loadOnline
{
    [Allo i: @"loadOnline @%@", [[self class] description]];

    @try
    {
        [self loadLink: SITE_ONLINE];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) loadOffline
{
    [Allo i: @"loadOffline @%@", [[self class] description]];

    @try
    {
        // 오프라인 모드 설정함
        // (명시적 오프라인 모드 설정뿐 아니라 페이지 로딩시 디바이스가 오프라인 이라면 다시 오프라인 모드 설정하기에 loadOffline 메소드에서 처리함)
        isOffline = YES; [self setOffline: isOffline];
        [Allo toast: NSLocalizedString (@"message_offline", @"오프라인 상태입니다!")];

        NSURL* htmlPath = [[NSBundle mainBundle ] URLForResource : SITE_OFFLINE withExtension : @"htm" subdirectory: @"offline"];
        NSString* htmlData = [NSString stringWithContentsOfURL: htmlPath encoding:NSUTF8StringEncoding error: nil];
        [web loadHTMLString: htmlData baseURL: [htmlPath URLByDeletingLastPathComponent]];
        
        CGFloat delay = 1.200;
        [self performSelector: @selector (configOffline) withObject: nil afterDelay: delay];

    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) configOffline
{
    [Allo i: @"configOffline @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_CONFIG_OFFLINE;
        // script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: code];
        // script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        [web evaluateJavaScript: script completionHandler: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) loadLink: (NSString*) link
{
    [Allo i: @"loadLink @%@", [[self class] description]];

    @try
    {
        [web loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: link]]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) openLink: (NSString*) link
{
    [Allo i: @"openLink @%@", [[self class] description]];

    @try
    {
        NSURL* check = [NSURL URLWithString: link];
        if (check && check.scheme && check.host)
        {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: link] options: @{} completionHandler: nil];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

// android 의 경우 시스템 키로 백버튼을 제공하지만 ios 의 경우 이전 페이지로 이동할 방법이 딱히 없기에 제스쳐를 적용해서 처리함
- (void) handleSwipeGesture: (UISwipeGestureRecognizer*) sender
{
    [Allo i: @"handleSwipeGesture @%@", [[self class] description]];

    @try
    {
        if (UISwipeGestureRecognizerDirectionLeft == sender.direction) [self actionNext];
        if (UISwipeGestureRecognizerDirectionRight == sender.direction) [self actionPrev];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionNone
{
    [Allo i: @"actionNone @%@", [[self class] description]];

    @try
    {
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionPrev
{
    [Allo i: @"actionPrev @%@", [[self class] description]];

    @try
    {
        if ([self.web canGoBack]) [self.web goBack];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionNext
{
    [Allo i: @"actionNext @%@", [[self class] description]];

    @try
    {
        if ([self.web canGoForward]) [self.web goForward];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionVoicePlay
{
    [Allo i: @"actionVoicePlay @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_VOICE_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onVoiceCallback: NO response: [error description]]; return; };

        NSString* nameAs = [json objectForKey: @"list"]; // 향후 필요시 콤마로 구분해서 멀티로 처리요

        // 20200731 저장위치 점검요
        // NSDocumentDirectory
        // NSDownloadsDirectory
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", nameAs],
                                   nil];
        NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];

        if (nil != player) [player stop];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL: saveURL error: &error];
        if (error) { [self onVoiceCallback: NO response: [error description]]; return; };
        player.delegate = self;
        // 볼륨을 크게 설정함
        player.volume = 1.0;
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride);
        }
        [Allo i: @"check player volume [%d]", player.volume];
        [player play];
        
        // audioPlayerDidFinishPlaying 에서 onVoiceCallback 처리요
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onVoiceCallback: NO response: [e description]]; }
}

- (void) actionVoiceStop
{
    [Allo i: @"actionVoiceStop @%@", [[self class] description]];

    @try
    {
        if (nil != player) [player stop];
        [self onVoiceCallback: YES response: @"Player stop"];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) flag
{
    [Allo i: @"audioPlayerDidFinishPlaying @%@", [[self class] description]];

    @try
    {
        [self onVoiceCallback: YES response: @"Player done"];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionVoiceRecord
{
    [Allo i: @"actionRecord @%@", [[self class] description]];

    @try
    {
        VoiceController* voicePicker = [[VoiceController alloc] init];
        voicePicker.callback = self;
        [self presentViewController: voicePicker animated: YES completion: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionExec
{
    [Allo i: @"actionExec @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_EXEC_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: nil];

        NSString* link = [json objectForKey: @"link"];
        NSString* data = [json objectForKey: @"data"];

        [Allo i: @"check eval parse [%@][%@]", link, data];
        
        NSString* scheme = [NSString stringWithFormat: @"%@://", data];
        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: scheme]])
        {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: scheme] options: @{} completionHandler: nil];
        } else if (0 < [link length]) { [self openLink: link]; }

    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionRole
{
    [Allo i: @"actionRole @%@", [[self class] description]];

    @try
    {
        NSString* role = @"";
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* value = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey: ROLE]];
        if (nil != value) role = value;

        [self onRoleCallback: role];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionImageThumb
{
    [Allo i: @"actionImageThumb @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_IMAGE_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onImageThumbCallback: NO response: [error description]]; return; }

        NSString* list = [json objectForKey: @"list"]; // 향후 필요시 콤마로 구분해서 멀티로 처리요
        NSString* thumbName = [list stringByReplacingOccurrencesOfString: @".jpg" withString: @"-thumb.jpg"];
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", thumbName],
                                   nil];
        NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
        NSString* filePath = [saveURL path];
        NSData* thumbData = [NSData dataWithContentsOfFile: filePath];
        NSString* thumb = [NSString stringWithFormat: @"data:image/jpg;base64,%@", [thumbData base64EncodedStringWithOptions: 0]];

        imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     thumb, @"thumb",
                     nil];

        [self onImageThumbCallback: YES response: imageInfo];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionImagePhoto
{
    [Allo i: @"actionImagePhoto @%@", [[self class] description]];

    @try
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        // picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController: picker animated: YES completion: nil];
        // 결과 처리 참고요 : didFinishPickingMediaWithInfo 및 imagePickerControllerDidCancel
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionImageCamera
{
    [Allo i: @"actionImageCamera @%@", [[self class] description]];

    @try
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        // picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController: picker animated: YES completion: nil];
        // 결과 처리 참고요 : didFinishPickingMediaWithInfo 및 imagePickerControllerDidCancel
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionImageSubmit
{
    [Allo i: @"actionImageSubmit @%@", [[self class] description]];

    @try
    {
        NSString* CRLF = FORMDATA_CRLF;
        NSString* HYPHENS = FORMDATA_HYPHENS;
        NSString* BOUNDARY = FORMDATA_BOUNDARY;

        NSString* script = SCRIPT_IMAGE_EVAL;
        // JImage.data 설정 없이 form 데이터를 추릴려면 target=form_id_or_name 을 넘겨줘야함
        // VER1 script = [script stringByReplacingOccurrencesOfString: @"#FORM#" withString: target];
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onImageSubmitCallback: NO response: [error description]]; return; }

        // ***********************
        // 20200730 이미지 정보를 네이티브 ImageInfo 가 아닌 패러미터로 받아서 처리해야 멀티 가능함
        // ***********************

        NSString* mimeType = @"image/jpg";
        
        // NSString* fileName = (NSString*) [imageInfo objectForKey: @"name"];
        // NSString* filePath = (NSString*) [imageInfo objectForKey: @"path"];
        
        NSString* actionURL = [json objectForKey: @"url"];
        NSString* inputName = [json objectForKey: @"name"];
        NSString* inputList = [json objectForKey: @"list"]; // 향후 멀티플 업로드 고려요 (배열 또는 콤마로 구분하여 처리 등)
        // ***********************
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", inputList],
                                   nil];
        NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
        NSString* filePath = [saveURL path];
        // ***********************

        NSDictionary* params = [json objectForKey: @"params"];
        [Allo i: @"check json [%@][%@][%@][%@][%@]", actionURL, inputName, inputList, filePath, params];

        NSMutableData* mutableData = [NSMutableData data];

        // 이미지 데이터 패러미터
        @try
        {
            NSData* bytes = [NSData dataWithContentsOfFile: filePath];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", inputName, inputList, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Type: %@%@%@", mimeType, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData: bytes];
            // [mutableData appendData: [NSData dataWithContentsOfFile: filePath]];
            [mutableData appendData:[[NSString stringWithFormat: @"%@", CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        } @catch (NSException* z) { NSLog ( @"error : %@ %@", [z name], [z reason]); }

        // 로그인 데이터 패러미터
        // [info setUser: @"test-user-seqno"]; // 디버깅
        NSString* userName = @"user";
        NSString* userValue = [deviceInfo user];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", userName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@", userValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];

        // 데이터 페러미터 설정요
        for (NSString* eachName in params)
        {
            NSString* eachValue = [params objectForKey: eachName];
            [Allo i: @"check params [%@] => [%@]", eachName, eachValue];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", eachName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@", eachValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        }

        // 업로드 데이터 마무리 (end of data)
        [mutableData appendData: [[NSString stringWithFormat: @"%@%@%@%@", HYPHENS, BOUNDARY, HYPHENS, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        
        // 사이트 개발 완료되기 전까지는 unit.php 로 데이터 포스팅 테스트
        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net post: actionURL data: mutableData];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];

        [self onImageSubmitCallback: YES response: responseText];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionVoiceSubmit
{
    [Allo i: @"actionVoiceSubmit @%@", [[self class] description]];

    @try
    {
        NSString* CRLF = FORMDATA_CRLF;
        NSString* HYPHENS = FORMDATA_HYPHENS;
        NSString* BOUNDARY = FORMDATA_BOUNDARY;

        NSString* script = SCRIPT_VOICE_EVAL;
        // JVoice.data 설정 없이 form 데이터를 추릴려면 target=form_id_or_name 을 넘겨줘야함
        // VER1 script = [script stringByReplacingOccurrencesOfString: @"#FORM#" withString: target];
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onVoiceSubmitCallback: NO response: [error description]]; return; }

        NSString* voiceMime = @"audio/aac";
        // NSString* fileName = (NSString*) [voiceInfo objectForKey: @"name"];
        // NSString* filePath = (NSString*) [voiceInfo objectForKey: @"path"];
        NSString* actionURL = [json objectForKey: @"url"];
        NSString* inputName = [json objectForKey: @"name"];
        NSString* inputList = [json objectForKey: @"list"]; // 향후 멀티플 업로드 고려요 (배열 또는 콤마로 구분하여 처리 등)
        // ***********************
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", inputList],
                                   nil];
        NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
        NSString* filePath = [saveURL path];
        // ***********************

        /*
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: filePath];
        [Allo i: @"check info [%@][%@][%@]", (fileExists ? @"Y" : @"N"), inputList, filePath];
        */

        NSDictionary* params = [json objectForKey: @"params"];
        [Allo i: @"check json [%@][%@][%@][%@][%@]", actionURL, inputName, inputList, filePath, params];

        NSMutableData* mutableData = [NSMutableData data];

        // 오디오 데이터 패러미터
        @try
        {
            NSData* bytes = [NSData dataWithContentsOfFile: filePath];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", inputName, inputList, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Type: %@%@%@", voiceMime, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData: bytes];
            // [mutableData appendData: [NSData dataWithContentsOfFile: filePath]];
            [mutableData appendData:[[NSString stringWithFormat: @"%@", CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        } @catch (NSException* z) { NSLog ( @"error : %@ %@", [z name], [z reason]); }

        // 로그인 데이터 패러미터
        // [info setUser: @"test-user-seqno"]; // 디버깅
        NSString* userName = @"user";
        NSString* userValue = [deviceInfo user];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", userName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@", userValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];

        // 데이터 페러미터 설정요
        for (NSString* eachName in params)
        {
            NSString* eachValue = [params objectForKey: eachName];
            [Allo i: @"check params [%@] => [%@]", eachName, eachValue];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", eachName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@", eachValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        }

        // 업로드 데이터 마무리 (end of data)
        [mutableData appendData: [[NSString stringWithFormat: @"%@%@%@%@", HYPHENS, BOUNDARY, HYPHENS, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        
        // 사이트 개발 완료되기 전까지는 unit.php 로 데이터 포스팅 테스트
        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net post: actionURL data: mutableData];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];

        [self onVoiceSubmitCallback: YES response: responseText];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onRoleCallback: (NSString*) role
{
    [Allo i: @"onRoleCallback @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        [json setValue: role forKey: @"role"];
        // [json setValue: @"1" forKey: @"role"]; // 감리업체 테스트
        // [json setValue: @"2" forKey: @"role"]; // 협력업체 테스트
        // [json setValue: @"3" forKey: @"role"]; // KCC직원 테스트

        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];
        
        NSString* script = SCRIPT_ROLE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: @"true"];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onDataCallback: (NSString*) result
{
    [Allo i: @"onDataCallback @%@", [[self class] description]];

    @try
    {
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [result dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        BOOL check = [[NSString stringWithFormat: @"%@", [json objectForKey: @"status"]] boolValue];
        NSString* message = [NSString stringWithFormat: @"%@", [json objectForKey: @"message"]];

        NSString* prepare = @"";
        @try
        {
            NSMutableDictionary* mutable = [NSMutableDictionary dictionary];
            [mutable setObject: (NSMutableArray*) [json objectForKey: @"response"] forKey: @"response"];
            
            NSData* jsonable = [NSJSONSerialization dataWithJSONObject: mutable options: NSJSONWritingPrettyPrinted error: nil];
            prepare = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];
        } @catch (NSException* x) { NSLog ( @"error : %@ %@", [x name], [x reason]);
            check = NO; message = [NSString stringWithFormat: @"%@ - %@", [json objectForKey: @"message"], [x reason]]; }
        
        BOOL status = check;
        NSString* response = [NSString jsonescape: [NSString stringWithFormat: @"%@", (NSString*) prepare]];
        if (!status) response = [NSString jsonescape: [NSString stringWithFormat: @"%@", (NSString*) message]];
        
        NSString* script = SCRIPT_DATA_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onDataExceptionCallback: (NSString*) message
{
    [Allo i: @"onDataExceptionCallback @%@", [[self class] description]];

    @try
    {
        NSString* response = [NSString jsonescape: [NSString stringWithFormat: @"%@", (NSString*) message]];

        NSString* script = SCRIPT_DATA_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: @"false"];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onImageThumbCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onImageThumbCallback @%@", [[self class] description]];
    
    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        if ([object isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* info = (NSDictionary*) object;
            NSString* thumb = (NSString*) [info objectForKey: @"thumb"];
            [json setValue: thumb forKey: @"thumb"];
        }
        else
        {
            NSString* message = (NSString*) object;
            [json setValue: message forKey: @"message"];
        }
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_IMAGE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onImageSelectCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onImageSelectCallback @%@", [[self class] description]];
    
    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        if ([object isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* info = (NSDictionary*) object;
            NSString* name = (NSString*) [info objectForKey: @"name"];
            // NSString* path = (NSString*) [info objectForKey: @"path"];
            
            // 쎔네일 설정함
            NSString* thumbName = [name stringByReplacingOccurrencesOfString: @".jpg" withString: @"-thumb.jpg"];
            NSArray* pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       [NSString stringWithFormat: @"%@", thumbName],
                                       nil];
            NSString* thumbPath = [[NSURL fileURLWithPathComponents: pathComponents] path];

            NSString* thumb = @"";
            @try
            {
                thumb = [NSString stringWithFormat: @"data:image/jpg;base64,%@", [[NSData dataWithContentsOfFile: thumbPath] base64EncodedStringWithOptions: 0]];
            } @catch (NSException* x) { NSLog ( @"error : %@ %@", [x name], [x reason]); }

            [json setValue: name forKey: @"name"];
            // [json setValue: path forKey: @"path"];
            [json setValue: thumb forKey: @"thumb"];
        }
        else
        {
            NSString* message = (NSString*) object;
            [json setValue: message forKey: @"message"];
        }
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_IMAGE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onImageSubmitCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onImageSubmitCallback @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        NSString* message = (NSString*) object;
        [json setValue: message forKey: @"message"];

        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_IMAGE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onVoiceCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onVoiceCallback @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        NSString* message = (NSString*) object;
        [json setValue: message forKey: @"message"];
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_VOICE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onVoiceRecordCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onVoiceRecordCallback @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        if ([object isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* info = (NSDictionary*) object;
            NSString* name = (NSString*) [info objectForKey: @"name"];
            [json setValue: name forKey: @"name"];
            NSString* duration = (NSString*) [info objectForKey: @"duration"];
            [json setValue: duration forKey: @"duration"];
            // 20200731 보안 이슈로 경로는 제외함
            // (데이터 저장시 지정된 경로를 사용하므로 이름만으로 처리 가능함)
            // NSString* path = (NSString*) [info objectForKey: @"path"];
            // [json setValue: path forKey: @"path"];
        }
        else
        {
            NSString* message = (NSString*) object;
            [json setValue: message forKey: @"message"];
        }

        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_VOICE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) onVoiceSubmitCallback: (BOOL) status response: (id) object
{
    [Allo i: @"onVoiceSubmitCallback @%@", [[self class] description]];

    @try
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        NSString* message = (NSString*) object;
        [json setValue: message forKey: @"message"];
        
        NSError *error;
        NSData* data = [NSJSONSerialization dataWithJSONObject: json options: kNilOptions error: &error];
        if (error) [Allo i: @"check error json data [%@]", [error description]];
        // 20200730 오류남 NSString* response = [NSString stringWithUTF8String: [data bytes]];
        NSString* response = [NSString jsonescape: [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];

        NSString* script = SCRIPT_VOICE_CALLBACK;
        script = [script stringByReplacingOccurrencesOfString: @"#RESPONSE#" withString: response];
        script = [script stringByReplacingOccurrencesOfString: @"#STATUS#" withString: (status ? @"true" : @"false")];
        [web evaluateJavaScript: script completionHandler: nil];

        [Allo i: @"%@", script];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    [Allo i: @"imagePickerController / didFinishPickingMediaWithInfo @%@", [[self class] description]];

    @try
    {
        [Allo i: @"%@", info];

        NSString* KOUP_IMAGE_EXT = @".jpg";
        NSString* KOUP_IMAGE_PRE = @"KOUP-";
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
        NSString* timeAs = [dateFormatter stringFromDate: [NSDate date]];
        NSString* nameAs = [NSString stringWithFormat: @"%@%@%@", KOUP_IMAGE_PRE, timeAs, KOUP_IMAGE_EXT];
        NSString* thumbAs = [NSString stringWithFormat: @"%@%@-thumb%@", KOUP_IMAGE_PRE, timeAs, KOUP_IMAGE_EXT];

        // 20200731 저장위치 점검요 
        // NSDocumentDirectory
        // NSDownloadsDirectory
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", nameAs],
                                   nil];
        NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
        NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* savePath = [[NSString alloc]initWithString: [paths [0] stringByAppendingPathComponent: nameAs]];
        pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", thumbAs],
                                   nil];
        NSURL* thumbURL = [NSURL fileURLWithPathComponents: pathComponents];

        UIImage* chosenImage = [info objectForKey: UIImagePickerControllerOriginalImage];
        // 0.5f 50% : Medium Quality 1.5MB 이하 수준, 1.0f 100% : High Quality 5.0MB 이상 수준
        NSData* imageData = UIImageJPEGRepresentation (chosenImage, 0.5f);
        // NSData* imageData = UIImageJPEGRepresentation (chosenImage, 1.0f);

        if (![imageData writeToURL: saveURL atomically: NO])
        {
            [Allo i: @"check save error url : %@", saveURL];
            [Allo i: @"check save error path : %@", savePath];
        }

        // 썸네일 작성요
        UIImage* swapImage = [info objectForKey: UIImagePickerControllerOriginalImage];
        CGRect thumbRect = CGRectMake (0.0, 0.0, 240, 240*(swapImage.size.height/swapImage.size.width));
        UIGraphicsBeginImageContext (thumbRect.size);
        [swapImage drawInRect: thumbRect];
        UIImage* thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData* thumbData = UIImageJPEGRepresentation (thumbImage, 0.5f);
        UIGraphicsEndImageContext();
        if (![thumbData writeToURL: thumbURL atomically: NO])
        {
            [Allo i: @"check save error url : %@", thumbURL];
        }
        
        // 20200728 이미지 업로드용 데이터 설정함
        imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     [[saveURL path] lastPathComponent], @"name", [saveURL path], @"path",
                     nil];

        // 카메라 촬영의 경우엔 갤러리도 저장함
        if (UIImagePickerControllerSourceTypeCamera == picker.sourceType) UIImageWriteToSavedPhotosAlbum (chosenImage, nil, nil, nil);

        [self onImageSelectCallback: YES response: imageInfo];
        [picker dismissViewControllerAnimated: YES completion: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [Allo i: @"imagePickerControllerDidCancel @%@", [[self class] description]];

    @try
    {
        [self onImageSelectCallback: NO response: @"canceled"];
        [self dismissViewControllerAnimated: YES completion: nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - SQLite Data Handling

- (void) actionDataSubmit
{
    [Allo i: @"actionDataSubmit @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        // JImage.data 설정 없이 form 데이터를 추릴려면 target=form_id_or_name 을 넘겨줘야함
        // VER1 script = [script stringByReplacingOccurrencesOfString: @"#FORM#" withString: target];
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        // ***********************
        // 20200730 이미지 정보를 네이티브 ImageInfo 가 아닌 패러미터로 받아서 처리해야 멀티 가능함
        // ***********************

        NSString* actionURL = [json objectForKey: @"url"];
        NSString* imageName = [json objectForKey: @"image"];
        NSString* voiceName = [json objectForKey: @"voice"];
        NSDictionary* params = [json objectForKey: @"params"];

        // 이미지, 보이스 파일명 설정요
        NSString* imageList = @"";
        NSString* voiceList = @"";
        for (NSString* eachName in params)
        {
            NSString* eachValue = [params objectForKey: eachName];
            if ([@"image" isEqualToString: eachName]) imageList = eachValue;
            if ([@"voice" isEqualToString: eachName]) voiceList = eachValue;
            [Allo i: @"check params [%@] => [%@]", eachName, eachValue];
        }

        [Allo i: @"check data form info [%@][%@ => %@][%@ => %@]", actionURL, imageName, imageList, voiceName, voiceList];

        NSString* CRLF = FORMDATA_CRLF;
        NSString* HYPHENS = FORMDATA_HYPHENS;
        NSString* BOUNDARY = FORMDATA_BOUNDARY;

        NSMutableData* mutableData = [NSMutableData data];

        // 이미지 데이터 업로드
        if (0 < [imageList length])
        {
            NSString* imageMime = @"image/jpg";
            [Allo i: @"check data upload image [%@][%@ => %@]", actionURL, imageName, imageList];

            // NSString* imageList = [json objectForKey: @"list"]; // 향후 멀티플 업로드 고려요 (배열 또는 콤마로 구분하여 처리 등)
            // ***********************
            NSArray* pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       [NSString stringWithFormat: @"%@", imageList],
                                       nil];
            NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
            NSString* filePath = [saveURL path];
            // ***********************

            @try
            {
                NSData* bytes = [NSData dataWithContentsOfFile: filePath];
                [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", imageName, imageList, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData:[[NSString stringWithFormat: @"Content-Type: %@%@%@", imageMime, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData: bytes];
                // [mutableData appendData: [NSData dataWithContentsOfFile: filePath]];
                [mutableData appendData:[[NSString stringWithFormat: @"%@", CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
        }

        // 보이스 데이터 업로드
        if (0 < [voiceList length])
        {
            NSString* voiceMime = @"audio/aac";
            [Allo i: @"check data upload voice [%@][%@ => %@]", actionURL, voiceName, voiceList];

            // NSString* voiceList = [json objectForKey: @"list"]; // 향후 멀티플 업로드 고려요 (배열 또는 콤마로 구분하여 처리 등)
            // ***********************
            NSArray* pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       [NSString stringWithFormat: @"%@", voiceList],
                                       nil];
            NSURL* saveURL = [NSURL fileURLWithPathComponents: pathComponents];
            NSString* filePath = [saveURL path];
            // ***********************

            @try
            {
                NSData* bytes = [NSData dataWithContentsOfFile: filePath];
                [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", voiceName, voiceList, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData:[[NSString stringWithFormat: @"Content-Type: %@%@%@", voiceMime, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
                [mutableData appendData: bytes];
                // [mutableData appendData: [NSData dataWithContentsOfFile: filePath]];
                [mutableData appendData:[[NSString stringWithFormat: @"%@", CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
        }

        // 로그인 데이터 패러미터
        // [info setUser: @"test-user-seqno"]; // 디버깅
        NSString* userName = @"user";
        NSString* userValue = [deviceInfo user];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", userName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        [mutableData appendData:[[NSString stringWithFormat: @"%@%@", userValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];

        // 데이터 페러미터 설정요
        for (NSString* eachName in params)
        {
            if ([@"image" isEqualToString: eachName]) continue;
            if ([@"voice" isEqualToString: eachName]) continue;
            NSString* eachValue = [params objectForKey: eachName];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@%@", HYPHENS, BOUNDARY, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"%@%@", eachName, CRLF, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
            [mutableData appendData:[[NSString stringWithFormat: @"%@%@", eachValue, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        }

        // 업로드 데이터 마무리 (end of data)
        [mutableData appendData: [[NSString stringWithFormat: @"%@%@%@%@", HYPHENS, BOUNDARY, HYPHENS, CRLF] dataUsingEncoding: NSUTF8StringEncoding]];
        
        // 사이트 개발 완료되기 전까지는 unit.php 로 데이터 포스팅 테스트
        AlloData* net = [[AlloData alloc] init];
        NSData* responseData = [net post: actionURL data: mutableData];
        NSString* responseText = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];

        [self onDataCallback: [AlloSQLite submit: responseText]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

- (void) actionDataSet
{
    [Allo i: @"actionDataSet @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        NSString* menu = [NSString stringWithFormat: @"%@", [json objectForKey: @"menu"]];
        NSString* name = [NSString stringWithFormat: @"%@", [json objectForKey: @"name"]];
        
        // 대표 이미지 썸네일 설정용
        NSString* list = @"";
        
        NSMutableDictionary* swap = [NSMutableDictionary dictionary];
        NSDictionary* line = (NSDictionary*) [json objectForKey: @"data"];
        for (NSString* eachName in line)
        {
            NSString* eachValue = [line objectForKey: eachName];
            [Allo i: @"check data line [%@] => [%@]", eachName, eachValue];
            [swap setObject: eachValue forKey: eachName];

            // 대표 이미지 썸네일 설정용
            if ([@"image" isEqualToString: eachName]) list = eachValue;
        }
        
        NSData* jsonable = [NSJSONSerialization dataWithJSONObject: swap options: NSJSONWritingPrettyPrinted error: nil];
        NSString* data = [[NSString alloc] initWithData: jsonable encoding: NSUTF8StringEncoding];

        // 쎔네일 설정함
        NSString* thumbName = [list stringByReplacingOccurrencesOfString: @".jpg" withString: @"-thumb.jpg"];
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat: @"%@", thumbName],
                                   nil];
        NSString* thumbPath = [[NSURL fileURLWithPathComponents: pathComponents] path];
        
        NSString* thumb = @"";
        @try
        {
            thumb = [NSString stringWithFormat: @"data:image/jpg;base64,%@", [[NSData dataWithContentsOfFile: thumbPath] base64EncodedStringWithOptions: 0]];
        } @catch (NSException* x) { NSLog ( @"error : %@ %@", [x name], [x reason]); }
        
        [Allo i: @"data set #2 => [%@][%@][%@]", menu, name, data];
        [self onDataCallback: [AlloSQLite set: menu name: name data: data thumb: thumb]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

- (void) actionDataGet
{
    [Allo i: @"actionDataGet @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        NSString* name = [NSString stringWithFormat: @"%@", [json objectForKey: @"name"]];

        [Allo i: @"data get => [%@]", name];

        [self onDataCallback: [AlloSQLite get: name]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

- (void) actionDataDel
{
    [Allo i: @"actionDataDel @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        NSMutableString* list = [NSMutableString stringWithString: @""];
        NSArray* array = (NSArray*) [json objectForKey: @"list"];
        for (int i = 0; i < [array count]; i++)
        {
            if (0 < [list length]) [list appendString: @", "];
            [list appendString: [NSString stringWithFormat: @"'%@'", (NSString*) [array objectAtIndex: i]]];
        }

        [Allo i: @"data del list => [%@]", list];

        [self onDataCallback: [AlloSQLite del: list]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

- (void) actionDataAll
{
    [Allo i: @"actionDataAll @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        NSString* menu = [NSString stringWithFormat: @"%@", [json objectForKey: @"menu"]];

        [Allo i: @"data all => [%@]", menu];

        [self onDataCallback: [AlloSQLite all: menu]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

- (void) actionDataList
{
    [Allo i: @"actionDataList @%@", [[self class] description]];

    @try
    {
        NSString* script = SCRIPT_DATA_EVAL;
        NSString* response = [web eval: script];
        [Allo i: @"check eval [%@][%@]", script, response];
        
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
        if (error) { [self onDataExceptionCallback: [error description]]; return; }

        NSString* menu = [NSString stringWithFormat: @"%@", [json objectForKey: @"menu"]];
        int last = [[NSString stringWithFormat: @"%@", [json objectForKey: @"last"]] intValue];
        int limit = [[NSString stringWithFormat: @"%@", [json objectForKey: @"limit"]] intValue];

        [Allo i: @"data list => [%@][%d][%d]", menu, last, limit];

        [self onDataCallback: [AlloSQLite list: menu last: last limit: limit]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); [self onDataExceptionCallback: [e description]]; }
}

#pragma mark - Scroll Delegate

- (void) actionTop
{
    // [web.scrollView setContentOffset: CGPointMake (0, 0)];
    [web.scrollView setContentOffset: CGPointMake (0, 0) animated: YES];
}

- (void) actionHitTop
{
    [web reload];
    self.topStatus = NO;
    [self.refreshControl endRefreshing];
}

- (void) actionHitTopDelay
{
    if (self.topStatus) return;
    self.topStatus = YES;
    
    CGFloat delay = 0.50;
    [self performSelector: @selector (actionHitTop) withObject: nil afterDelay: delay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [Allo i: @"scrollViewDidScroll [%f] @%@", scrollView.contentOffset.y, [[self class] description]];

    if (self.scrollStatus)
    {
        self.scrollStatus = NO;
    }

    // iOS 에선 사용하지 않음
    /*
    NSString* script = SCRIPT_SCROLL_Y;
    NSString* response = [web eval: script];
    [Allo i: @"check eval SCRIPT_SCROLL_Y [%@][%@]", script, response];
    */
    
    // 20200813 사용하지 않음 (refresh control 로 변경함)
    /*
    if (CSCROLL_HITTOP_DETECT > scrollView.contentOffset.y)
    {
        NSLog (@"----------");
        NSLog (@"debug: scroll view did hit top!!");
        NSLog (@"----------");
        [self actionHitTopDelay];
    }
    */
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat delay = 1.32;
    [self performSelector: @selector (scrollDetected) withObject: nil afterDelay: delay];
}

- (void) scrollDetected
{
    scrollStatus = YES;
}
@end
