//
//  ZWPushAppDelegateService.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ZWPushAppDelegateService.h"
#import "AppDelegate.h"
#include <sys/time.h>
#include <sys/timeb.h>
#import "MMPushUtil.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
@interface ZWPushAppDelegateService()<UNUserNotificationCenterDelegate>
#else
@interface ZWPushAppDelegateService()
#endif


@end


@implementation ZWPushAppDelegateService

- (void)checkGotoChatPage:(NSDictionary *)userinfo time:(float)time {
    id customData = [userinfo objectForKey:@"customData"];
    if (customData) {
//        id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//        mediaInstance.delayCallUrl                            = @"1";
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            //            [[KPASViewTools share] gotoChatPage:@"" des:@""];
//            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"anelicaiapp://stock.pingan.com/consultonline?method=gotoChatPageDescription"]];
//            NSString *url = [NSString stringWithFormat:@"%@://stock.pingan.com/consultonline?method=gotoChatPageDescription", kPASchemeName];
//            [CMBusMediator routeURL:[NSURL URLWithString:url]];
//        });
    }
}

// 用本地通知清理applicationIconBadgeNumber
- (void)clearBadgeNum {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11")) {
            //            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            //            content.badge = @(-1);
            //            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"clearBadge" content:content trigger:nil];
            //            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            //            }];
            // 7.3.0 -1 只清除角标；0 清除角标同时清空消息栏
            [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
        } else {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            if (notification) {
                // 设置触发通知的时间
                NSDate *fireDate      = [NSDate dateWithTimeIntervalSinceNow:1];
                notification.fireDate = fireDate;
                // 时区
                notification.timeZone = [NSTimeZone defaultTimeZone];
                // 设置重复的间隔
                notification.repeatInterval             = 0;
                notification.alertBody                  = nil;
                notification.applicationIconBadgeNumber = -1;
                notification.soundName                  = nil;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AppDelegate *curAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int64_t compentStartTime    = GetMilTimeStamp();

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) { // 6.1推送
        // iOS 10 later
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate                  = self;
        }
    }
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    [mediaInstance getSharePASPushMessageCenter];
//    [mediaInstance registerRemotePushNotification];
//    [mediaInstance handleNotificationDidFinishLaunchWithOption:launchOptions];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    // 清空推送数组
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    [mediaInstance.pushIdArray removeAllObjects];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self clearBadgeNum];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    /**  同步推送消息  */
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    NSString *pageId                                      = [UIResponder pathOfObject:self abortClass:nil parameters:nil];
//    [mediaInstance syncDataToPAPush:NO pageId:pageId pagePrams:nil];
}

#pragma mark-- Notifications
// MARK: - 远程通知(推送)回调

/// [ 系统回调 ] 远程通知注册成功回调，获取DeviceToken成功，同步给个推服务器
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 需要对应的app推送权限才能注册成功，调试需要用支持推送的证书，并发给服务器
    // 这个回调需要一定时间，也许服务器已经连接成功，也可能没成功。
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    [mediaInstance didReceivedPushDeviceToken:deviceToken];
    
    // [ GTSDK ]：向个推服务器注册deviceToken
    // 2.5.2.0 之前版本需要调用：
    //[GeTuiSdk registerDeviceTokenData:deviceToken];

    NSString *token = [MMPushUtil getHexStringForData:deviceToken];
    NSLog(@"token = %@", token);

    NSString *errorMsg = [NSString stringWithFormat:@"[ My_Study ] [ DeviceToken(NSString) ]: %@\n\n", token];
    NSLog(@"errorMsg = %@", errorMsg);

}

/// [ 系统回调:可选 ] 远程通知注册失败回调，获取DeviceToken失败，打印错误信息
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *msg = [NSString stringWithFormat:@"[ My_Study ] %@: %@", NSStringFromSelector(_cmd), error.localizedDescription];
    NSLog(@"msg = %@", msg);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //    [HsNotifyInfoCenter addNotify:userInfo];
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    [mediaInstance didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    //    aps =     {
    //        alert = "\U5e73\U5b89\U8bc1\U5238\U5ba2\U670d : \U4f60\U597d";
    //        badge = 1;
    //        sound = default;
    //    };
    //    customData =     {
    //        pasc = 1;
    //    };  im

    NSLog(@"didReceiveRemoteNotification dfdfdfd = %@", userInfo);
    if (userInfo) {
        NSLog(@"dfdfdfd = %@", userInfo);
    }

    if (application.applicationState == UIApplicationStateActive) {
        // 程序处于前台
        NSLog(@"applicationstate:Active");
        //        [PASPushMessageCenter registerLocalPushNotification:userInfo];
        NSString *pushId                                      = [userInfo objectForKey:@"id"] ?: @"";
//        id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//        [mediaInstance.pushIdArray addObject:pushId];
    } else if (application.applicationState == UIApplicationStateInactive) {
        // 程序处于后台
        NSLog(@"applicationstate:Inactive");
        [self checkGotoChatPage:userInfo time:1.0];
    } else {
        NSLog(@"applicationstate:Background");
        [self checkGotoChatPage:userInfo time:1.0];
    }
}

#pragma mark - UNUserNotificationCenterDelegate
// 在前台的时候调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo                                = notification.request.content.userInfo;
    NSString *pushId                                      = [userInfo objectForKey:@"id"] ?: @"";
//    id<CMPTPublicService_PushMessageCenter> mediaInstance = [CMBusMediator serviceForProtocol:@protocol(CMPTPublicService_PushMessageCenter) componentId:kCMPTPublicService];
//    [mediaInstance.pushIdArray addObject:pushId];
}

// 从后台进入的时候调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self checkGotoChatPage:userInfo time:1.0];

    //  按非ios10逻辑，这个时候调用不需要填
    //    NSString *pushId = [userInfo objectForKey:@"id"] ?: @"";
    //    [[PASPushMessageCenter sharedPASPushMessageCenter].pushIdArray addObject:pushId];
}


/**
 获取当前时间戳毫秒
 */
static inline int64_t GetMilTimeStamp(void)
{
    struct timeval tv;
    //获取一个时间结构
    gettimeofday(&tv, NULL);
    int64_t t = (int64_t)tv.tv_sec * 1000 + tv.tv_usec / 1000;
    return t;
}

@end
