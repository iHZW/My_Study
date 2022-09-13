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
#import "zhThemeOperator.h"
#import "TABAnimated.h"


#ifdef DOKIT
#import "DoraemonManager.h"
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
    // 配置app主题
    [zhThemeOperator themeConfiguration];
    /* 初始化配置信息 */
    [[ModuleContainer sharedModuleContainer] registerConfig];
    
    [CMBusMediaAppDelegate serviceManager:@selector(application:didFinishLaunchingWithOptions:) withParameters:@[application, launchOptions ? : [NSNull null]]];
    
    /* 取消约束警告 */
//    [[NSUserDefaults standardUserDefaults] setValue:@(false) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    /** 初始化骨架屏  TABAnimated  */
    [self initTABAnimated];
    
    return YES;
}

#pragma mark - 初始化骨架屏  TABAnimated
- (void)initTABAnimated
{
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
