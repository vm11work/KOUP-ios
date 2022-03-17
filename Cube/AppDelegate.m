//
//  AppDelegate.m
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Allo i: @"application / didFinishLaunchingWithOptions @%@", [[self class] description]];

    @try
    {
        // Override point for customization after application launch.
        [FIRApp configure];//20211108 이전.

        // [END configure_firebase]
        // [START set_messaging_delegate]
//        FIRFirestore *defaultFirestore = [FIRFirestore firestore];

        [FIRMessaging messaging].delegate = self;
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
          
        if ([UNUserNotificationCenter class] != nil)
        {
          // iOS 10 or later
          // For iOS 10 display notification (sent via APNS)
          [UNUserNotificationCenter currentNotificationCenter].delegate = self;
          UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
              UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
          [[UNUserNotificationCenter currentNotificationCenter]
              requestAuthorizationWithOptions:authOptions
              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                // ...
              }];
        }
        else
        {
          // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
          UIUserNotificationType allNotificationTypes =
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
          UIUserNotificationSettings *settings =
          [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
          [application registerUserNotificationSettings:settings];
        }

        [application registerForRemoteNotifications];
        // [END register_for_notifications]
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    [Allo i: @"application / configurationForConnectingSceneSession / options @%@", [[self class] description]];

    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    [Allo i: @"application / didDiscardSceneSessions @%@", [[self class] description]];

    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Firebase

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [Allo i: @"application / didReceiveRemoteNotification @%@", [[self class] description]];

  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification

  // With swizzling disabled you must let Messaging know about the message, for Analytics
  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  NSLog(@"didReceiveRemoteNotification => %@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [Allo i: @"application / didReceiveRemoteNotification @%@", [[self class] description]];

    @try
    {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

        // Print full message.
        [Allo i: @"message @%@", userInfo];

        completionHandler (UIBackgroundFetchResultNewData);
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  [Allo i: @"userNotificationCenter / willPresentNotification / withCompletionHandler @%@", [[self class] description]];

    @try
    {
        NSDictionary *userInfo = notification.request.content.userInfo;

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

        // 아래 userNotificationCenter / didReceiveNotificationResponse.  withCompletionHandler에서 처리요
          
        // Change this to your preferred presentation option
        completionHandler (UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

}

// Handle notification messages after display notification is tapped by the user.
- (void) userNotificationCenter:(UNUserNotificationCenter *)center
            didReceiveNotificationResponse:(UNNotificationResponse *)response
            withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    [Allo i: @"userNotificationCenter / didReceiveNotificationResponse / withCompletionHandler @%@", [[self class] description]];

    @try
    {
        // 푸시 알림 정보
        NSDictionary* info = response.notification.request.content.userInfo;
          
        // ios 의 경우 수신된 푸시 알림을 메인 뷰 컨트롤러로 넘겨서 처리함 (android 와 다르게 심플함)
        ViewController* controller = (ViewController*) [UIApplication sharedApplication].keyWindow.rootViewController;
        [controller rotateNotification: info];

        completionHandler ();
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

}
// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *) fcmToken
{
    [Allo i: @"messaging / didReceiveRegistrationToken @%@", [[self class] description]];

    @try
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject: fcmToken forKey: @"token"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"FCMToken" object:nil userInfo: userInfo];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
// [END refresh_token]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [Allo i: @"application / didFailToRegisterForRemoteNotificationsWithError [%@] @%@", error, [[self class] description]];
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Allo i: @"application / didRegisterForRemoteNotificationsWithDeviceToken [%@] @%@", deviceToken, [[self class] description]];
}


@end
