//
//  ModuleContainer.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ModuleContainer.h"
#import "DataBaseManager.h"
#import "PathConstants.h"
#import "ConsoleAppender.h"
#import "DatabaseAppender.h"

#import "TabbarConfig.h"
#import "CustomTabbarObject.h"
#import "BaseRouterAction.h"

#import "NSObject+Params.h"
#import "UIApplication+Ext.h"
#import "UIViewController+ZW.h"
#import "PermissionIntercept.h"
#import "Permission.h"
#import "LocationManager.h"
#import "Config.h"
#import "RouterCoordinator.h"
#import "ZWDokitLog.h"


@interface ModuleContainer ()

@property (nonatomic, strong, readwrite) HttpClient *http;

@property (nonatomic, strong,readwrite) Router *router;
/** 存储页面信息  */
@property (nonatomic, strong) NSMutableArray<RouterPageItem *> *registerRouterItems;

@end


@implementation ModuleContainer
DEFINE_SINGLETON_T_FOR_CLASS(ModuleContainer)


- (void)registerConfig
{
    //数据库
    [self registerDB];
    
    //日志配置
    [self registerLog];
    
    //APP路由
    [self registerRouter];
    
    [self configPermissionIntercept];
        
    //设置地图Key
    [[LocationManager shareLocationManager] configAMapService:[Config sharedConfig].aMapKey];

}

- (void)configPermissionIntercept{
    PermissionIntercept *intercept = [[PermissionIntercept alloc] init];
    [Permission setIntercept:intercept];
}

#pragma mark - DB
- (void)registerDB
{
    [DataBaseManager registerRootDirectory:[PathConstants appDataDirectory]];
}

#pragma mark - Log
- (void)registerLog{

    NSArray *logAppenders = @[[ConsoleAppender new],[DatabaseAppender new]];
    [LogUtil setLogAppenders:logAppenders];

    //开发的时候，不想打印某一个模块的日志，可以在这里添加忽略
    [LogUtil configIgnoreFlagsLog:@[@"Socket"]];
}

#pragma mark - lazyLoad
- (HttpClient *)http
{
    if (!_http) {
        _http = [HttpClient defaultClient];
    }
    return _http;
}

#pragma mark - Router
- (RouterParam *)findRouterParam:(NSString *)route {
    return [self.router resolveURL:route] ?: [self webRouterParam:route];
}

- (RouterParam *)webRouterParam:(NSString *)url {
    if ([url hasPrefix:@"/h5/"]){
        NSArray *components = [url componentsSeparatedByString:@"?"];
        NSString *path = components.firstObject;
        NSString *pageURLPath = [path substringFromIndex:4];
        NSString *pageName = [pageURLPath componentsSeparatedByString:@"/"].firstObject;
        NSString *dataStr = components.lastObject;
        NSString *pageURL = dataStr;
        if ([dataStr hasPrefix:@"param="]){
            dataStr = [dataStr substringFromIndex:6];
            pageURL = [NSString stringWithFormat:@"%@/%@",pageURLPath,dataStr];
        } else {
            pageURL = [url substringFromIndex:3];
        }
        
        NSDictionary *params = @{
                                 @"pageName":pageName,
                                 @"pageURL":pageURL,
                                 @"type":@"h5"
                                 };
        RouterParam *routerParam = [[RouterParam alloc] init];
        routerParam.originUrl = url;
        routerParam.destURL = @"ZWCommonWebPage";
        routerParam.params = params;
        
        //因为无法将h5 的url 注册为tab 路由，
        //因此通过在tabConfig找查找是否有匹配的url， 有就是tab， 否则就是普通网页的navigate
        //如果tab页面还没生成，跳到第一个tab就好
        //hiddenList 中的路由也是tab 页面
        BOOL isTabPage = NO;
        TabbarConfig *tabbarConfig = [TabbarConfig loadTabListConfig];
        NSMutableArray *tabList = [NSMutableArray arrayWithArray:tabbarConfig.displayList];
        [tabList addObjectsFromArray:tabbarConfig.hiddenList];
        for (CustomTabbarObject * tabObject in tabList){
            if ([tabObject.route isEqualToString:url]){
                isTabPage = YES;
                break;
            }
        }
        routerParam.type = isTabPage ? RouterTypeNavigateTab : RouterTypeNavigate;
        return routerParam;
    }
    return nil;
}

/**
 *  根据类名查找 RouterPageItem
 *
 *  @param clsName    类名
 *
 */
- (RouterPageItem *)findRouterPageItem:(NSString *)clsName
{
    return [self.router pageForClassName:clsName];
}

/**
 *  注册路由
 */
- (void)registerRouter
{
    if (self.router) return;
    self.registerRouterItems = [NSMutableArray array];
    RouterPageConfig *pageConfig = [RouterPageConfig getDefaultRouterPageConfig];
    
    [pageConfig.pageItems enumerateObjectsUsingBlock:^(RouterPageItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        RouterPageItem *config = [RouterPageItem makeWithUrl:TransToString(obj.url) clsName:TransToString(obj.clsName) type:obj.type attachValue:TransToDictionary(obj.attachValue)];
        [self.registerRouterItems addObject:config];
    }];
    
    self.router = [[Router alloc] init];
    self.router.eventLogger = ^(NSString *event, NSDictionary *fields) {
        [ZWDokitLog event:event category:@"Router" fields:fields];
    };
    self.router.navigateObject = [RouterCoordinator new];
    @pas_weakify_self
    self.router.routerParseBlock = ^RouterParam * _Nullable(NSString * _Nonnull routerURL) {
        @pas_strongify_self
        return [self webRouterParam:routerURL];
    };
    NSError *registrationError = nil;
    if (![self.router registerPages:self.registerRouterItems error:&registrationError]) {
        [NSException raise:NSInternalInconsistencyException format:@"%@", registrationError.localizedDescription];
    }
    
    /** 配置拦截器  */
    [self configRouterIntercept];
    
}


- (void)configRouterIntercept
{
    
}


@end
