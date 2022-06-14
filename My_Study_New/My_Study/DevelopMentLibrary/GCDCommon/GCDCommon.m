//
//  GCDCommon.m
//  JCYProduct
//
//  Created by Howard on 15/10/21.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import "GCDCommon.h"

static NSString *defaultQueueLabel = @"DefaultAnotherQueue";

@implementation GCDCommon

/**
 *  主线程执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnMainQueue(BOOL waitUntilDone, void (^block)())
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
        performBlockOnCustomQueue(dispatch_get_main_queue(), NULL, waitUntilDone, block);
}

/**
 *  子线程执行操作(如果主线程调用，则dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)队列中调用)
 *
 *  @param ^block 执行操作
 */
void performActionBlockOnThread(void (^block)())
{
    static int specificKey;
    if ([NSThread isMainThread]) {
        performBlockOnCustomQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), &specificKey, NO, block);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), block);
    }
    else {
        block();
    }
}

/**
 *  异步在DefaultAnotherQueue中执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnAnotherQueue(BOOL waitUntilDone, void (^block)())
{
    static int specificKey;
    dispatch_queue_t queue = dispatch_queue_create([defaultQueueLabel UTF8String], NULL);
    CFStringRef specificValue = (__bridge CFStringRef)defaultQueueLabel;
    dispatch_queue_set_specific(queue, &specificKey, (void*)specificValue, NULL);
    
    performBlockOnCustomQueue(queue, &specificKey, waitUntilDone, block);
#if defined (OS_OBJECT_USE_OBJC_RETAIN_RELEASE) && OS_OBJECT_USE_OBJC_RETAIN_RELEASE==0
    dispatch_release(queue);
#endif
    
}

/**
 *  在自定义队列中执行操作
 *
 *  @param waitUntilDone=> YES:同步  NO:异步 ^block 执行操作
 */
void performBlockOnCustomQueue(dispatch_queue_t queue, const void *key, BOOL waitUntilDone, void (^block)())
{
    CFStringRef retrievedValue = dispatch_get_specific(key);//dispatch_queue_get_specific(queue, key);
    if (key != NULL && retrievedValue)
    {
        block();
    }
    else
    {
        if (waitUntilDone)
            dispatch_sync(queue, block);
        else
            dispatch_async(queue, block);
    }
}

/**
 *  在自定义队列中Barrier执行操作
 *
 *  @param queue         自定义队列
 *  @param key           The context for the specified key or NULL if no context was found
 *  @param allowNesting  是否允许dispatch_barrier 嵌套执行
 *  @param waitUntilDone YES:同步  NO:异步
 *  @param ^block        回调block
 */
void performBarrierBlockOnCustomQueue(dispatch_queue_t queue, const void *key, BOOL allowNesting, BOOL waitUntilDone, void (^block)())
{
    CFStringRef retrievedValue = dispatch_get_specific(key);//dispatch_queue_get_specific(queue, key);
    if (key != NULL && retrievedValue)
    {
        if (allowNesting)
            dispatch_barrier_async(queue, block);
        else
            block();
    }
    else
    {
        if (waitUntilDone) {
            if ([NSThread isMainThread] && !allowNesting)
                dispatch_barrier_async(queue, block);
            else
                dispatch_barrier_sync(queue, block);
        } else {
            dispatch_barrier_async(queue, block);
        }
    }
}

/**
 *  在自定义队列中Barrier执行操作
 *
 *  @param queue         自定义队列
 *  @param waitUntilDone YES:同步  NO:异步
 *  @param ^block        回调block
 */
void performBarrierBlock(dispatch_queue_t queue, BOOL waitUntilDone, void (^block)())
{
    performBarrierBlockOnCustomQueue(queue, NULL, YES, waitUntilDone, block);
}

/**
 *  延迟多少秒执行操作
 *
 *  @param queue 队列
 *  @param delay 延迟时间
 *  @param block 执行操作
 */
void performBlockDelay(dispatch_queue_t queue, NSTimeInterval delay, dispatch_block_t block)
{
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(when, queue, block);
}

@end
