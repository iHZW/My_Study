//
//  NSMutableOrderedSet+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableOrderedSet+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableOrderedSet (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 普通方法 */
        NSMutableOrderedSet* obj = [NSMutableOrderedSet orderedSetWithObjects:@0, nil];
        [obj swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(hookObjectAtIndex:)];
        [obj swizzleInstanceMethod:@selector(addObject:) withMethod:@selector(hookAddObject:)];
        [obj swizzleInstanceMethod:@selector(removeObjectAtIndex:) withMethod:@selector(hookRemoveObjectAtIndex:)];
        [obj swizzleInstanceMethod:@selector(insertObject:atIndex:) withMethod:@selector(hookInsertObject:atIndex:)];
        [obj swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withMethod:@selector(hookReplaceObjectAtIndex:withObject:)];
    });
}
- (id)hookObjectAtIndex:(NSUInteger)idx
{
    @synchronized (self) {
        if (idx < self.count){
            return [self hookObjectAtIndex:idx];
        }
        return nil;
    }
}
- (void)hookAddObject:(id)object {
    @synchronized (self) {
        if (object) {
            [self hookAddObject:object];
        } else {
            SFAssert(NO, @"NSMutableOrderedSet invalid args hookAddObject:[%@]", object);
        }
    }
}
- (void)hookInsertObject:(id)object atIndex:(NSUInteger)idx
{
    @synchronized (self) {
        if (object && idx <= self.count) {
            [self hookInsertObject:object atIndex:idx];
        }else{
            SFAssert(NO, @"NSMutableOrderedSet invalid args hookInsertObject:[%@] atIndex:[%@]", object, @(idx));
        }
    }
}
- (void)hookRemoveObjectAtIndex:(NSUInteger)idx
{
    @synchronized (self) {
        if (idx < self.count){
            [self hookRemoveObjectAtIndex:idx];
        }else{
            SFAssert(NO, @"NSMutableOrderedSet invalid args hookRemoveObjectAtIndex:[%@]", @(idx));
        }
    }
}
- (void)hookReplaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    @synchronized (self) {
        if (object && idx < self.count) {
            [self hookReplaceObjectAtIndex:idx withObject:object];
        }else{
            SFAssert(NO, @"NSMutableOrderedSet invalid args hookReplaceObjectAtIndex:[%@] withObject:[%@]", @(idx), object);
        }
    }
}

@end
