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
#import "MMPrivacyManager.h"
#import <CYLTabBarController/CYLTabBarController.h>
#import "DHLaunchAdPageHUD.h"


@interface LaunchViewController ()

@property (nonatomic, assign) BOOL didSetMainViewController;

@end

@implementation LaunchViewController

-(void)name:(void (^)(NSString *name))complete{
    BlockSafeRun(complete, @"111");
    
    NSInteger (^blockName)(NSInteger index) = ^NSInteger(NSInteger index) {
        index += 3;
        NSLog(@"index = %@", @(index));
        return index;
    };
    
    
    NSInteger a = blockName(2);
    NSLog(@"a = %@", @(a));
    
    NSInteger b = [self eh_sum](2);
    NSLog(@"b = %@", @(b));

    
}

- (NSInteger (^)(NSInteger a))eh_sum {
    NSInteger (^block)(NSInteger a) = ^NSInteger(NSInteger a) {
        return a*2;
    };
    return block;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self name:^(NSString *name) {
        NSLog(@"name:%@", name);
    }];
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


- (void)remakePage {
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


- (void)loadPrivacy {
    
    if (![MMPrivacyManager.sharedInstance hasShowedAppPrivacy]) {
        [MMPrivacyManager.sharedInstance showPrivacyAlert:self.view clickResult:^(NSInteger index) {
            if (index == 1) {
                //点击同意
                //回到首页
                [self remakePage];
                [MMPrivacyManager.sharedInstance markAppPrivacyShowed];
            }
        }];
    } else {
        [self remakePage];
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
        [self _setMainVc];
        
    };
    self.viewControllers = @[vc];
}

- (void)_loadAdPageHUD:(dispatch_block_t)completeBlock {
    NSString *adImageJPGUrl = @"http://e.hiphotos.baidu.com/image/pic/item/a1ec08fa513d2697e542494057fbb2fb4316d81e.jpg";
    NSString *adimageGIFUrl = @"https://upload-images.jianshu.io/upload_images/550672-aa96b5cca33cb802.gif?imageMogr2/auto-orient/strip";
    NSString *adImageJPGPath = @"adImage1";//[[NSBundle mainBundle] pathForResource:@"adImage2" ofType:@"jpg"];
    NSString *adImageGifPath = [[NSBundle mainBundle] pathForResource:@"adImage3" ofType:@"gif"];
//    adImageGifPath = [[NSBundle mainBundle] pathForResource:@"eqh_home" ofType:@"gif"];
    __block BOOL didFinishLaunchAd = NO;
    DHLaunchAdPageHUD *launchAd = [[DHLaunchAdPageHUD alloc] initWithFrame:CGRectMake(0, 0, DDScreenW, DDScreenH) aDduration:10.0 aDImageUrl:adImageGifPath hideSkipButton:NO launchAdClickBlock:^(NSInteger index) {
        if (didFinishLaunchAd) {
            return;
        }
        didFinishLaunchAd = YES;

        NSURL *adURL = nil;
        switch (index) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                NSLog(@"[AppDelegate]:点了广告图片");
                adURL = [NSURL URLWithString:@"https://www.baidu.com"];
            }
                break;
                
            default:
                break;
        }
        
        if (completeBlock) {
            completeBlock();
        }

        if (adURL) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:adURL options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:adURL];
                }
            });
        }
    }];
    (void)launchAd;
}

- (void)loadComponent
{
    @pas_weakify_self
    [self _loadAdPageHUD:^{
        @pas_strongify_self
        [self _setMainVc];
    }];

//    NSDictionary *launchOptions = WM.pushManager.launchOptions;
//    [WM.pushManager handleLaunchOptions];
    
//    [self handleUniversalLinkLaunch:launchOptions];
    
    //处理openURL 时候的universalLink
//    if (WM.wakeUpAppRoute.length > 0){
//        [Router openApp:WM.wakeUpAppRoute];
//        WM.wakeUpAppRoute = nil;
//    }
}

#pragma mark - 设置主控制器
- (void)_setMainVc {
    if (self.didSetMainViewController) {
        return;
    }
    self.didSetMainViewController = YES;

    dispatch_block_t setMainBlock = ^{
        [self setNavigationBarHidden:YES animated:NO];
        ZWTabBarController *mainVC = [[ZWTabBarController alloc] init];
        [self setViewControllers:@[mainVC] animated:NO];
        [mainVC build];
    };

    if (NSThread.isMainThread) {
        setMainBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), setMainBlock);
    }
}




@end
