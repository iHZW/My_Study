//
//  ModuleContainer.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonTemplate.h"
#import "HttpClient.h"
#import "RouterParam.h"
#import "RouterPageModel.h"
#import "Router.h"

/** 给 NSObject 添加路由参数  */
#import "NSObject+Params.h"
#import "Router+CRM.h"

#define ZWM   [ModuleContainer sharedModuleContainer]

//刷新tabbar
#define NOTIFICATION_TAB_REFRESH    @"NOTIFICATION_TAB_REFRESH"
//TabBar切换通知
#define TABBAR_SELECT_NOTICE        @"TABBAR_SELECT_NOTICE"

NS_ASSUME_NONNULL_BEGIN


@interface ModuleContainer : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(ModuleContainer)

@property (nonatomic, strong, readonly) HttpClient *http;

@property (nonatomic, strong,readonly) Router *router;


- (void)registerConfig;

/**
 *  根据路由查找 RouterParam
 *
 *  @param route    路由
 *
 */
- (RouterParam *)findRouterParam:(NSString *)route;

/**
 *  根据类名查找 RouterPageConfig
 *
 *  @param clsName    类名
 *
 */
- (RouterPageConfig *)findRouterPageConfig:(NSString *)clsName;

@end


NS_ASSUME_NONNULL_END
