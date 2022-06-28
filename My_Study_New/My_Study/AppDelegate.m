//
//  AppDelegate.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWBaseViewController.h"
#import "HomeViewController.h"
//#import "TwoPageViewController.h"
#import "CRMViewController.h"
#import "AppLaunchTime.h"
#import "ZWNavigationController.h"
#import "ModuleContainer.h"
#import "CMBusMediaAppDelegate.h"
#import "ZWMainAppDelegateService.h"


#ifdef DOKIT
#import <DoraemonKit/DoraemonManager.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    [super initialize];
    
    [CMBusMediaAppDelegate regisertService:[[ZWMainAppDelegateService alloc] init]];    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [AppLaunchTime mark];
    /* 注册调试工具 */
    [self registDebugDoKitTool];
    /* 初始化配置信息 */
    [[ModuleContainer sharedModuleContainer] registerConfig];
    
    [CMBusMediaAppDelegate serviceManager:@selector(application:didFinishLaunchingWithOptions:) withParameters:@[application, launchOptions ? : [NSNull null]]];
    
    /* 取消约束警告 */
//    [[NSUserDefaults standardUserDefaults] setValue:@(false) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    return YES;
}

/* 注册调试工具 */
- (void)registDebugDoKitTool{
#ifdef DOKIT
    [[DoraemonManager shareInstance] addPluginWithTitle:@"LookinServer" icon:@"doraemon_default" desc:@"LookinServer" pluginName:@"LookinPlugin" atModule:@"业务工具"];
    [[DoraemonManager shareInstance] addPluginWithTitle:@"开发" icon:@"doraemon_default" desc:@"AppLog" pluginName:@"AppLogPlugin" atModule:@"业务工具"];
    [[DoraemonManager shareInstance] install];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {

    [CMBusMediaAppDelegate serviceManager:@selector(applicationWillResignActive:) withParameters:@[application]];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    [CMBusMediaAppDelegate serviceManager:@selector(applicationDidEnterBackground:) withParameters:@[application]];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {

    [CMBusMediaAppDelegate serviceManager:@selector(applicationWillEnterForeground:) withParameters:@[application]];

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    [CMBusMediaAppDelegate serviceManager:@selector(applicationDidBecomeActive:) withParameters:@[application]];

}


- (void)applicationWillTerminate:(UIApplication *)application {

    [CMBusMediaAppDelegate serviceManager:@selector(applicationWillTerminate:) withParameters:@[application]];
}


@end
