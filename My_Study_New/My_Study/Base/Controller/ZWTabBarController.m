//
//  ZWTabBarController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWTabBarController.h"

#import "UITabBar+Ext.h"
#import "UIImage+Addition.h"
#import "UIColor+Ext.h"
#import "NSArray+Func.h"
#import "UIImage+Resize.h"
#import "NSObject+Params.h"

#import "CustomTabbarObject.h"
#import "TabbarConfig.h"
#import "TabIndexManager.h"
#import "ZWCommonWebPage.h"
#import "ZWNavigationController.h"

#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

#pragma mark - MainTabSinglelogin
@implementation MainTabSinglelogin

+ (instancetype)shared
{
    static MainTabSinglelogin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MainTabSinglelogin alloc] init];
    });
    return instance;
}

- (NSMutableDictionary *)routePageEntityCache
{
    if (!_routePageEntityCache) {
        _routePageEntityCache = [NSMutableDictionary dictionary];
    }
    return _routePageEntityCache;
}

@end



#pragma mark - ZWTabBarController
@interface ZWTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic ,strong) NSArray <CustomTabbarObject *>* items;

//@property (nonatomic, strong) MessageFirstLevelViewModel *messageFirstLevelViewModel;

// 修改Tabbar 中 联系tab 之前所处的位置
@property (nonatomic, assign) NSInteger previousIMTabIndex;
// IM Tabbar 红点是否显示
@property (nonatomic, assign) BOOL showIMBage;
//修改Tabbar 中 消息tab 之前所处的位置
@property (nonatomic, assign) NSInteger previousMessageTabIndex;

/** 通知H5界面刷新  */
//@property (nonatomic, strong) ClientHybridNotification *clientNoti;

@end

@implementation ZWTabBarController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /** 通知刷新tabbar  */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabRefresh:) name:NOTIFICATION_TAB_REFRESH object:nil];
    
    /** 通知切换tabbar  */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarSeletDidChange:) name:TABBAR_SELECT_NOTICE object:nil];

    
    [self loadTabBar];
}


- (void)loadTabBar
{
    if(@available(iOS 13.0, *)) {
        UITabBarAppearance* tabbarAppearance = [self.tabBar.standardAppearance copy];
        tabbarAppearance.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 49) andRoundSize:0];
        
        tabbarAppearance.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
         // 官方文档写的是 重置背景和阴影为透明
        //[tabbarAppearance configureWithTransparentBackground];

        UITabBarItemStateAppearance * normal = tabbarAppearance.stackedLayoutAppearance.normal;
        UITabBarItemStateAppearance * selected = tabbarAppearance.stackedLayoutAppearance.selected;
        normal.titleTextAttributes = @{NSFontAttributeName:PASFont(10),NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"#D5D5E1"]};
        selected.titleTextAttributes = @{NSFontAttributeName:PASFont(10),NSForegroundColorAttributeName:[UIColor colorFromHexCode:@"#4F7AFD"]};
        self.tabBar.standardAppearance = tabbarAppearance;
        
    } else {
        self.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 49) andRoundSize:0];
        self.tabBar.shadowImage = [UIImage new];
    }
    
}

/** 通知刷新tabbar  */
- (void)tabRefresh:(NSNotification *)noti{
    [self build];
}

#pragma mark ---- 通知切换tab方法
- (void)tabBarSeletDidChange:(NSNotification *)notification{
    if (self.viewControllers.count == 0){
        return;
    }
    
    UINavigationController *nav = self.selectedViewController;
    if ([nav isKindOfClass:[UINavigationController class]]){
        [nav popToRootViewControllerAnimated:NO];
    }
    
    RouterParam *routerParam = notification.object;
    NSString *route = routerParam.originUrl;
    __block NSInteger index = -1;
    [self.items enumerateObjectsUsingBlock:^(CustomTabbarObject *  _Nonnull itemConfig, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([route hasPrefix:itemConfig.route]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index < 0 || index > self.items.count) {
        // 特殊处理  坐席改变的时候刷新找客户页面
        if (self.selectedIndex == 0) {
            if ([routerParam.params objectForKey:@"reload"] && [[routerParam.params objectForKey:@"reload"] integerValue] == 1) {
                if ([[self.items objectAtIndex:0].route isEqualToString:@"/h5/treasure/app-home"]) {
                    UINavigationController *nav = [self.viewControllers objectAtIndex:0];
                    if (nav && nav.viewControllers.count >= 1) {
                        UIViewController * vc = [nav.viewControllers objectAtIndex:0];
                        if (vc) {
                            [vc viewDidAppear:NO];
                        }
                    }
                }
            }
        }else{
            [self setSelectedIndex:0];
        }
        //
        return;
    }
    [self setSelectedIndex:index];
}

#pragma mark - 初始化tabbar
- (void)build
{
    self.items = [TabbarConfig loadTabListConfig].displayList;
    
    /** 这里可以请求网络tabbar配置信息  */
    if (!ZWCurrentUserInfo.isVisitor) {
//        [WM.http post:API_CLIENT_TOOLS requestModel:[BaseRequest defaultRequest] complete:^(ResultObject * result) {
//        }];
    }

    /** 创建控制器  */
    [self initialViewControllers];
    
    [self.tabBar hideBadgeOnItemIndex:1];
}


- (void)initialViewControllers
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    NSMutableDictionary<NSString *,PageIndexObject*> *pageIndexMap = [NSMutableDictionary dictionaryWithDictionary:TabIndexManager.shared.pageIndexMap];
    [self.items enumerateObjectsUsingBlock:^(CustomTabbarObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIViewController *vc = [MainTabSinglelogin.shared.routePageEntityCache objectForKey:obj.route];
        if (vc){
            //已经存在， 使用老的
            if ([vc isKindOfClass:ZWCommonWebPage.class]){
//                NSString *key = [(ZWCommonWebPage *)vc apiGroup];
//                PageIndexObject *pageIndexObject = [pageIndexMap objectForKey:key];
//                pageIndexObject.index = idx;
            }
            
        } else {
            RouterParam *routerParam = [[ModuleContainer sharedModuleContainer] findRouterParam:obj.route];
            
            Class class = NSClassFromString(routerParam.destURL);
            if (class){
                vc = [[class alloc] init];
                vc.routerParams = routerParam.params;
                vc.routerParamObject = routerParam;
                vc.isRootPage = YES;
                BOOL hideNavigationBar = NO;
                if ([class respondsToSelector:@selector(ss_constantParams)]){
                    NSDictionary *dict = [class ss_constantParams];
                    hideNavigationBar = [[dict objectForKey:@"hideNavigationBar"] boolValue];
                }
                vc.hideNavigationBar = hideNavigationBar;
                
        
                [MainTabSinglelogin.shared.routePageEntityCache setObject:vc forKey:obj.route];
                if ([vc isKindOfClass:ZWCommonWebPage.class]){
//                    NSString *key = [(ZWCommonWebPage *)vc apiGroup];
//                    PageIndexObject *pageIndexObject = [PageIndexObject initWith:idx showTab:YES];
//                    [pageIndexMap setObject:pageIndexObject forKey:key];
                }
            }
        }
        
        if (vc){
            ZWNavigationController * nav = [[ZWNavigationController alloc] initWithRootViewController:vc];
            if ([obj.iconUrl hasPrefix:@"http"]) {
                UIImage * image = [self getCacheImage:obj.iconUrl];
                if (image) {
                    nav.tabBarItem.image = [self originalImage:image];
                }else{
                    nav.tabBarItem.image = [[UIImage imageNamed:@"Tab_Text"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    [self downloadTabBarItemImage:obj.iconUrl index:idx isSelect:NO];
                }
            }else{
                nav.tabBarItem.image =  [[UIImage imageNamed:obj.iconUrl] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            
            if ([obj.selectedIconUrl hasPrefix:@"http"]) {
                UIImage * image = [self getCacheImage:obj.selectedIconUrl];
                if (image) {
                    nav.tabBarItem.selectedImage = [self originalImage:image];
                }else{
                    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"Tab_Test"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    [self downloadTabBarItemImage:obj.selectedIconUrl index:idx isSelect:YES];
                }
            }else{
                nav.tabBarItem.selectedImage = [[UIImage imageNamed:obj.selectedIconUrl] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            
            nav.tabBarItem.title = obj.title;
            
            [nav.tabBarItem setTitleTextAttributes:[self customNormalTabTitle] forState:UIControlStateNormal];
            [nav.tabBarItem setTitleTextAttributes:[self customSelectTabTitle] forState:UIControlStateSelected];
            
            [viewControllers addObject:nav];
        }
    }];
    
    //删除不存在与显示tab 中的页面缓存
    NSMutableDictionary *tempRoutePageEntityMap = [MainTabSinglelogin.shared.routePageEntityCache mutableCopy];
    NSArray *displayRoutes = [self.items flatMap:^id _Nonnull(CustomTabbarObject *item) {
        return item.route;
    }];
    for (NSString *route in MainTabSinglelogin.shared.routePageEntityCache){
        if (![displayRoutes containsObject:route]){
            [tempRoutePageEntityMap removeObjectForKey:route];
        }
    }
    MainTabSinglelogin.shared.routePageEntityCache = tempRoutePageEntityMap;
    
    
    self.viewControllers = viewControllers;
    
    /** 登录成功后需要 定位的 tab  */
//    CheckLoginCompleteResult *checkLoginCompleteResult = CheckLoginHelper.sharedInstace.loginCompleteResult;
//    NSString *restoreTabRoute = checkLoginCompleteResult.restoreTabRoute;
//    [self restoreSelectedTab:restoreTabRoute];
    
    //还原游客模式中的二级页面
//    NSArray *restoreViewControllers = checkLoginCompleteResult.restoreViewControllers;
//    if (restoreViewControllers.count > 0){
//        //TODO:还原登录前的nav
//        UINavigationController *navVC = self.selectedViewController;//viewControllers.firstObject;
//        NSMutableArray *viewControllers = [NSMutableArray arrayWithObject:navVC.viewControllers.firstObject];
//        [viewControllers addObjectsFromArray:restoreViewControllers];
//        navVC.viewControllers = viewControllers;
//
//        UIViewController *topVC = viewControllers.lastObject;
//        if (topVC.hideNavigationBar){
//            [navVC setNavigationBarHidden:YES];
//        }
//    }
    
    [TabIndexManager.shared updatePageIndexMap:pageIndexMap];
}



#pragma mark ---- other

- (UIImage *)getCacheImage:(NSString *)url{
    NSString *imageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
}

- (UIImage *)originalImage:(UIImage *)image{
    return [[UIImage tabbarSizeImage:CGSizeMake(22, 22) image:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


/** 恢复选中tab  */
- (void)restoreSelectedTab:(NSString *)restoreTabRoute{
    if (restoreTabRoute.length > 0){
        NSArray *routes = [self.items flatMap:^id _Nonnull(CustomTabbarObject *item) {
            return item.route;
        }];
        NSInteger index = [routes indexOfObject:restoreTabRoute];
        if (index >= 0 && index < self.viewControllers.count){
            self.selectedIndex = index;
        }
    }
}

- (NSDictionary *)customNormalTabTitle{
    return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHexCode:@"#4C4B5E"],NSForegroundColorAttributeName,PASFont(10),NSFontAttributeName,nil];
}

- (NSDictionary *)customSelectTabTitle{
    return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHexCode:@"#4F7AFD"],NSForegroundColorAttributeName,PASFont(10),NSFontAttributeName,nil];
}

- (void)downloadTabBarItemImage:(NSString *)url
           index:(NSInteger)index
        isSelect:(BOOL)isSelect{
    @pas_weakify_self
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        @pas_strongify_self
        [[SDImageCache sharedImageCache] storeImageDataToDisk:UIImagePNGRepresentation(image) forKey:url];
        [self updateTabBarItem:image index:index isSelect:isSelect];
    }];
}


- (void)updateTabBarItem:(UIImage *)image
             index:(NSInteger)index
          isSelect:(BOOL)isSelect{
    ZWNavigationController * nav =  [self.viewControllers objectAtIndex:index];
    if (!isSelect) {
        nav.tabBarItem.image = [self originalImage:image];
    }else{
        nav.tabBarItem.selectedImage = [self originalImage:image];
    }
}


- (BOOL)shouldAutorotate{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

@end
