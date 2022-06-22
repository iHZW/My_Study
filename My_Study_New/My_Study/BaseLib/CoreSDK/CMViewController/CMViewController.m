//
//  CMViewController.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMViewController.h"
#import "CMNotificationCenter.h"
#import "CMNetLayerNotificationCenter.h"
#import <objc/runtime.h>
#import "ZWSDK.h"


@interface CMViewController () <UINavigationControllerDelegate>

/**
 *  换肤处理动作
 */
@property (nonatomic, strong) NSMutableDictionary *themeChangeActions;

- (void)initData;

@end


@implementation CMViewController

+ (void)load
{
    [NSObject swizzledInstanceMethod:[CMViewController class] originalSelector:NSSelectorFromString(@"dealloc") swizzledSelector:NSSelectorFromString(@"swizzle_dealloc")];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initData];
    }
    
    return self;
}

- (void)dealloc
{
//    CMLogDebug(LogBusinessBasicLib, @"dealloc<<<<<<<<<<<<<<%@<<<<%@<<<<", self, self.objectTag);
#if !__has_feature(objc_arc)
    self.objectTag              = nil;
    self.themeChangeActions     = nil;
    [super dealloc];
#endif
}

- (void)swizzle_dealloc
{
    [self removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [self swizzle_dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    if (SYSTEM_VERSION_LESS_THAN(@"5")) self.navigationController.delegate = self;
    if ((floor(NSFoundationVersionNumber)) > NSFoundationVersionNumber_iOS_6_1 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) [self setNeedsStatusBarAppearanceUpdate];
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    [[CMNetLayerNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNetLayerResponse:) name:[self objectID] object:nil];
    [[CMNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyThemeChange:) name:kThemeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyStatusBarFrameChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && self.view.window == nil)
    {
        [self receiveLowMemoryWarning];
        self.view = nil;
        [[CMNetLayerNotificationCenter defaultCenter] removeObserver:self];
        [[CMNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - StatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//}
//
//- (BOOL)prefersHomeIndicatorAutoHidden  API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(watchos, tvos)
//{
//    return YES;
//}

#pragma mark - Private's methods
- (void)initData
{
    _resident            = NO;
    _tabBarIndex         = -1;
    _tabBarStatus        = NO;
    _navigationBarStatus = YES;
    _isModal             = NO;
    
    [self initExtendedData];
}

#pragma mark - Public's methods
/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData
{
    
}

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning
{
    
}

/**
 *  判断该viewcontroller当前是否是可见的，用来在app从后台启前台的时候决定要不要刷新数据或者view
 *
 *  @return 可见YES, 否则NO
 */
- (BOOL)isVisible
{
    return (self.isViewLoaded && self.view.window);
}

#pragma mark - UINavigationControllerDelegate's methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    static UIViewController *lastController = nil;
    
    if (lastController != nil)
    {
        if (SYSTEM_VERSION_LESS_THAN(@"5") && [lastController respondsToSelector:@selector(viewWillDisappear:)])
            [lastController viewWillDisappear:animated];
        
        if (![navigationController.viewControllers containsObject:lastController])
            [self removeAllObservers];
    }
    
    // 为了防止无动画pop页面(无动画pop时,会先调dealloc,然后在调用对应的navigationController委托方法),所以要retain对应Controller,后再做release处理
#if !__has_feature(objc_arc)
    UIViewController *tmpVC = [viewController retain];
    [lastController release];
    lastController = tmpVC;
#else
    lastController = viewController;
#endif
    
    if (SYSTEM_VERSION_LESS_THAN(@"5") && [lastController respondsToSelector:@selector(viewWillAppear:)])[viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    static UIViewController *lastController = nil;
    
    if (lastController != nil)
    {
        if (SYSTEM_VERSION_LESS_THAN(@"5") && [lastController respondsToSelector:@selector(viewDidDisappear:)])
            [lastController viewDidDisappear:animated];
    }
    
    // 为了防止无动画pop页面(无动画pop时,会先调dealloc,然后在调用对应的navigationController委托方法),所以要retain对应Controller,后再做release处理
#if !__has_feature(objc_arc)
    UIViewController *tmpVC = [viewController retain];
    [lastController release];
    lastController = tmpVC;
#else
    lastController = viewController;
#endif
    
    if (SYSTEM_VERSION_LESS_THAN(@"5") && [lastController respondsToSelector:@selector(viewDidAppear:)])[viewController viewDidAppear:animated];
}

#pragma mark - PASBaseProtocol's method
/**
 *  对象标识别
 */
- (NSString *)objectID
{
    return self.objectTag;
}

/**
 *  数据刷新处理
 *
 *  @param userInfo 字典数据键值为 kRefreshType, kForceRefresh, kReqPageNo, kReqPos, kReqNum信息
 */
- (void)refreshData:(NSDictionary *)userInfo
{
    
}

/**
 *  换肤通知处理函数
 *
 *  @param notification 通知参数
 */
- (void)notifyThemeChange:(NSNotification *)notification
{
//    CMLogDebug(LogBusinessBasicLib, @"ReceiveThemeChangeNotification:%@", notification.userInfo);
    
    if (self.themeChangeActions.count > 0)
    {
        for (CMThemeChangeCallback call in self.themeChangeActions.allValues)
        {
            if (call) {
                call(notification.userInfo);
            }
        }
    }
}

/**
 *  换肤通知处理函数
 *
 *  @param callback   CMThemeChangeCallback
 *  @param identifier 换肤标记
 */
- (void)attachThemeChangeCallback:(CMThemeChangeCallback)callback identifier:(NSString *)identifier
{
    if (!self.themeChangeActions) {
        self.themeChangeActions = [NSMutableDictionary dictionary];
    }
    callback(nil);
    
    [self.themeChangeActions setObject:[callback copy] forKey:identifier];
}

/**
 *  网络层数据返回通知处理函数
 *
 *  @param notification 通知参数
 */
- (void)notifyNetLayerResponse:(NSNotification *)notification
{
    
}

/**
 *  StatusBarFrameChange
 *
 *  @param notification 通知参数
 */
- (void)notifyStatusBarFrameChange:(NSNotification *)notification
{
    
}

/**
 *  清空所有观察者
 */
- (void)removeAllObservers
{
    [[CMNotificationCenter defaultCenter] removeObserver:self];
    [[CMNetLayerNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  导航栏背景颜色设置
 */
- (UIColor *)navigationBGColor
{
    return [UIColor blueColor];
}

/**
 *  底部TabBar北京颜色
 */
- (UIColor *)tabBarBGColor
{
    return [UIColor lightGrayColor];
}

@end
