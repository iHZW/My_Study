//
//  GCDCommon.m
//  JCYProduct
//
//  Created by Howard on 15/10/21.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import "GCDCommon.h"
#import <objc/runtime.h>

static NSString *defaultQueueLabel                = @"DefaultAnotherQueue";
static const void *const kDefaultQueueSpecificKey = &kDefaultQueueSpecificKey;

@implementation GCDCommon

/**
 主线程执行操作

 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnMainQueue(BOOL waitUntilDone, void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else
        performBlockOnCustomQueue(dispatch_get_main_queue(), NULL, waitUntilDone, block);
}

/**
 子线程执行操作(如果主线程调用，则dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)队列中调用)

 @param block 执行操作
 */
void performActionBlockOnThread(void (^block)(void)) {
    static int specificKey;
    if ([NSThread isMainThread]) {
        performBlockOnCustomQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), &specificKey, NO, block);
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), block);
    } else {
        block();
    }
}

/**
 异步在DefaultAnotherQueue中执行操作

 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnAnotherQueue(BOOL waitUntilDone, void (^block)(void)) {
    dispatch_queue_t queue    = dispatch_queue_create([defaultQueueLabel UTF8String], NULL);
    CFStringRef specificValue = (__bridge CFStringRef)defaultQueueLabel;
    dispatch_queue_set_specific(queue, kDefaultQueueSpecificKey, (void *)specificValue, NULL);

    performBlockOnCustomQueue(queue, kDefaultQueueSpecificKey, waitUntilDone, block);
#if defined(OS_OBJECT_USE_OBJC_RETAIN_RELEASE) && OS_OBJECT_USE_OBJC_RETAIN_RELEASE == 0
    dispatch_release(queue);
#endif
}

/**
 在自定义队列中执行操作

 @param queue dispatch_queue
 @param key The context for the specified key or NULL if no context was found
 @param waitUntilDone YES:同步  NO:异步
 @param block 执行操作
 */
void performBlockOnCustomQueue(dispatch_queue_t queue, const void * _Nullable key, BOOL waitUntilDone, void (^block)(void)) {
    CFStringRef retrievedValue = dispatch_get_specific(key); // dispatch_queue_get_specific(queue, key);
    if (key != NULL && retrievedValue) {
        block();
    } else {
        if (waitUntilDone)
            dispatch_sync(queue, block);
        else
            dispatch_async(queue, block);
    }
}

/**
 在自定义队列中Barrier执行操作

 @param queue 自定义队列
 @param key The context for the specified key or NULL if no context was found
 @param allowNesting 是否允许dispatch_barrier 嵌套执行
 @param waitUntilDone YES:同步  NO:异步
 @param block 回调block
 */
void performBarrierBlockOnCustomQueue(dispatch_queue_t queue, const void * _Nullable key, BOOL allowNesting, BOOL waitUntilDone, void (^block)(void)) {
    CFStringRef retrievedValue = dispatch_get_specific(key); // dispatch_queue_get_specific(queue, key);
    if (key != NULL && retrievedValue) {
        if (allowNesting)
            dispatch_barrier_async(queue, block);
        else
            block();
    } else {
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
 在自定义队列中Barrier执行操作

 @param queue 自定义队列
 @param waitUntilDone YES:同步  NO:异步
 @param block 回调block
 */
void performBarrierBlock(dispatch_queue_t queue, BOOL waitUntilDone, void (^block)(void)) {
    performBarrierBlockOnCustomQueue(queue, NULL, YES, waitUntilDone, block);
}

/**
 延迟多少秒执行操作

 @param queue 队列
 @param delay 延迟时间
 @param block 执行操作
 */
void performBlockDelay(dispatch_queue_t queue, NSTimeInterval delay, dispatch_block_t block) {
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(when, queue, block);
}

void BasicParametersOfType(const char *argType, id paramObj, void *retVal) {
    if (!retVal) return;

    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;
    id obj = [paramObj isKindOfClass:[NSNull class]] ? nil : paramObj;

    if (strcmp(argType, @encode(char)) == 0) {
        *((char *)retVal) = [obj charValue];
    } else if (strcmp(argType, @encode(int)) == 0) {
        *((int *)retVal) = [obj intValue];
    } else if (strcmp(argType, @encode(short)) == 0) {
        *(short *)retVal = [obj shortValue];
    } else if (strcmp(argType, @encode(long)) == 0) {
        *(long *)retVal = [obj longValue];
    } else if (strcmp(argType, @encode(long long)) == 0) {
        *(long long *)retVal = [obj longLongValue];
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        *(unsigned char *)retVal = [obj unsignedCharValue];
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        *(unsigned int *)retVal = [obj unsignedIntValue];
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        *(unsigned short *)retVal = [obj unsignedShortValue];
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        *(unsigned long *)retVal = [obj unsignedLongValue];
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        *(unsigned long long *)retVal = [obj unsignedLongLongValue];
    } else if (strcmp(argType, @encode(float)) == 0) {
        *(float *)retVal = [obj floatValue];
    } else if (strcmp(argType, @encode(double)) == 0) {
        *(double *)retVal = [obj doubleValue];
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        *(BOOL *)retVal = [obj boolValue];
    } else if (strcmp(argType, @encode(bool)) == 0) {
        *(bool *)retVal = [obj boolValue];
    } else if (strcmp(argType, @encode(char *)) == 0) {
        strcpy(retVal, (__bridge void *)obj);
    }
}

void SetInvocationParams(NSInvocation **invocation, NSMethodSignature *methodSignature, NSArray *parameters) {
    // 签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
    NSInteger signatureParamCount = methodSignature.numberOfArguments - 2;
    NSInteger requireParamCount   = parameters.count;
    NSInteger resultParamCount    = MIN(signatureParamCount, requireParamCount);

    void *argBuf = NULL;
    for (NSInteger i = 0; i < resultParamCount; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:2 + i];

        id obj = parameters[i];
        // 需要做参数类型判断然后解析成对应类型
        if (strcmp(type, "@") == 0 ||
            strcmp(type, "@?") == 0) { // 函数参数类型为OC对象处理 或 Block 对象
            if ([obj isKindOfClass:[NSNull class]]) {
                obj = nil;
            }
            [*invocation setArgument:&obj atIndex:2 + i];
        } else { // 基础数据类型处理
            NSUInteger argSize;
            NSGetSizeAndAlignment(type, &argSize, NULL);
            if (!(argBuf = reallocf(argBuf, argSize))) {
                return;
            }

            BasicParametersOfType(type, obj, argBuf);
            [*invocation setArgument:argBuf atIndex:2 + i];
        }
    }

    [*invocation retainArguments]; // retain 所有参数， 防止参数被释放

    if (argBuf) {
        free(argBuf);
    }
}

/**
 多参数实例对象performSelecor 实现

 @param instance 实例对象
 @param aSelector aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @return 对应函数返回值
 */
id PerformInstanceMethodWithParams(id instance, SEL aSelector, NSArray *parameters) {
    if (instance == nil || aSelector == nil || ![instance respondsToSelector:aSelector]) {
        return nil;
    }

    NSMethodSignature *methodSignature = [[instance class] instanceMethodSignatureForSelector:aSelector];

    if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:instance];
        [invocation setSelector:aSelector];
        SetInvocationParams(&invocation, methodSignature, parameters);
        [invocation invoke];

        id callBackObject = nil;
        if (strcmp(methodSignature.methodReturnType, "@") == 0) {
            [invocation getReturnValue:&callBackObject];
        } else if (strcmp(methodSignature.methodReturnType, "v") != 0) { // 基础类型
            long long val = 0;
            [invocation getReturnValue:&val];
            callBackObject = [NSString stringWithFormat:@"%@", @(val)];
        }

        return callBackObject;
    }

    return nil;
}

/**
 多参数类方法performSelecor 实现

 @param aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @return 对应函数返回值
 */
id PerformClassMethodWithParams(Class class, SEL aSelector, NSArray *parameters) {
    if (class == nil || aSelector == nil || ![class respondsToSelector:aSelector]) {
        return nil;
    }

    NSMethodSignature *methodSignature = [class methodSignatureForSelector:aSelector];

    if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:class];
        [invocation setSelector:aSelector];
        SetInvocationParams(&invocation, methodSignature, parameters);
        [invocation invoke];

        id callBackObject = nil;

        if (strcmp(methodSignature.methodReturnType, "@") == 0) {
            [invocation getReturnValue:&callBackObject];
        } else if (strcmp(methodSignature.methodReturnType, "v") != 0) { // 基础类型
            long long val = 0;
            [invocation getReturnValue:&val];
            callBackObject = [NSString stringWithFormat:@"%@", @(val)];
        }

        return callBackObject;
    }

    return nil;
}

/**
 多参数performSelecor 实现(带通用返回值)

 @param instance 实例对象
 @param aSelector 方法名
 @param parameters 参数列表 nil参数 传[NSNull null]
 @param returnVal 返回值
 */
void PerformInstanceMethodWithReturnValue(id instance, SEL aSelector, NSArray * _Nullable parameters, void *returnVal) {
    if (instance == nil || aSelector == nil || ![instance respondsToSelector:aSelector]) {
        returnVal = NULL;
    }

    NSMethodSignature *methodSignature = [[instance class] instanceMethodSignatureForSelector:aSelector];

    if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:instance];
        [invocation setSelector:aSelector];
        SetInvocationParams(&invocation, methodSignature, parameters);
        [invocation invoke];

        if (returnVal && strcmp(methodSignature.methodReturnType, "v") != 0) {
            [invocation getReturnValue:returnVal];
        }
    }
}

@end
