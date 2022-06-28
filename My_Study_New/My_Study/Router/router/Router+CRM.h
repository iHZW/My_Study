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
@interface Router (CRM)
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
