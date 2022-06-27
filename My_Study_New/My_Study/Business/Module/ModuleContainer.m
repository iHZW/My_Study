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


@interface ModuleContainer ()

@property (nonatomic, strong, readwrite) HttpClient *http;

@property (nonatomic, strong) NSMutableArray<RouterPageConfig *> *registerRouterConfigs;

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
+ (RouterPageConfig *)findRouterPageConfig:(NSArray *)routerConfigs url:(NSString *)url{
    RouterPageConfig *pageConfig = nil;
    if (routerConfigs && routerConfigs.count > 0) {
        for (RouterPageConfig *config in routerConfigs){
            if ([config.url isEqualToString:url]){
                pageConfig = config;
            }
        }
    }
    return pageConfig;
}

/**
 *  根据路由查找 RouterParam
 *
 *  @param route    路由
 *
 */
- (RouterParam *)findRouterParam:(NSString *)route
{
    return [ModuleContainer getRouterParam:route routerConfigs:self.registerRouterConfigs];
}


+ (RouterParam *)getRouterParam:(NSString *)url routerConfigs:(NSArray *)routerConfigs{
    
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
        routerParam.destURL = @"HybridWebViewController";
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
    } else{
        url = [url stringByRemovingPercentEncoding];
        NSArray *components = [url componentsSeparatedByString:@"?"];
        NSString *path = components.firstObject;
        if (path.length > 0){
            RouterParam *routerParam = [[RouterParam alloc] init];
            routerParam.originUrl = url;
            RouterPageConfig *routerConfig = [self findRouterPageConfig:routerConfigs url:path];
            routerParam.destURL = routerConfig.clsName;
            routerParam.type = routerConfig.type;
            
            NSString *dataStr = [url substringFromIndex:path.length];
            if ([dataStr hasPrefix:@"?"]){
                dataStr = [dataStr substringFromIndex:1];
            }
            if (dataStr.length > 0){
                if ([dataStr hasPrefix:@"param="]){
                    NSString *parmasString = [dataStr substringFromIndex:6];
                    //URL解码
                    parmasString = [parmasString stringByRemovingPercentEncoding];
                    
                    id data = [JSONUtil jsonObject:parmasString];
                    if (data){
                        routerParam.params = data;
                    }
                }
            }
            
            if (routerConfig.attachValue){
                NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:routerConfig.attachValue];
                [mutDict addEntriesFromDictionary:routerParam.params];
                routerParam.params = mutDict;
            }
            
            return routerParam;
        }
    }
    return nil;
}

/**
 *  根据类名查找 RouterPageConfig
 *
 *  @param clsName    类名
 *
 */
- (RouterPageConfig *)findRouterPageConfig:(NSString *)clsName
{
    NSArray *registerRouterConfigs = self.registerRouterConfigs;
    for (RouterPageConfig *pageConfig in registerRouterConfigs){
        if ([pageConfig.clsName isEqualToString:clsName]){
            return pageConfig;
        }
    }
    return nil;
}

/**
 *  注册路由
 */
- (void)registerRouter
{
    self.registerRouterConfigs = [NSMutableArray array];
    RouterPageModel *pageModel = [RouterPageModel getDefaultRouterPageModel];
    
    [pageModel.configs enumerateObjectsUsingBlock:^(RouterPageConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        RouterPageConfig *config = [RouterPageConfig makeWithUrl:TransToString(obj.url) clsName:TransToString(obj.clsName) type:obj.type attachValue:TransToDictionary(obj.attachValue)];
        [self.registerRouterConfigs addObject:config];
    }];
    
}


@end
