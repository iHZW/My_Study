//
//  PASBaseViewController.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/4.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASBaseViewController.h"
#import "UIImage+Addition.h"
//#import "PASShareModule.h"
//#import "PASSchemeManager.h"
#import "UIButton+Navigation.h"
//#import "PASStaticCheckingManager.h"
//#import "PASWebViewManager.h"
#import "PASDefine.h"
//#import "PASVastMCIDManager.h "
//#import "TalkingDataAction.h"       // 后续埋点解耦
//#import "PASSwitchPageManagerUtil.h"

@interface PASBaseViewController()


@end

@implementation PASBaseViewController

#pragma mark - private's method
- (void)changeNavigationBarScheme
{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBackgroundImage:[self navigationBackgroupImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)setNavigationLeftItem
{
    UIButton *cusbtn        = [UIButton customNormalButton:UIButtonTypeCustom frame:CGRectMake(0, 0, 61, 31) offsetSize:CGSizeMake(0, 0)   title:@"" image:[UIImage imageNamed:@"top_icon_back"] align:NSTextAlignmentLeft];
    @pas_weakify_self
    [cusbtn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        @pas_strongify_self
//        [[PASNavigator sharedPASNavigator] pop:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:cusbtn];
    [self.navigationItem addLeftBarButtonItem:barItem];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11")){
//        UIImage *backButtonImage = [[UIImage imageNamed:@"top_icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.navigationController.navigationBar.backIndicatorImage = backButtonImage;
//        self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
//        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -5) forBarMetrics:UIBarMetricsDefault];
//
//    } else {
//
//        CGFloat xOffset = IS_IPHONE_4 || IS_IPHONE_5 ? 20 : 30;
//
//        UIImage *backButtonImage = [[UIImage imageNamed:@"top_icon_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, xOffset, 0, 0)];
//        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//
//        if (!IS_IPHONE_4 && !IS_IPHONE_5)
//        {
//            // 将返回按钮的文字position设置不在屏幕上显示
//            [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
//        }
//    }
//
//
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

/**
 *  右导航搜索分享
 */
- (void)setShareAndSearchItem
{
    // 分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    shareBtn.frame = CGRectMake(0, 0, 30, 31);
    [shareBtn addTarget:self action:@selector(action_share:) forControlEvents:(UIControlEventTouchUpInside)];
    [shareBtn setImage:[UIImage imageNamed:@"top_icon_share"] forState:UIControlStateNormal];
    
    // 搜索按钮
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(30, 0, 30, 31);
    [searchBtn addTarget:self action:@selector(action_search:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"top_icon_search"] forState:UIControlStateNormal];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 31)];
    rightView.backgroundColor = [UIColor clearColor];
    [rightView addSubview:shareBtn];
    [rightView addSubview:searchBtn];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    rightItem.width = 60;

    [self.navigationItem addRightBarButtonItem:rightItem];
}

- (void)action_share:(id)sender
{
//    [[PASShareModule sharedPASShareModule]  shareWithShareModel:nil actionBlock:nil];
}

- (void)action_search:(id)sender
{
     //6.0 修改行情详情页 跳转搜索二级页面
//    [PASSwitchPageManager switchHomeSearchSecondPageForStock:nil];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"text", @"stock", @"indexname", @"0", @"home", @"1" , @"textType", kPATDEventMarketSearch , @"ATDEventType", nil];
//    [PASSwitchPageManager switchHomeSearchFirstPage:nil dic:dic];
}

- (void)removeAllObservers
{
    [super removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- public's method
/**
 *  无导航栏显示statusbar处理
 */
- (void)showStatusBarWithNoNavigation
{
//    if ([self.navigationController isKindOfClass:[CMMultiLayerNavigationController class]]) {
//        CMMultiLayerNavigationController *navc = (CMMultiLayerNavigationController *)self.navigationController;
//        navc.statusBarView.backgroundImage = [UIImage navigationBackgroupImageWithSize:CGSizeMake(kMainScreenWidth, kSysStatusBarHeight)];
//        [navc.statusBarView setHidden:NO];
//    }

}

/**
 *  移除无导航栏显示statusbar处理
 */
- (void)removeStatusBarWithNoNavigation
{
//    if ([self.navigationController isKindOfClass:[CMMultiLayerNavigationController class]]) {
//        CMMultiLayerNavigationController *navc = (CMMultiLayerNavigationController *)self.navigationController;
//        [navc.statusBarView setHidden:YES];
//    }
}

- (void)registNotificationForLogout
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:KNotificationWithLogoutName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginInNotification:) name:KNotificationWithLoginName object:nil];
}

- (void)removeNotificationForLogout
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationWithLogoutName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationWithLoginName object:nil];
}

- (void)loginInNotification:(NSNotification *)notification
{
    //登录完成通知
}

- (void)logoutNotification:(NSNotification *)notification
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** 默认控制器的名称 */
    self.title = NSStringFromClass([self class]);
    [self changeNavigationBarScheme];
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);
    [self setNavigationLeftItem];
    [self loadUIData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL isHidden = ![self navigationBarStatus];
    [self.navigationController setNavigationBarHidden:isHidden animated:animated];
//    [[PASNavigator sharedPASNavigator].tabBarController.tabBarView setUserInteractionEnabled:NO];
//    BOOL isHiddenTabBar = ![self tabBarStatus];
//    [[PASNavigator sharedPASNavigator] setTabBarHidden:isHiddenTabBar animated:YES];
    [self loadExtendToolView];
    [self removeStatusBarWithNoNavigation];
    [self customViewWillAppear:animated];
    
//    NSString *paget = [NSString stringWithUTF8String:object_getClassName(self)];
//    [TalkingDataAction trackMethodBegin:paget];
    
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    BOOL isHiddenTabBar = ![self tabBarStatus];
//    [[PASNavigator sharedPASNavigator] setTabBarHidden:isHiddenTabBar animated:NO];
//    [[PASNavigator sharedPASNavigator].tabBarController.tabBarView setUserInteractionEnabled:YES];
    [self customViewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self customViewWillDisappear:animated];
    
//    NSString *paget = [NSString stringWithUTF8String:object_getClassName(self)];
//    [TalkingDataAction trackMethodEnd:paget];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self customViewDidDisappear:animated];
}

/**
 *  导航栏颜色设置
 */
- (UIColor *)navigationBGColor
{
    return [UIColor blueColor];//PASFaceColorWithKey(@"p19");
}

- (UIImage *)navigationBackgroupImage{
    
    return [UIImage imageNamed:@""];
}

- (void)dealloc
{
    [self removeAllObservers];
    NSLog(@"%s -- %@", __func__, NSStringFromClass([self class]));

}

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning
{
    [super receiveLowMemoryWarning];
}

/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData
{
    [super initExtendedData];
}

/**
 *  界面加载(子类继承时,子类扩展界面加载可在此函数中进行处理)
 */
- (void)loadUIData
{
}

/**
 *  大智慧兼容处理
 */
- (void)updateLayout
{
    [self.view layoutIfNeeded];
}

/**
 *  加载扩展工具师徒
 */
- (void)loadExtendToolView
{
}

/**
 *  Called when the view is about to made visible. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewWillAppear:(BOOL)animated
{
    
}

/**
 *  Called when the view has been fully transitioned onto the screen. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewDidAppear:(BOOL)animated
{
    
}

/**
 *  Called when the view is dismissed, covered or otherwise hidden. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewWillDisappear:(BOOL)animated
{
    
}

/**
 *  Called after the view was dismissed, covered or otherwise hidden. Default does nothing(child class override the method)
 *
 *  @param animated 是否显示动画效果
 */
- (void)customViewDidDisappear:(BOOL)animated
{
    
}

/**
 *  获取实际对应的SchemeURL键值
 *
 *  @return 返回键值字典
 */
+ (NSDictionary *)propertyURLSchemeParamKeyMap
{
    return nil;
}

/**
 *  Scheme参数经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 *
 *  @param protocol    Scheme调用中对应URLMap的protocol
 *  @param params      Scheme参数
 *  @param actionBlock SchemeURL检测处理回调方法
 */
//- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol params:(NSDictionary *)params actionBlock:(URLParamMapPropertyCheckBlock)actionBlock
//{
//    NSString *method = [DataFormatterFunc strValueForKey:@"method" ofDict:params];
//    //特殊scheme处理
//    if ([method length]) {
//        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",method]);
//        if ([PASSchemeManager respondsToSelector:selector]) {
//            [self checkingServiceStaticMethodParamDict:params actionBlock:^{
//                IMP action = [PASSchemeManager methodForSelector:selector];
//                void (*func)(id,SEL,id) = (void *)action;
//                func([PASSchemeManager class],selector,params);
//            }];
//
//        }
//        return;
//    }
//
//    /**
//     *  998登录处理
//     */
//    NSInteger errcode = [[DataFormatterFunc numberValueForKey:@"errcode" ofDict:params] integerValue];
//    if (errcode == KResponseRestStatus998 || errcode == KResponseRestStatus997) {
//        [PASLoginManager showLoginWithH5:params webView:nil];
//        return;
//    }
//
//    //正常处理
//    NSInteger strongAcc = [[DataFormatterFunc numberValueForKey:@"strongAcc" ofDict:params] integerValue];
//    NSInteger rightStatus = [[DataFormatterFunc numberValueForKey:@"rightStatus" ofDict:params] integerValue];
//    NSString *notMatchScheme = [DataFormatterFunc strValueForKey:@"notMatchScheme" ofDict:params];
//
//    [PASLoginManager gotoPageWithNeedUserRights:strongAcc matchRightsBlock:^(UserRights currentRights) {
//
//        switch (rightStatus) {
//            case 1:
//            {
//                if (UserRights_Margin == currentRights) {
//                    if (actionBlock) {
////                        actionBlock();
//                        [self checkingServiceStaticUserInfoProtocol:protocol objcet:self actionBlock:actionBlock];
//                    }
//                } else if([notMatchScheme length]){
//                    [[PASNavigator sharedPASNavigator] openURLString:notMatchScheme];
//                } else {
//                    [PASSwitchPageManager switchUserCenterPage:nil];
//                }
//
//            }
//                break;
//            case 2:
//
//                if (UserRights_Margin != currentRights && currentRights >= strongAcc) {
//                    if (actionBlock) {
////                        actionBlock();
//                        [self checkingServiceStaticUserInfoProtocol:protocol objcet:self actionBlock:actionBlock];
//                    }
//                } else if([notMatchScheme length]){
//                    [[PASNavigator sharedPASNavigator] openURLString:notMatchScheme];
//                } else {
//
//                    [PASSwitchPageManager switchUserCenterPage:nil];
//                    [PASSwitchPageManager checkIsMarginLoginAll];
//                }
//
//                break;
//
//            default:
//            {
//                if (actionBlock) {
////                    actionBlock();
//                    [self checkingServiceStaticUserInfoProtocol:protocol objcet:self actionBlock:actionBlock];
//                }
//            }
//                break;
//        }
//
//    } notMatchRightsBlock:^(UserRights currentRights) {
//
//    } setProperty:nil];
//}

/**
 Scheme对象生成后经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 
 @param protocol Scheme调用中对应URLMap的protocol
 @param object object description
 @param actionBlock protocol 检测处理回调方法
 */
- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol object:(id)object actionBlock:(URLParamMapPropertyCheckBlock)actionBlock
{
    if (actionBlock) {
        [self checkingServiceStaticUserInfoProtocol:protocol objcet:object actionBlock:actionBlock];
    }
}

/**
 6.15.0version 业务功能点（protocol）  介入静态检查

 @param protocol  协议
 @param objcet 默认目标vc
 @param actionBlock 回调
 */
- (void)checkingServiceStaticUserInfoProtocol:(Protocol *)protocol
                                       objcet:(id)objcet
                                  actionBlock: (URLParamMapPropertyCheckBlock)actionBlock
{
//    [[PASStaticCheckingManager sharedPASStaticCheckingManager] staticCheckURLSchemeProtocol:protocol viewController:objcet resultBlock:^(BOOL bolPassed) {
//        URLParamMapPropertyCheckBlock completeBlock = [actionBlock copy];
//        if (completeBlock && bolPassed) {
//            completeBlock();
//        }
//    }];
}

/**
 6.15.0version 业务功能点（method跳转）  介入静态检查

 @param paramDict method跳转参数字典
 @param actionBlock  回调
 */
- (void)checkingServiceStaticMethodParamDict:(NSDictionary *)paramDict
                                 actionBlock: (URLParamMapPropertyCheckBlock)actionBlock
{
//    [[PASStaticCheckingManager sharedPASStaticCheckingManager] schemeMethodCheckingStaticService:paramDict actionBlock:^(BOOL bolPassed) {
//        URLParamMapPropertyCheckBlock completeBlock = [actionBlock copy];
//        if (completeBlock && bolPassed) {
//            completeBlock();
//        }
//    }];
}

-(void)viewDidLayoutSubviews{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11")){
        UINavigationItem * navigationItem=self.navigationItem;
        NSArray * itemsArray=navigationItem.leftBarButtonItems;
        if (itemsArray&&itemsArray.count!=0){
            UIBarButtonItem * buttonItem=itemsArray[0];
            UIView * customView =buttonItem.customView ;
            /**< 左侧item有view  所有不做判断 */
//            if([customView isKindOfClass:[UIButton class]])
//            {
                UIView * contentView =[[[customView superview] superview] superview];
                for (NSLayoutConstraint * constant in contentView.constraints) {
                   /**< 判断是 iphone Plus 并且不是 iphoneX 间距为20,否则为16 */
                    CGFloat tempSpace = (IS_IPHONE_6P && !IS_IPHONE_X)? 20 : 16;
                    if (fabs(constant.constant)==tempSpace) {
                        constant.constant=8;
                    }
                }
//            }
        }
    }
}

//埋点路径参数
- (void)setApp_mc_id:(NSString *)app_mc_id
{
    if (app_mc_id.length > 0) {
//        [PASVastMCIDManager sharedPASVastMCIDManager].app_mc_id = app_mc_id;
    }
}

#pragma mark- 猴子动画处理
//- (void)createMonkeyView
//{
//    PASSuspensionAdView *suspView = [PASSuspensionAdView createSuspensionAdViewWithFlagPage:self.monkeyType withDelegate:self];
//    if (suspView) {
//        self.suspensionAdV = suspView;
//        [self.view addSubview:suspView];
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSuspendViewDataFrom) name:KSuspendNotificationRefreshName object:nil];
//}

//- (void)setBolShowMonkeyAnimation:(BOOL)bolShowMonkeyAnimation
//{
//    _bolShowMonkeyAnimation = bolShowMonkeyAnimation;
//    if (_bolShowMonkeyAnimation) {
//        if (!self.suspensionAdV) {
////            [self createMonkeyView];
//        }
//
//    } else {
//        if (self.suspensionAdV) {
//            if ([self.suspensionAdV superview]) {
//                [self.suspensionAdV removeFromSuperview];
//                [[NSNotificationCenter defaultCenter] removeObserver:self name:KSuspendNotificationRefreshName object:nil];
//            }
//            self.suspensionAdV = nil;
//        }
//    }
//}

- (void)showAnimationLayoutView:(UIScrollView *)scrollView
{
//    if (self.suspensionAdV)
//    {
//        if (!scrollView.isDragging) {
//            [self.suspensionAdV showAnimationLayoutV];
//        } else {
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showAnimationLayoutView:) object:scrollView];
//            [self performSelector:@selector(showAnimationLayoutView:) withObject:scrollView afterDelay:0.5];
//        }
//
//    }
}
//
//- (void)refreshSuspendViewDataFrom
//{
//    [self.suspensionAdV reLoadRefreshLocalCacheData];
//}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showAnimationLayoutView:) object:scrollView];
    [self performSelector:@selector(showAnimationLayoutView:) withObject:scrollView afterDelay:0.5];
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//
//    if (self.suspensionAdV)
//    {
//        [self.suspensionAdV hideAnimationLayoutV];
//    }
//}

//- (void)dismissClearnSourceSuspensionAdView:(PASSuspensionAdView *)suspensionAdV
//{
//    self.bolShowMonkeyAnimation = NO;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
//    CMLogDebug(LogBusinessPublicService, @"%@", parent);
    if(!parent){
//        if(self == [PASWebViewManager sharedPASWebViewManager].prestrainWebViewController)
//        {
//            [[PASWebViewManager sharedPASWebViewManager] resetPrestrainWebViewController];
//        }
    }
}

@end
