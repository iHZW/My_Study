//
//  AppDelegate.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BaseViewController.h"
#import "HomeViewController.h"
//#import "TwoPageViewController.h"
#import "CRMViewController.h"
#import "AppLaunchTime.h"

#ifdef DOKIT
#import <DoraemonKit/DoraemonManager.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [AppLaunchTime mark];
    
    [self registDebugDoKitTool];
    
    [self loadSubViewControllers];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)loadSubViewControllers
{
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    
    HomeViewController *vc1 = [HomeViewController new];
    vc1.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    CRMViewController *vc2 = [CRMViewController new];
    vc2.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:1];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    ViewController *vc3 = [ViewController new];
    vc3.title = @"History";
    vc3.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemHistory tag:2];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    
    BaseViewController *vc4 = [BaseViewController new];
    vc4.title = @"Recents";
    vc4.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemRecents tag:3];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    tabVC.viewControllers = @[nav1,nav2,nav3,nav4];
    self.window.rootViewController = tabVC;
    
}

/* 注册调试工具 */
- (void)registDebugDoKitTool{
#ifdef DOKIT
    [[DoraemonManager shareInstance] addPluginWithTitle:@"LookinServer" icon:@"doraemon_default" desc:@"LookinServer" pluginName:@"LookinPlugin" atModule:@"业务工具"];
//    [[DoraemonManager shareInstance] addPluginWithTitle:@"开发" icon:@"doraemon_default" desc:@"AppLog" pluginName:@"AppLogPlugin" atModule:@"业务工具"];
    [[DoraemonManager shareInstance] install];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
