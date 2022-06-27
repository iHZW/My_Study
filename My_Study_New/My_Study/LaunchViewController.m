//
//  LaunchViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LaunchViewController.h"
#import "LoginViewController.h"
#import "VersionUpgradeViewController.h"
#import "ZWTabBarController.h"
#import "ZWUserAccountManager.h"


@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    
    
}

/** 加载引导页  */
- (void)loadGuidePage{
    VersionUpgradeViewController *vc = [[VersionUpgradeViewController alloc] init];
    @pas_weakify_self
    vc.guideCompleteBlock = ^(NSInteger index, GuideActionType type) {
        @pas_strongify_self
        /* 引导完成 */
        [self loadLoginPage];
    };
    vc.hideNavigationBar = YES;
    self.viewControllers = @[vc];
}


- (void)remakePage
{
    ZWUserAccountManager *accountManager = ZWSharedUserAccountManager;
    if (!accountManager.currentUserInfo) {
        /* 判断是否加载引导页 */
        if (![VersionUpgradeViewController isFirstStartApp]) {
            [self loadGuidePage];
        } else {
            [self loadLoginPage];
        }
    } else {
        [self loadComponent];
    }
}

/**
 *  加载登录页
 */
- (void)loadLoginPage
{
    self.navigationBarHidden = NO;
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.hideNavigationBar = YES;
    @pas_weakify_self
    vc.loginCompleted = ^{
        @pas_strongify_self
        [self remakePage];
    };
    self.viewControllers = @[vc];
}

- (void)loadComponent
{
    self.navigationBarHidden = YES;
    ZWTabBarController *mainVC = [[ZWTabBarController alloc] init];
    NSArray *viewControllers = @[mainVC];
    [self setViewControllers:viewControllers];
    
    [mainVC build];
//    NSDictionary *launchOptions = WM.pushManager.launchOptions;
//    [WM.pushManager handleLaunchOptions];
    
//    [self handleUniversalLinkLaunch:launchOptions];
    
    //处理openURL 时候的universalLink
//    if (WM.wakeUpAppRoute.length > 0){
//        [Router openApp:WM.wakeUpAppRoute];
//        WM.wakeUpAppRoute = nil;
//    }
}




@end
