//
//  NSCache+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSCache+Safe.h"
#import "WMSafeProxy.h"

@implementation NSCache (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod([NSCache class], @selector(setObject:forKey:), @selector(hookSetObject:forKey:));
        swizzleInstanceMethod([NSCache class], @selector(setObject:forKey:cost:), @selector(hookSetObject:forKey:cost:));
    });
}
- (void)hookSetObject:(id)obj forKey:(id)key // 0 cost
{
    if (obj) {
        [self hookSetObject:obj forKey:key];
    }else {
        SFAssert(NO, @"NSCache invalid args hookSetObject:[%@] forKey:[%@]", obj, key);
    }
}
- (void)hookSetObject:(id)obj forKey:(id)key cost:(NSUInteger)g
{
    if (obj) {
        [self hookSetObject:obj forKey:key cost:g];
    }else {
        SFAssert(NO, @"NSCache invalid args hookSetObject:[%@] forKey:[%@] cost:[%@]", obj, key, @(g));
    }
}

@end
