//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "Allo.h"
#import "AlloData.h"
#import "AlloSession.h"
#import "DeviceInfo.h"
#import "VoiceDelegate.h"
#import "VoiceController.h"

#import "Reachability.h"
#import "UIView+Toast.h"
#import "NSString+Addtions.h"
#import "WKWebView+Addtions.h"
#import "AlloSQLite.h"

@class DeviceInfo;

@interface ViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioPlayerDelegate, VoiceDelegate>

@property (readwrite) BOOL isOffline;
@property (readwrite) BOOL topStatus;
@property (readwrite) BOOL scrollStatus;

@property (nonatomic, retain) WKWebView* web;
@property (nonatomic, retain) UIRefreshControl* refreshControl;

@property (nonatomic, retain) DeviceInfo* deviceInfo;
@property (nonatomic, retain) NSDictionary* imageInfo;
@property (nonatomic, retain) NSDictionary* voiceInfo;
@property (nonatomic, retain) UIActivityIndicatorView* indicator;

// 20200811 음성 듣기 추가중 
@property (nonatomic)     AVAudioPlayer       *player;

- (void) showIndicator;
- (void) hideIndicator;
- (void) rotateNotification: (NSDictionary*) info;


@end

