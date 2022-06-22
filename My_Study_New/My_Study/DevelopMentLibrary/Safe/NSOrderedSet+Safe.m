//
//  NSOrderedSet+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSOrderedSet+Safe.h"
#import "WMSafeProxy.h"

@implementation NSOrderedSet (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSOrderedSet swizzleClassMethod:@selector(orderedSetWithObject:) withMethod:@selector(hookOrderedSetWithObject:)];
        
        /* init方法 */
        swizzleInstanceMethod(NSClassFromString(@"__NSPlaceholderOrderedSet"), @selector(initWithObject:), @selector(hookInitWithObject:));
        
        /* 普通方法 */
        swizzleInstanceMethod(NSClassFromString(@"__NSOrderedSetI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    });
}
+ (instancetype)hookOrderedSetWithObject:(id)object
{
    if (object) {
        return [self hookOrderedSetWithObject:object];
    }
    SFAssert(NO, @"NSOrderedSet invalid args hookOrderedSetWithObject:[%@]", object);
    return nil;
}
- (instancetype)hookInitWithObject:(id)object
{
    if (object){
        return [self hookInitWithObject:object];
    }
    SFAssert(NO, @"NSOrderedSet invalid args hookInitWithObject:[%@]", object);
    return nil;
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

@end
