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
 *  主线程执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnMainQueue(BOOL waitUntilDone, void (^block)(void));

/**
 *  子线程执行操作(如果主线程调用，则dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)队列中调用)
 *
 *  @param ^block 执行操作
 */
void performActionBlockOnThread(void (^block)(void));

/**
 *  异步在DefaultAnotherQueue中执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnAnotherQueue(BOOL waitUntilDone, void (^block)(void));

/**
 *  在自定义队列中执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnCustomQueue(dispatch_queue_t queue, const void *key, BOOL waitUntilDone, void (^block)(void));

/**
 *  在自定义队列中Barrier执行操作
 *
 *  @param queue         自定义队列
 *  @param key           The context for the specified key or NULL if no context was found
 *  @param allowNesting  是否允许dispatch_barrier 嵌套执行
 *  @param waitUntilDone YES:同步  NO:异步
 *  @param ^block        回调block
 */
void performBarrierBlockOnCustomQueue(dispatch_queue_t queue, const void *key, BOOL allowNesting, BOOL waitUntilDone, void (^block)(void));

/**
 *  在自定义队列中Barrier执行操作
 *
 *  @param queue         自定义队列
 *  @param waitUntilDone YES:同步  NO:异步
 *  @param ^block        回调block
 */
void performBarrierBlock(dispatch_queue_t queue, BOOL waitUntilDone, void (^block)(void));

/**
 *  延迟多少秒执行操作
 *
 *  @param queue 队列
 *  @param delay 延迟时间
 *  @param block 执行操作
 */
void performBlockDelay(dispatch_queue_t queue, NSTimeInterval delay, dispatch_block_t block);

@end
