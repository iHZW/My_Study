//
//  NSArray+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSArray+Safe.h"
#import "WMSafeProxy.h"

@implementation NSArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法不用在NSMutableArray里再swizz一次 */
        [NSArray swizzleClassMethod:@selector(arrayWithObject:) withMethod:@selector(hookArrayWithObject:)];
        [NSArray swizzleClassMethod:@selector(arrayWithObjects:count:) withMethod:@selector(hookArrayWithObjects:count:)];
        
        /* 没内容类型是__NSArray0 */
        swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        /* 有内容obj类型才是__NSArrayI */
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        /* 有内容obj类型才是__NSArrayI_Transfer */
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        /* iOS10 以上，单个内容类型是__NSSingleObjectArrayI */
        swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        /* __NSFrozenArrayM */
        swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        /* __NSArrayReversed */
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    });
}
+ (instancetype) hookArrayWithObject:(id)anObject
{
    if (anObject) {
        return [self hookArrayWithObject:anObject];
    }
    SFAssert(NO, @"NSArray invalid args hookArrayWithObject:[%@]", anObject);
    return nil;
}

- (id) hookObjectAtIndex:(NSUInteger)index {
    @synchronized (self) {
        if (index < self.count) {
            return [self hookObjectAtIndex:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
}
- (id) hookObjectAtIndexedSubscript:(NSInteger)index {
    @synchronized (self) {
        if (index < self.count) {
            return [self hookObjectAtIndexedSubscript:index];
        }
        SFAssert(NO, @"NSArray invalid index:[%@]", @(index));
        return nil;
    }
}
- (NSArray *)hookSubarrayWithRange:(NSRange)range
{
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.count){
            return [self hookSubarrayWithRange:range];
        }else if (range.location < self.count){
            return [self hookSubarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
        }
        return nil;
    }
}
+ (instancetype)hookArrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    @synchronized (self) {
        NSInteger index = 0;
        id objs[cnt];
        for (NSInteger i = 0; i < cnt ; ++i) {
            if (objects[i]) {
                objs[index++] = objects[i];
            } else {
                SFAssert(NO, @"NSArray invalid args hookArrayWithObjects:[%@] atIndex:[%@]", objects[i], @(i));
            }
        }
        return [self hookArrayWithObjects:objs count:index];
    }
}

@end
