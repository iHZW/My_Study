//
//  NSMutableArray+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableArray+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableArray (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /* __NSArrayM */
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:), @selector(hookAddObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:), @selector(hookInsertObject:atIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectAtIndex:), @selector(hookRemoveObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(hookReplaceObjectAtIndex:withObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectsInRange:), @selector(hookRemoveObjectsInRange:));
        
        /* __NSCFArray */
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(addObject:), @selector(hookAddObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(insertObject:atIndex:), @selector(hookInsertObject:atIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(removeObjectAtIndex:), @selector(hookRemoveObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(replaceObjectAtIndex:withObject:), @selector(hookReplaceObjectAtIndex:withObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(removeObjectsInRange:), @selector(hookRemoveObjectsInRange:));
    });
}
- (void) hookAddObject:(id)anObject {
    @synchronized (self) {
        if (anObject) {
            [self hookAddObject:anObject];
        } else {
            SFAssert(NO, @"NSMutableArray invalid args hookAddObject:[%@]", anObject);
        }
    }
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
- (void) hookInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @synchronized (self) {
        if (anObject && index <= self.count) {
            [self hookInsertObject:anObject atIndex:index];
        } else {
            if (!anObject) {
                SFAssert(NO, @"NSMutableArray invalid args hookInsertObject:[%@] atIndex:[%@]", anObject, @(index));
            }
            if (index > self.count) {
                SFAssert(NO, @"NSMutableArray hookInsertObject[%@] atIndex:[%@] out of bound:[%@]", anObject, @(index), @(self.count));
            }
        }
    }
}

- (void) hookRemoveObjectAtIndex:(NSUInteger)index {
    @synchronized (self) {
        if (index < self.count) {
            [self hookRemoveObjectAtIndex:index];
        } else {
            SFAssert(NO, @"NSMutableArray hookRemoveObjectAtIndex:[%@] out of bound:[%@]", @(index), @(self.count));
        }
    }
}


- (void) hookReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    @synchronized (self) {
        if (index < self.count && anObject) {
            [self hookReplaceObjectAtIndex:index withObject:anObject];
        } else {
            if (!anObject) {
                SFAssert(NO, @"NSMutableArray invalid args hookReplaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
            }
            if (index >= self.count) {
                SFAssert(NO, @"NSMutableArray hookReplaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
            }
        }
    }
}

- (void) hookRemoveObjectsInRange:(NSRange)range {
    @synchronized (self) {
        if (NSSafeMaxRange(range) <= self.count) {
            [self hookRemoveObjectsInRange:range];
        }else {
            SFAssert(NO, @"NSMutableArray invalid args hookRemoveObjectsInRange:[%@]", NSStringFromRange(range));
        }
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


@end
