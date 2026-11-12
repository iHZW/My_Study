//
//  Router+CRM.m
//  CRM
//
//  Created by js on 2019/8/20.
//  Copyright © 2019 js. All rights reserved.
//

#import "Router+CRM.h"
#import "NSObject+Params.h"

@implementation Router (CRM)

+ (RouterParam *)requestForController:(UIViewController *)controller source:(id)source type:(RouterType)type animated:(BOOL)animated {
    NSString *className = NSStringFromClass(controller.class);
    RouterPageItem *registered = [ZWM.router pageForClassName:className];
    NSString *path = registered.url ?: [@"native/" stringByAppendingString:className ?: @"unknown"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:registered.attachValue ?: @{}];
    [parameters addEntriesFromDictionary:controller.routerParams ?: @{}];
    RouterParam *request = [RouterParam makeWith:path destURL:className params:parameters type:type context:source];
    request.successBlock = controller.routerParamObject.successBlock;
    request.failBlock = controller.routerParamObject.failBlock;
    request.preparedDestination = controller;
    request.usesPreparedDestination = YES;
    request.navigationAnimated = @(animated);
    return request;
}

+ (void)pushViewController:(UIViewController *)controller navigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
    RouterParam *request = [self requestForController:controller source:navigationController type:RouterTypeNavigate animated:animated];
    if (!navigationController || !controller) {
        [ZWM.router recordEvent:@"跳转失败" request:request details:@{@"message": @"导航控制器或目标页面为空"}];
        return;
    }
    [ZWM.router executeRouterParam:request];
}

+ (void)presentViewController:(UIViewController *)controller from:(UIViewController *)source animated:(BOOL)animated completion:(void (^)(void))completion {
    RouterParam *request = [self requestForController:controller source:source type:RouterTypeNavigatePresent animated:animated];
    request.presentationCompletion = completion;
    if (!source || !controller) {
        [ZWM.router recordEvent:@"跳转失败" request:request details:@{@"message": @"展示上下文或目标页面为空"}];
        return;
    }
    [ZWM.router executeRouterParam:request];
}

+ (void)selectTabAtIndex:(NSUInteger)index controller:(UITabBarController *)controller source:(NSString *)source {
    if (index >= controller.viewControllers.count) return;
    UIViewController *target = controller.viewControllers[index];
    if ([target isKindOfClass:UINavigationController.class]) target = [(UINavigationController *)target viewControllers].firstObject;
    RouterParam *request = [self requestForController:target source:controller type:RouterTypeNavigateTab animated:NO];
    request.preparedDestination = nil;
    request.tabSelectionIndex = @(index);
    request.params = @{@"fromIndex": @(controller.selectedIndex), @"toIndex": @(index), @"source": source};
    [ZWM.router executeRouterParam:request];
}

+ (void)push:(NSString *)clsName
      params:(NSDictionary *)params
     context:(id)context{
    [self push:clsName params:params context:context success:nil fail:nil];
}

+ (void)push:(NSString *)clsName
      params:(NSDictionary *)params
     context:(id)context
     success:(nullable void (^)(id))successBlock
        fail:(nullable void (^)(NSError *))failBlock{
    RouterParam *routerParam = [RouterParam makeWith:@"" destURL:clsName params:params type:RouterTypeNavigate context:context];
    [ZWM.router execute:routerParam success:successBlock fail:failBlock];
}

+ (void)present:(NSString *)clsName
         params:(NSDictionary *)params
        context:(id)context{
    [self present:clsName params:params context:context success:nil fail:nil];
}

+ (void)present:(NSString *)clsName
      params:(NSDictionary *)params
        context:(id)context
     success:(nullable void (^)(id))successBlock
        fail:(nullable void (^)(NSError *))failBlock{
    RouterParam *routerParam = [RouterParam makeWith:@"" destURL:clsName params:params type:RouterTypeNavigatePresent context:context];
    [ZWM.router execute:routerParam success:successBlock fail:failBlock];
}

+ (NSString *)encodeRouterUrl:(NSString *)url params:(NSDictionary *)params {
    return [Router encodeRoute:url parameters:params];
}

+ (NSDictionary *)decodeRouterUrl:(NSString *)route {
    return [Router decodeRoute:route];
}
#warning -- 拼接 universalLink 处理的域名
+ (NSString *)appCustomDomain{
    /** 拼接域名  */
    return @"https://zw.home.cn";
//    NSString *url = [NSString stringWithFormat:@"https://%@",[Config sharedInstance].associatedDomain];
//    return url;
}

#warning -- 拼接  schema
+ (NSString *)appCustomSchema{
    /** 拼接schema  */
    return @"zwapp://zw.app/open";
//    NSString *url = [NSString stringWithFormat:@"%@://%@/open",[Config sharedInstance].crmScheme,[Config sharedInstance].crmHost];
//    return url;
}

+ (NSDictionary *)routePayloadForLink:(NSString *)link {
    NSURLComponents *components = [NSURLComponents componentsWithString:link];
    NSURLComponents *domain = [NSURLComponents componentsWithString:[self appCustomDomain]];
    NSURLComponents *schema = [NSURLComponents componentsWithString:[self appCustomSchema]];
    BOOL isWeb = [components.scheme.lowercaseString isEqualToString:domain.scheme.lowercaseString]
        && [components.host.lowercaseString isEqualToString:domain.host.lowercaseString]
        && [components.port isEqual:domain.port];
    if (!components.port && !domain.port) {
        isWeb = [components.scheme.lowercaseString isEqualToString:domain.scheme.lowercaseString]
            && [components.host.lowercaseString isEqualToString:domain.host.lowercaseString];
    }
    BOOL isApp = [components.scheme.lowercaseString isEqualToString:schema.scheme.lowercaseString]
        && [components.host.lowercaseString isEqualToString:schema.host.lowercaseString]
        && [components.path isEqualToString:schema.path] && !components.port;
    if ((!isWeb && !isApp) || components.user.length || components.password.length) return nil;
    NSString *value = nil;
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"param"]) {
            if (value) return nil;
            value = item.value;
        }
    }
    if (!value.length) return nil;
    if (isWeb) {
        NSURLComponents *nested = [NSURLComponents componentsWithString:value];
        if (![nested.scheme.lowercaseString isEqualToString:schema.scheme.lowercaseString]) return nil;
        return [self routePayloadForLink:value];
    }
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    id payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![payload isKindOfClass:NSDictionary.class] || ![payload[@"route"] isKindOfClass:NSString.class]) return nil;
    if (payload[@"param"] && ![payload[@"param"] isKindOfClass:NSDictionary.class]) return nil;
    // 外部入口只允许已注册页面，不允许任意类实例化及行为调用。
    RouterPageItem *page = [ZWM.router pageForPath:payload[@"route"]];
    if (!page || page.type == RouterTypeAction) return nil;
    return payload;
}

+ (void)openApp:(NSString *)link {
    NSDictionary *payload = [self routePayloadForLink:link];
    if (payload && [self supportOpenApp]) {
        [ZWM.router openPath:payload[@"route"] parameters:payload[@"param"] context:nil success:nil failure:nil];
    }
}

+ (BOOL)supportOpenApp { return YES; }
+ (BOOL)canOpenApp:(NSString *)link { return [self routePayloadForLink:link] != nil; }
@end
