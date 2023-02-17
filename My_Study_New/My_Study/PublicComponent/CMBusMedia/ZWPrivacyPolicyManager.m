//
//  ZWPrivacyPolicyManager.m
//  My_Study
//
//  Created by hzw on 2023/2/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "CMBusMediaAppDelegate.h"
#import "ZWMainAppDelegateService.h"
#import "ZWPrivacyPolicyManager.h"
#import "AppDelegate.h"
#import "ZWPushAppDelegateService.h"


@interface ZWPrivacyPolicyManager ()

@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, strong) UIImageView *bottomImgV;

@end

@implementation ZWPrivacyPolicyManager

- (void)showPrivacyPolicyTipView {
}

+ (BOOL)checkShowPrivacyPolicy {
    //    BOOL val = ![[PASCommonUtil getStringWithKey:kAgreePrivacyPolicy] boolValue];
    //    return val;
    return NO;
}

+ (void)initializeAction {
    [CMBusMediaAppDelegate regisertService:[[ZWMainAppDelegateService alloc] init]];
    [CMBusMediaAppDelegate regisertService:[[ZWPushAppDelegateService alloc] init]];
}

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        AppDelegate *curAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [CMBusMediaAppDelegate serviceManager:@selector(application:didFinishLaunchingWithOptions:) withParameters:@[application, launchOptions ?: [NSNull null]]];
    } else {
    }
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        // 涉及调用顺序问题，避免所有实现<UIApplicationDelegate>对象openURL 都被调用
        for (id<UIApplicationDelegate> service in [CMBusMediaAppDelegate services]) {
            if ([service respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
                BOOL bRet = [service application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
                if (bRet) {
                    return YES;
                }
            }
        }
    }

    return NO;
}

+ (void)applicationWillResignActive:(UIApplication *)application {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        [CMBusMediaAppDelegate serviceManager:@selector(applicationWillResignActive:) withParameters:@[application]];
    }
}

+ (void)applicationDidEnterBackground:(UIApplication *)application {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        [CMBusMediaAppDelegate serviceManager:@selector(applicationDidEnterBackground:) withParameters:@[application]];
    }
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        [CMBusMediaAppDelegate serviceManager:@selector(applicationWillEnterForeground:) withParameters:@[application]];
    } else {
    }
}

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        [CMBusMediaAppDelegate serviceManager:@selector(applicationDidBecomeActive:) withParameters:@[application]];
    }
}

+ (void)applicationWillTerminate:(UIApplication *)application {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        [CMBusMediaAppDelegate serviceManager:@selector(applicationWillTerminate:) withParameters:@[application]];
    }
}

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params = @[application, shortcutItem, completionHandler];
        [CMBusMediaAppDelegate serviceManager:@selector(application:performActionForShortcutItem:completionHandler:) withParameters:params];
    }
}

#pragma mark-- Notifications
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, deviceToken ?: [NSNull null]];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) withParameters:params];
    } else {
        id val = deviceToken ?: [NSNull null];
//        [PASConfigration writeCacheMemoryWithKey:kDeviceTokenVal value:val];
    }
}

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, error ?: [NSNull null]];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) withParameters:params];
    }
}

+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, notificationSettings ?: [NSNull null]];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didRegisterUserNotificationSettings:) withParameters:params];
    }
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, userInfo ?: [NSNull null]];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didReceiveRemoteNotification:) withParameters:params];
    }
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, notification ?: [NSNull null]];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didReceiveLocalNotification:) withParameters:params];
    }
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSArray *params  = @[application, userInfo ?: [NSNull null], completionHandler];
        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[ZWPushAppDelegateService class]];
        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:) withParameters:params];
    }
}

#pragma mark - ----------------------iWatch回调--------------------
+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(nonnull void (^)(NSDictionary *_Nullable))reply {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
//        NSArray *params  = @[application, userInfo ?: [NSNull null], reply];
//        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[PASWatchAppDelegateService class]];
//        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:handleWatchKitExtensionRequest:reply:) withParameters:params];
    }
}

#pragma mark - universal link
+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
        NSLog(@"\tAction Type : %@", userActivity.activityType);
        NSLog(@"\tURL         : %@", userActivity.webpageURL);

        // 涉及调用顺序问题，避免所有实现<UIApplicationDelegate>对象openURL 都被调用
        for (id<UIApplicationDelegate> service in [CMBusMediaAppDelegate services]) {
            if ([service respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
                BOOL bRet = [service application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
                if (bRet) {
                    return YES;
                }
            }
        }
    }

    return YES;
}

@end
