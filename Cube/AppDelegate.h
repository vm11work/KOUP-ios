//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

#import "Allo.h"
#import "AlloData.h"
#import "UIView+Toast.h"
#import "NSString+Addtions.h"
#import "AlloSQLite.h"

@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow* window;

@end

