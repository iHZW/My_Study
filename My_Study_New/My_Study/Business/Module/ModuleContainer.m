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


@interface ModuleContainer ()<RouterNavigateDelegate>

@property (nonatomic, strong, readwrite) HttpClient *http;

@property (nonatomic, strong,readwrite) Router *router;

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
    
    self.router = [[Router alloc] init];
    self.router.navigateObject = self;
    @pas_weakify_self
    self.router.routerParseBlock = ^RouterParam * _Nullable(NSString * _Nonnull routerURL) {
        @pas_strongify_self
        return [self findRouterParam:routerURL];
    };
    self.router.routerConfigs = self.registerRouterConfigs;
    
    /** 配置拦截器  */
    [self configRouterIntercept];
    
}


- (void)configRouterIntercept
{
    
}

#pragma mark - RouterNavigateDelegate
- (void)doAction:(RouterParam *)param {
    NSObject *cls = [self commonActionRouter:param];
    if ([cls isKindOfClass:BaseRouterAction.class]) {
        [(BaseRouterAction *)cls doAction];
    }
}

- (void)navigateTo:(RouterParam *)param { 
    UIViewController *cls = [self commonRouter:param];
    if ([cls isKindOfClass:UIViewController.class]) {
        
        NSDictionary *extraParam = [param.params objectForKey:kExtraParamKey];
        
        BOOL animated = YES;
        BOOL modifyedAni = NO;
        BOOL hideNavigationBar = NO;
        
        if (extraParam){
            if ([extraParam.allKeys containsObject:@"anim"]){
                animated = [[extraParam objectForKey:@"anim"] boolValue];
                modifyedAni = YES;
            }
        }
        
        if ([[cls class] respondsToSelector:@selector(ss_constantParams)]){
            NSDictionary *dict = [[cls class] ss_constantParams];
            if (!modifyedAni){
                animated = [[dict objectForKey:@"animated"] boolValue];
            }
            
            hideNavigationBar = [[dict objectForKey:@"hideNavigationBar"] boolValue];
        }

        UIViewController *currentViewController = [self currentViewController:param];
        cls.disableAnimatePush = !animated;
        cls.hideNavigationBar = hideNavigationBar;
        if ([currentViewController isKindOfClass:[UINavigationController class]]){
            [(UINavigationController *)currentViewController pushViewController:cls animated:animated];
        } else {
            [currentViewController.navigationController pushViewController:cls animated:animated];
        }
    }
}

- (void)presentTo:(RouterParam *)param { 
    NSObject *cls = [self commonRouter:param];
    if ([cls isKindOfClass:[UIViewController class]]) {
        
        
    }

}

/**
 *  通知切换tabbar
 *
 *  @param param    路由参数
 */
- (void)tabTo:(RouterParam *)param { 
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_SELECT_NOTICE object:param];
}


/**
 *  获取路由跳转页面
 *
 *  @param param    路由参数RouterParam
 *  @return  路由跳转界面
 */
- (id)commonRouter:(RouterParam *)param{
    NSString *clsName = param.destURL;
    if (clsName.length == 0){
        [LogUtil debug:@"路由类名为空" flag:nil context:self];
        return nil;
    }
    
    Class cls = NSClassFromString(clsName);
    if (cls == nil){
        [LogUtil debug:@"路由类名对应类不存在" flag:nil context:self];
        return nil;
    }
    
    NSObject *instance = [[cls alloc] init];
    if (![instance isKindOfClass:UIViewController.class]){
        [LogUtil debug:@"路由类不是页面" flag:nil context:self];
        return nil;
    }
    instance.routerParams = param.params;
    instance.routerParamObject = param;
    return instance;;
}


/**
 *  获取行为路由
 *
 *  @param param    路由参数
 *  @return 行为路由
 */
- (id)commonActionRouter:(RouterParam *)param{
    NSString *clsName = param.destURL;
    if (clsName.length == 0){
        [LogUtil debug:@"路由类名为空" flag:nil context:self];
        return nil;
    }
    
    Class cls = NSClassFromString(clsName);
    if (cls == nil){
        [LogUtil debug:@"路由类名对应类不存在" flag:nil context:self];
        return nil;
    }
    
    NSObject *instance = [[cls alloc] init];
    if (![instance isKindOfClass:BaseRouterAction.class]){
        [LogUtil debug:@"行为路由不支持" flag:nil context:self];
        return nil;
    }
    instance.routerParams = param.params;
    instance.routerParamObject = param;
    return instance;
}

/**
 *  获取当前控制器
 *
 *  @param param    路由参数
 *  @return  当前控制器
 *
 */
- (UIViewController *)currentViewController:(RouterParam *)param{
    UIViewController *currentViewController = nil;
    if (param.context && [param.context isKindOfClass:[UIViewController class]]){
        currentViewController = param.context;
    } else {
        currentViewController = [UIApplication displayViewController];
    }
    return currentViewController;
}

@end
