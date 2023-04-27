//
//  AppDelegate.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ZWBaseViewController.h"
// #import "TwoPageViewController.h"
#import "AppLaunchTime.h"
#import "CMBusMediaAppDelegate.h"
#import "CRMViewController.h"
#import "ModuleContainer.h"
#import "TABAnimated.h"
#import "WXApi.h"
// #import "ZWMainAppDelegateService.h"
#import "ZWNavigationController.h"
#import "zhThemeOperator.h"
#import <objc/runtime.h>

#import "OneKeyLogin.h"
#import "ZWOneKey.h"
#import <CL_ShanYanSDK/CL_ShanYanSDK.h>

#ifdef DOKIT

#import "DoraemonManager.h"
#import <DoraemonKit/DoraemonManager.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#endif

#import "TestBlock.h"

/** 添加防崩溃三方库  */
#if __has_include(<JJException/JJException.h>)
#import <JJException/JJException.h>
#else
#import "JJException.h"
#endif

#import "MMShareManager.h"

#import "MMPushManager.h"
#import "MMPushUtil.h"

#import "ZWPrivacyPolicyManager.h"

/** 闪验appId  */
#define kCLShanYanAppId @"MMTFuKONCXID"
// #define kCLShanYanAppId                 @"TFuKONCX"

@interface AppDelegate () <WXApiDelegate, JJExceptionHandle>

@property (nonatomic, strong) ZWPrivacyPolicyManager *privacyPolicyManager; // 隐私协议首次安装弹窗管理器

@end

@implementation AppDelegate

/**
 * 尽可能使用 initialize + dispatch_once  来替代 +load 方法 , C++静态构造器
 */
+ (void)initialize {
    [super initialize];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"----AppDelegate---initialize--onceToken--");
        [ZWPrivacyPolicyManager initializeAction];
        //        [CMBusMediaAppDelegate regisertService:[[ZWMainAppDelegateService alloc] init]];
    });
    NSLog(@"----AppDelegate---initialize----");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    /** 注册AppID  */
    //    [WXApi registerApp:@"wxd930ea5d5a258f4f" universalLink:@""];

    NSString *link = [NSString stringWithFormat:@"https://%@/", @"m-qa.xiaoke.cn"];
    [MMShareManager registerWechat:@"wx77dab3119a53889a" universalLink:link];

    /* 注册调试工具 */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self registeredDebugDoKitTool];
    });

    // 配置app主题
    [zhThemeOperator themeConfiguration];
    /* 初始化配置信息 */
    [[ModuleContainer sharedModuleContainer] registerConfig];
    /** 加载闪验SDK  */
    [self loadShanYanSDK];

    [ZWPrivacyPolicyManager application:application didFinishLaunchingWithOptions:launchOptions];

    /* 取消约束警告 */
    //    [[NSUserDefaults standardUserDefaults] setValue:@(false) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

    /** 初始化骨架屏  TABAnimated  */
    [self initTABAnimated];
    Class cls = object_getClass([ZWBaseViewController class]); //[ZWBaseViewController class];

    /** 打印ZWBaseViewController 的类方法  */
    printMethodNamesOfClass(cls);

    /** 测试消息转发   实现了methodSignatureForSelector 方法签名, 拦截crash  */
    //    [[[TestBlock alloc] init] methodName:10];
    //    TestBlock *test = [[TestBlock alloc] init];

    /** 统计启动耗时  */
    [AppLaunchTime mark];

    /** 初始化个推SDK  */
    [[MMPushManager sharedInstance] startGTSDKOptions:launchOptions];

    return YES;
}

/**
 * 加载闪验SDK
 */
- (void)loadShanYanSDK {
    // 初始化
    //    [[OneKeyLogin sharedOneKeyLogin] config:kCLShanYanAppId];

    [ZWOneKey staticInstance];
}

#pragma mark - 初始化骨架屏  TABAnimated

- (void)initTABAnimated {
    // 初始化TABAnimated，并设置TABAnimated相关属性
    // 初始化方法仅仅设置的是全局的动画效果
    // 你可以设置`TABViewAnimated`中局部动画属性`superAnimationType`覆盖全局属性，在工程中兼容多种动画
    [[TABAnimated sharedAnimated] initWithOnlySkeleton];
    // 开启日志
    [TABAnimated sharedAnimated].openLog = NO;
    // 是否开启动画坐标标记，如果开启，也仅在debug环境下有效。
    // 开启后，会在每一个动画元素上增加一个红色的数字，该数字表示该动画元素所在下标，方便快速定位某个动画元素。
    [TABAnimated sharedAnimated].openAnimationTag = YES;
    // 关闭缓存
    [TABAnimated sharedAnimated].closeCache = YES;
}

/* 注册调试工具 */
- (void)registeredDebugDoKitTool {
#ifdef DOKIT
    [[DoraemonManager shareInstance] addPluginWithTitle:@"LookinServer" icon:@"doraemon_default" desc:@"LookinServer" pluginName:@"LookinPlugin" atModule:@"业务工具"];
    [[DoraemonManager shareInstance] addPluginWithTitle:@"开发" icon:@"doraemon_default" desc:@"AppLog" pluginName:@"AppLogPlugin" atModule:@"业务工具"];
    [[DoraemonManager shareInstance] install];
    
    /** 添加打印日志  */
//    1、TTY = Xcode 控制台
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    2、ASL = Apple System Logs 苹果系统日志
    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    3、本地文件日志
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 每24小时创建一个新文件
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 最多允许创建7个文件
    [DDLog addLogger:fileLogger];
    
    /** 默认log 开关  */
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"doraemon_env_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

#pragma mark - 加载放崩溃框架JJException
- (void)registeredJJException {
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
}

/**
 * 打印一个类的所有方法
 */
void printMethodNamesOfClass(Class cls) {
    unsigned int count;
    /** 获得方法列表  */
    Method *methodList = class_copyMethodList(cls, &count);
    /** 存储方法名称  */
    NSMutableString *methodNames = [NSMutableString string];
    /** 遍历所有方法列表  */

    for (int i = 0; i < count; i++) {
        /** 获得方法  */
        Method method = methodList[i];
        /** 获得方法名  */
        NSString *methodName = NSStringFromSelector(method_getName(method));
        /** 拼接方法名  */
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    /** 释放  */
    free(methodList);
    /** 打印方法  */
    NSLog(@"%@ %@", cls, methodNames);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    /*  微信登录和分享    */
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [ZWPrivacyPolicyManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [ZWPrivacyPolicyManager applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [ZWPrivacyPolicyManager applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [ZWPrivacyPolicyManager applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [ZWPrivacyPolicyManager applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [ZWPrivacyPolicyManager applicationWillTerminate:application];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [ZWPrivacyPolicyManager application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}

#pragma mark-- Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [ZWPrivacyPolicyManager application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [ZWPrivacyPolicyManager application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [ZWPrivacyPolicyManager application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [ZWPrivacyPolicyManager application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [ZWPrivacyPolicyManager application:application didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    [ZWPrivacyPolicyManager application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

#pragma mark - ----------------------iWatch回调--------------------
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(nonnull void (^)(NSDictionary *_Nullable))reply {
    [ZWPrivacyPolicyManager application:application handleWatchKitExtensionRequest:userInfo reply:reply];
}

#pragma mark - universal link
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    return [ZWPrivacyPolicyManager application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - JJExceptionHandle
- (void)handleCrashException:(nonnull NSString *)exceptionMessage extraInfo:(nullable NSDictionary *)info {
    NSLog(@"exceptionMessage = %@\ninfo = %@", exceptionMessage, info);
}

@end
