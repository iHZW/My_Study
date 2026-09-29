//
//  GCDCommon.h
//  JCYProduct
//
//  Created by Howard on 15/10/21.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface GCDCommon : NSObject

/**
 主线程执行操作

 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnMainQueue(BOOL waitUntilDone, void (^block)(void));

/**
 子线程执行操作(如果主线程调用，则dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)队列中调用)

 @param block 执行操作
 */
void performActionBlockOnThread(void (^block)(void));

/**
 异步在DefaultAnotherQueue中执行操作

 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnAnotherQueue(BOOL waitUntilDone, void (^block)(void));

/**
 在自定义队列中执行操作

 @param queue dispatch_queue
 @param key The context for the specified key or NULL if no context was found
 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnCustomQueue(dispatch_queue_t queue, const void * _Nullable key, BOOL waitUntilDone, void (^block)(void));

/**
 在自定义队列中Barrier执行操作

 @param queue 自定义队列
 @param key The context for the specified key or NULL if no context was found
 @param allowNesting 是否允许dispatch_barrier 嵌套执行
 @param waitUntilDone YES:同步  NO:异步
 @param block 回调block
 */
void performBarrierBlockOnCustomQueue(dispatch_queue_t queue, const void * _Nullable key, BOOL allowNesting, BOOL waitUntilDone, void (^block)(void));

/**
 在自定义队列中Barrier执行操作

 @param queue 自定义队列
 @param waitUntilDone YES:同步  NO:异步
 @param block 回调block
 */
void performBarrierBlock(dispatch_queue_t queue, BOOL waitUntilDone, void (^block)(void));

/**
 延迟多少秒执行操作

 @param queue 队列
 @param delay 延迟时间
 @param block 执行操作
 */
void performBlockDelay(dispatch_queue_t queue, NSTimeInterval delay, dispatch_block_t block);

/**
 多参数实例对象performSelecor 实现

 @param instance 实例对象
 @param aSelector aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @return 对应函数返回值
 */
id PerformInstanceMethodWithParams(id instance, SEL aSelector, NSArray *parameters);

/**
 多参数类方法performSelecor 实现

 @param aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @return 对应函数返回值
 */
id PerformClassMethodWithParams(Class class, SEL aSelector, NSArray *parameters);

/**
 多参数performSelecor 实现(带通用返回值)

 @param instance 实例对象
 @param aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @param returnVal 返回值
 */
void PerformInstanceMethodWithReturnValue(id instance, SEL aSelector, NSArray * _Nullable parameters, void *returnVal);

@end
