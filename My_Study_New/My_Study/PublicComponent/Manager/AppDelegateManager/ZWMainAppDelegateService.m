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
#import <Photos/Photos.h>
#import "ZWAlertUtil.h"

#define BuglyAppId      @"adf13"

@interface ZWMainAppDelegateService ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHAsset *previousAsset;

@property (nonatomic, assign) NSInteger previousCount;

@end

@implementation ZWMainAppDelegateService

+ (void)initialize {
    [super initialize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    /** 初始化网络信息  */
    [[ZWHttpNetworkManager sharedZWHttpNetworkManager] initializeData];
    /** 加载本地缓存信息  */
    [ZWCommonUtil checkAndWriteLocalCMSDataToCache];

    [self configAppearance];

    [self loadLaunchVC];

    /** 初始化IQKeyboardManager  */
    [self _initIQKeyboardManager];
    
    /// bugly 注册
    [self _initiBugly];
    
    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];

    return YES;
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
    dispatch_block_t block = ^{
        LaunchViewController *launchVc                                         = [[LaunchViewController alloc] init];
        [[UIApplication sharedApplication].delegate window].rootViewController = launchVc;
        [launchVc loadPrivacy];
    };
    
    ZWUserAccountManager *manager = [ZWUserAccountManager sharedZWUserAccountManager];
    ZWUserAccountManager *managerInit = [[ZWUserAccountManager alloc] init];
    ZWUserAccountManager *managerCopy = [manager copy];
    ZWUserAccountManager *managerMutableCopy = [manager mutableCopy];
    NSLog(@"manager = %@\nmanagerInit = %@\nmanagerCopy = %@\nmanagerMutableCopy = %@",
          manager,
          managerInit,
          managerCopy,
          managerMutableCopy);

    if (ZWCurrentUserInfo &&
        ZWCurrentUserInfo.pid > 0 &&
        ZWCurrentUserInfo.userWid > 0) {
        block();
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[ZWHttpNetworkManager sharedZWHttpNetworkManager] openNetMonitoring];
    
    // 注册相册变化通知
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 移除相册变化通知
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // 在相册变化时调用，你可以在这里检查是否有新的截屏图片
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkForScreenshots];
    });
}

#pragma mark - 检测截屏图片
- (void)checkForScreenshots {
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];

    if (fetchResult.count > 0) {
        PHAsset *latestAsset = fetchResult.firstObject;
        /** 是否是截图  */
        BOOL isScreenshot = latestAsset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot;
        /** 是否和之前的图片相同  */
        BOOL isSameAsset = ![self isSameAsset:latestAsset asPreviousAsset:self.previousAsset];
        /** 是否是新增  */
        BOOL isAdd = fetchResult.count > self.previousCount;
        
        // 检查图片是否是新增的（你可以根据实际需要添加更多的判断条件）
        // 你可以保存一个变量来记录最新的图片，然后在这里检查是否有更新
        if (isSameAsset && isScreenshot && isAdd) {
            // 处理新增的图片
            self.previousAsset = latestAsset;
            [self loadScreenshotImage:latestAsset];
        }
        self.previousCount = fetchResult.count;
    }
}

#pragma mark - 图片是否相同
- (BOOL)isSameAsset:(PHAsset *)asset1 asPreviousAsset:(PHAsset *)asset2 {
    // 判断两个 PHAsset 是否相同，你可能需要根据实际需求调整这个逻辑
    return [asset1.localIdentifier isEqualToString:asset2.localIdentifier];
}

#pragma mark - 获取相册图片
- (void)loadScreenshotImage:(PHAsset *)asset {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.synchronous = YES;

    [imageManager requestImageForAsset:asset
                            targetSize:PHImageManagerMaximumSize
                           contentMode:PHImageContentModeDefault
                               options:requestOptions
                         resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                             // 在这里处理截屏图片 result
                             if (result) {
                                 // 显示或保存截屏图片
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self _handleShowScreenShotImage:result];
                                 });
                             }
                         }];
}

#pragma mark - 显示截屏图片
- (void)_handleShowScreenShotImage:(UIImage *)result {
    [ZWAlertUtil mmConfirm:@"显示截图" centerViewBlock:^UIView *_Nonnull {
        UIView *centerView = [UIView viewForColor:UIColor.whiteColor withFrame:CGRectMake(0, 0, 300, 300)];
        UIImageView *imageView = [UIImageView imageViewForImage:result withFrame:centerView.bounds];
        [centerView addSubview:imageView];
        return centerView;
    } cancelName:@"取消" okName:@"确定" cancelBlock:^{

    } okBlock:^{

    }];
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
