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
#import "LaunchViewController.h"
#import "ZWNavigationController.h"
#import "UIColor+Ext.h"
#import "ZWUserAccountManager.h"
#import "IQKeyboardManager.h"

#import <JJException/JJException.h>
#import <Bugly/Bugly.h>
#import <YTKNetwork/YTKNetworkConfig.h>

#import "UIAlertUtil.h"
#import "ZWAlertUtil.h"
#import "MMPrivacyManager.h"

#define BuglyAppId      @"adf13"

@interface ZWMainAppDelegateService ()

@property (nonatomic) BOOL observingScreenshots;
@property (nonatomic) BOOL privacyServicesStarted;
@property (nonatomic) NSUInteger screenshotGeneration;

@end

@implementation ZWMainAppDelegateService

+ (void)initialize {
    [super initialize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    [self configAppearance];

    [self startServicesAfterPrivacyConsent];
    [self loadLaunchVC];

    /** 初始化IQKeyboardManager  */
    [self _initIQKeyboardManager];
    
    
    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];

    return YES;
}

- (void)startServicesAfterPrivacyConsent {
    if (![MMPrivacyManager.sharedInstance hasShowedAppPrivacy] || self.privacyServicesStarted) return;
    self.privacyServicesStarted = YES;
    /** 初始化网络信息  */
    [[ZWHttpNetworkManager sharedZWHttpNetworkManager] initializeData];
    /** 加载本地缓存信息  */
    [ZWCommonUtil checkAndWriteLocalCMSDataToCache];

    [self _initiBugly];
}


#pragma mark - 初始化bugly
- (void)_initiBugly {
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
    [JJException registerExceptionHandle:(id<JJExceptionHandle>)self];
    
    /// bugly 注册
    [Bugly startWithAppId:BuglyAppId];
}

/** 配置导航信息及通用tabview属性  */
- (void)configAppearance {
    if (@available(iOS 15.0, *)) {
        UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]];

        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundImage            = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 64) andRoundSize:0];
        appearance.titleTextAttributes        = @{NSFontAttributeName: PASFont(17), NSForegroundColorAttributeName: [UIColor colorFromHexCode:@"#333333"]};
        appearance.shadowColor                = UIColor.clearColor;
        navBar.standardAppearance             = appearance;
        navBar.scrollEdgeAppearance           = appearance;
    } else {
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 64) andRoundSize:0] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]] setTitleTextAttributes:@{NSFontAttributeName: PASFont(17), NSForegroundColorAttributeName: [UIColor colorFromHexCode:@"#333333"]}];
        [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[ZWNavigationController.class]].shadowImage = [UIImage new];
    }

    NSDictionary *barButtonItemAttributes = @{NSFontAttributeName: PASFont(14), NSForegroundColorAttributeName: [UIColor colorFromHexCode:@"#4F7AFDFF"]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateSelected];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateDisabled];

    /** 这个是全局设置 UITableView 的通用属性  */
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].estimatedRowHeight           = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        // 系统通讯录选择 会导致列表上移到搜索框下面
        //        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        //        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

/** 加载启动页  */
- (void)loadLaunchVC {
    // 同意前只创建协议容器，不提前读取账号或执行首页业务。
    LaunchViewController *launchVC = [[LaunchViewController alloc] init];
    UIApplication.sharedApplication.delegate.window.rootViewController = launchVC;
    [launchVC loadPrivacy];
}


/**
 * 初始化IQKeyboardManager
 */
- (void)_initIQKeyboardManager {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setEnable:YES];
}




#pragma mark - 网络初始化配置
- (void)_initNetWork {
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    config.baseUrl = @"";
    
}

- (BOOL)canHandleScreenshot {
    return [MMPrivacyManager.sharedInstance hasShowedAppPrivacy] &&
        UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![MMPrivacyManager.sharedInstance hasShowedAppPrivacy]) return;
    [[ZWHttpNetworkManager sharedZWHttpNetworkManager] openNetMonitoring];
    [self startObservingScreenshots];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self stopObservingScreenshots];
}

#pragma mark - 系统截屏通知
- (void)startObservingScreenshots {
    if (![self canHandleScreenshot] || self.observingScreenshots) return;
    self.screenshotGeneration++;
    self.observingScreenshots = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)stopObservingScreenshots {
    self.screenshotGeneration++;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    self.observingScreenshots = NO;
}

- (UIImage *)captureCurrentAppImage {
    // 系统截屏通知不携带原图；只渲染本应用画面，不访问用户相册。
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    if (!window || window.hidden || CGRectIsEmpty(window.bounds)) return nil;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:window.bounds];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
    }];
}

- (void)userDidTakeScreenshot:(NSNotification *)notification {
    // 通知在系统完成截屏后到达；先保存画面，再延后一轮展示，避免将弹窗本身截进去。
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf userDidTakeScreenshot:notification]; });
        return;
    }
    if (![self canHandleScreenshot] || !self.observingScreenshots) return;
    UIImage *image = [self captureCurrentAppImage];
    if (!image) return;
    NSUInteger generation = ++self.screenshotGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || generation != self.screenshotGeneration || !self.observingScreenshots || ![self canHandleScreenshot]) return;
        [self _handleShowScreenShotImage:image];
    });
}

#pragma mark - 显示截屏图片
- (void)_handleShowScreenShotImage:(UIImage *)result {
    if (![self canHandleScreenshot] || !self.observingScreenshots) return;
    [ZWAlertUtil mmConfirm:@"显示截图" centerViewBlock:^UIView *_Nonnull {
        UIView *centerView = [UIView viewForColor:UIColor.whiteColor withFrame:CGRectMake(0, 0, 300, 300)];
        UIImageView *imageView = [UIImageView imageViewForImage:result withFrame:centerView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [centerView addSubview:imageView];
        return centerView;
    } cancelName:@"取消" okName:@"确定" cancelBlock:^{

    } okBlock:^{

    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end



#pragma mark - <JJExceptionHandle>
@interface ZWMainAppDelegateService (JJExceptionHandle) <JJExceptionHandle>
@end
@implementation ZWMainAppDelegateService (JJExceptionHandle)
- (void)handleCrashException:(nonnull NSString *)exceptionMessage extraInfo:(nullable NSDictionary *)info {
    if ([exceptionMessage containsString:@"[GTSThread main]"] && [exceptionMessage containsString:@"[TimerObject fireTimer]"]) {
        NSLog(@"log_error crash ignore = %@-%s-%d", exceptionMessage, __func__, __LINE__);
    } else {
        /** 上报日志到bugly  */
        [Bugly reportException:[NSException exceptionWithName:@"AvoidCrash" reason:exceptionMessage userInfo:info]];
    }
}
@end
