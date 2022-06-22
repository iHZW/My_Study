//
//  NSMutableDictionary+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableDictionary (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKey:), @selector(hookSetObject:forKey:));
        swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(removeObjectForKey:), @selector(hookRemoveObjectForKey:));
        swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKeyedSubscript:), @selector(hookSetObject:forKeyedSubscript:));
    });
}

- (void) hookSetObject:(id)anObject forKey:(id)aKey {
    @synchronized (self) {
        if (anObject && aKey) {
            [self hookSetObject:anObject forKey:aKey];
        } else {
            SFAssert(NO, @"NSMutableDictionary invalid args hookSetObject:[%@] forKey:[%@]", anObject, aKey);
        }
    }
}

- (void) hookRemoveObjectForKey:(id)aKey {
    @synchronized (self) {
        if (aKey) {
            [self hookRemoveObjectForKey:aKey];
        } else {
            SFAssert(NO, @"NSMutableDictionary invalid args hookRemoveObjectForKey:[%@]", aKey);
        }
    }
}

- (void)hookSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    @synchronized (self) {
        if (key){
            [self hookSetObject:obj forKeyedSubscript:key];
        } else {
            SFAssert(NO, @"NSMutableDictionary invalid args hookSetObject:forKeyedSubscript:");
        }
    }
}

@end
