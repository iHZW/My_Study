//
//  CMBusMediaAppDelegate.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonTemplate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMBusMediaAppDelegate : NSObject

DEFINE_SINGLETON_T_FOR_HEADER(CMBusMediaAppDelegate);

/**
 服务组件调用方法
 
 @param selector 方法名
 @param params 相关参数
 */
+ (void)serviceManager:(SEL)selector withParameters:(NSArray *)params;

/**
 指定服务组件执行指定方法
 
 @param service 指定的组件服务实例
 @param selector 方法名
 @param params 相关参数
 */
+ (void)performAction:(NSObject *)service selector:(SEL)selector withParameters:(NSArray *)params;

/**
 注册UIApplicationDelegate服务组件
 
 @param service 实现UIApplicationDelegate协议的服务组件
 */
+ (void)regisertService:(id<UIApplicationDelegate>)service;


/**
 获取当前注册组件列表信息
 */
+ (NSArray<id<UIApplicationDelegate>> *)services;

/**
 通过类名获取当前实例对象
 
 @param className 类名
 @return 返回对应实例对象
 */
+ (id<UIApplicationDelegate>)service:(Class)className;

@end

NS_ASSUME_NONNULL_END
