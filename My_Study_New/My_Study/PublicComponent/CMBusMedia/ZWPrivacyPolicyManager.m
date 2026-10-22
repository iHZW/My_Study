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
#import "MMPrivacyManager.h"

@interface AppDelegate (PrivacyStartup)
- (void)startServicesAfterPrivacyConsentWithLaunchOptions:(NSDictionary *)launchOptions;
@end

static NSDictionary *ZWPrivacyLaunchOptions;
static BOOL ZWPrivacyServicesStarted;


@interface ZWPrivacyPolicyManager ()

@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, strong) UIImageView *bottomImgV;

@end

@implementation ZWPrivacyPolicyManager

- (void)showPrivacyPolicyTipView {
}

+ (BOOL)checkShowPrivacyPolicy {
    return ![MMPrivacyManager.sharedInstance hasShowedAppPrivacy];
}

+ (void)initializeAction {
    [CMBusMediaAppDelegate regisertService:[[ZWMainAppDelegateService alloc] init]];
    [CMBusMediaAppDelegate regisertService:[[ZWPushAppDelegateService alloc] init]];
}

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ZWPrivacyLaunchOptions = [launchOptions copy];
    // 展示协议所必需的窗口、主题和启动页必须能够在同意前创建。
    ZWMainAppDelegateService *main = (id)[CMBusMediaAppDelegate service:ZWMainAppDelegateService.class];
    [self startServicesAfterPrivacyConsent];
    [main application:application didFinishLaunchingWithOptions:launchOptions];
}

+ (void)startServicesAfterPrivacyConsent {
    NSAssert(NSThread.isMainThread, @"启动服务必须在主线程执行");
    if ([self checkShowPrivacyPolicy] || ZWPrivacyServicesStarted) return;
    ZWPrivacyServicesStarted = YES;
    UIApplication *application = UIApplication.sharedApplication;
    [(AppDelegate *)application.delegate startServicesAfterPrivacyConsentWithLaunchOptions:ZWPrivacyLaunchOptions];
    ZWMainAppDelegateService *main = (id)[CMBusMediaAppDelegate service:ZWMainAppDelegateService.class];
    [main startServicesAfterPrivacyConsent];
    ZWPushAppDelegateService *push = (id)[CMBusMediaAppDelegate service:ZWPushAppDelegateService.class];
    [push application:application didFinishLaunchingWithOptions:ZWPrivacyLaunchOptions];
    ZWPrivacyLaunchOptions = nil;
    // 首次同意不一定再次触发系统前台回调，主动恢复被延后的前台业务。
    if (application.applicationState == UIApplicationStateActive) [self applicationDidBecomeActive:application];
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
    } else {
        completionHandler(NO);
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
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - ----------------------iWatch回调--------------------
+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(nonnull void (^)(NSDictionary *_Nullable))reply {
    if (![ZWPrivacyPolicyManager checkShowPrivacyPolicy]) {
//        NSArray *params  = @[application, userInfo ?: [NSNull null], reply];
//        CMObject *curObj = (CMObject *)[CMBusMediaAppDelegate service:[PASWatchAppDelegateService class]];
//        [CMBusMediaAppDelegate performAction:curObj selector:@selector(application:handleWatchKitExtensionRequest:reply:) withParameters:params];
    } else {
        reply(@{});
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

    return NO;
}

@end
