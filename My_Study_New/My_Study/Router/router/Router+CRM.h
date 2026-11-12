//
//  Router+CRM.h
//  CRM
//
//  Created by js on 2019/8/20.
//  Copyright © 2019 js. All rights reserved.
//

#import "Router.h"

NS_ASSUME_NONNULL_BEGIN
#define kExtraParamKey @"extra~xxxx"
@class UIViewController, UINavigationController, UITabBarController;

@interface Router (CRM)
/// 已完成业务配置的页面同样进入统一请求、拦截、日志与导航链路。
+ (void)pushViewController:(UIViewController *)controller navigationController:(nullable UINavigationController *)navigationController animated:(BOOL)animated;
+ (void)presentViewController:(UIViewController *)controller from:(UIViewController *)source animated:(BOOL)animated completion:(nullable void (^)(void))completion;
+ (void)selectTabAtIndex:(NSUInteger)index controller:(UITabBarController *)controller source:(NSString *)source;
+ (void)push:(NSString *)clsName
      params:(NSDictionary *)params
     context:(id)context;

+ (void)present:(NSString *)clsName
         params:(NSDictionary *)params
        context:(id)context;


+ (NSString *)encodeRouterUrl:(NSString *)url params:(NSDictionary *)params;
//{"path":"xxx", "data":xx}
+ (NSDictionary *)decodeRouterUrl:(NSString *)route;

//唤起app http://bable.weimob.com/pages/viewpage.action?pageId=16501573
//判断当前是否登录， 登录后才能跳转唤起app 目标页面
+ (BOOL)supportOpenApp;
+ (BOOL)canOpenApp:(NSString *)universalLink;
+ (void)openApp:(NSString *)universalLink;
@end

NS_ASSUME_NONNULL_END
