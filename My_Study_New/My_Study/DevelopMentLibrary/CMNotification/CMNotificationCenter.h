//
//  CMNotificationCenter.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMNotificationCenter : NSObject
/**
 *  单例模式默认消息中心
 */
+ (id)defaultCenter;

/**
 *  添加观察者
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationSelector 执行方法
 *  @param notificationName     注册通知名称
 *  @param objectOfInterest     引用对象
 */
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)objectOfInterest;

/**
 *  移除观察者对象
 *
 *  @param notificationObserver 观察者对象
 */
- (void)removeObserver:(id)notificationObserver;

/**
 *  移除指定注册通知名称的观察者对象
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationName     注册通知名称
 */
- (void)removeObserver:(id)notificationObserver name:(NSString *)notificationName;

/**
 *  移除指定注册通知名称的观察者对象
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationName     注册通知名称
 *  @param objectOfInterest     引用对象
 */
- (void)removeObserver:(id)notificationObserver name:(NSString *)notificationName object:(id)objectOfInterest;

/**
 *  消息通知观察者
 *
 *  @param aNotification NSNotification类型参数
 */
- (void)postNotification:(NSNotification *)aNotification;

/**
 *  消息通知观察者
 *
 *  @param aName            注册通知名称
 *  @param objectOfInterest 引用对象
 *  @param userInfo         自定义参数
 */
- (void)postNotificationName:(NSString *)aName object:(id)objectOfInterest userInfo:(NSDictionary *)userInfo;

@end
