//
//  ZWMainAppDelegateService.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWMainAppDelegateService.h"
#import "ZWHttpNetworkManager.h"
#import "ZWCommonUtil.h"
#import "VersionUpgradeViewController.h"
#import "LaunchViewController.h"
#import "ZWNavigationController.h"
#import "UIColor+Ext.h"
#import "ZWUserAccountManager.h"


@implementation ZWMainAppDelegateService

+ (void)initialize
{
    [super initialize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    /** 初始化网络信息  */
    [[ZWHttpNetworkManager sharedHttpManager] initializeData];
    /** 加载本地缓存信息  */
    [ZWCommonUtil checkAndWriteLocalCMSDataToCache];
    
    [self configAppearance];
    
    [self loadLaunchVC];
    
    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
    
    return YES;
}

/** 配置导航信息及通用tabview属性  */
- (void)configAppearance
{
    if (@available(iOS 15.0, *)) {
        UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]];
        
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 64) andRoundSize:0];
        appearance.titleTextAttributes = @{NSFontAttributeName:PASFont(17),NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"#333333"]};
        appearance.shadowColor = UIColor.clearColor;
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = appearance;
    } else {
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 64) andRoundSize:0] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]] setTitleTextAttributes:@{NSFontAttributeName:PASFont(17),NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"#333333"]}];
        [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]].shadowImage = [UIImage new];
    }
   
    
    NSDictionary* barButtonItemAttributes = @{NSFontAttributeName: PASFont(14),NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"#4F7AFDFF"]};
    [[UIBarButtonItem appearance] setTitleTextAttributes: barButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes: barButtonItemAttributes forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes: barButtonItemAttributes forState:UIControlStateSelected];
    [[UIBarButtonItem appearance] setTitleTextAttributes: barButtonItemAttributes forState:UIControlStateDisabled];
    
    /** 这个是全局设置 UITableView 的通用属性  */
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        //系统通讯录选择 会导致列表上移到搜索框下面
//        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}


/** 加载引导页  */
- (void)loadGuidePage{
    VersionUpgradeViewController *vc = [[VersionUpgradeViewController alloc] init];
    @pas_weakify_self
    vc.guideCompleteBlock = ^(NSInteger index, GuideActionType type) {
        @pas_strongify_self
        /* 引导完成 */
        [self loadLaunchVC];
    };
    [[UIApplication sharedApplication].delegate window].rootViewController = vc;
}

/** 加载启动页  */
- (void)loadLaunchVC
{
    dispatch_block_t block = ^{
        LaunchViewController *launchVc = [[LaunchViewController alloc] init];
        [[UIApplication sharedApplication].delegate window].rootViewController = launchVc;
        [launchVc remakePage];
    };
    if (ZWCurrentUserInfo
        && ZWCurrentUserInfo.pid > 0
        && ZWCurrentUserInfo.userWid > 0)
    {
        /** 请求tabBar 配置信息  */
//        [CustomTabPopManager.shared requestTabConfigList:^(BOOL success, TabbarConfig * config) {
//            if (success && config!= nil){
//                //Success. set tabController from server
//                [TabbarConfig saveTabListConfig:config];
//            } else {
//                //Use Default TabConfig
//            }
//            block();
//        }];
    } else {
        block();
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[ZWHttpNetworkManager sharedHttpManager] openNetMonitoring];
}



@end
