//
//  NSObject+DeallocExecutor.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/1.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "NSObject+ZWDeallocExecutor.h"
#import <objc/runtime.h>


const void *ZWDeallocExecutorsKey = &ZWDeallocExecutorsKey;

@interface ZWDeallocExecutor : NSObject

@property (nonatomic, copy) void(^deallocExecutorBlock)(void);

@end

@implementation ZWDeallocExecutor

- (id)initWithBlock:(void(^)(void))deallocExecutorBlock {
    self = [super init];
    if (self) {
        _deallocExecutorBlock = [deallocExecutorBlock copy];
    }
    return self;
}

- (void)dealloc {
    _deallocExecutorBlock ? _deallocExecutorBlock() : nil;
}

@end


@implementation NSObject (ZWDeallocExecutor)

- (void)zw_executeAtDealloc:(void (^)(void))block
{
    if (block) {
        ZWDeallocExecutor *excutor = [[ZWDeallocExecutor alloc] initWithBlock:block];
        /** 创建一个互斥锁.保证同一时间内没有其他线程对self对象进行修改, 起到线程的保护作用  */
        @synchronized (self) {
            [[self hs_deallocExecutor] addObject:excutor];
        }
    }
}

- (NSHashTable *)hs_deallocExecutor
{
    NSHashTable *table = objc_getAssociatedObject(self, ZWDeallocExecutorsKey);
    if (!table) {
        table = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
        objc_setAssociatedObject(self, ZWDeallocExecutorsKey, table, OBJC_ASSOCIATION_RETAIN);
    }
    return table;
}

@end
