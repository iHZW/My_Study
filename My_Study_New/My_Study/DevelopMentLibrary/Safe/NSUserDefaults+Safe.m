//
//  NSUserDefaults+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSUserDefaults+Safe.h"
#import "WMSafeProxy.h"

@implementation NSUserDefaults (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"NSUserDefaults"), @selector(objectForKey:), @selector(hookObjectForKey:));
        swizzleInstanceMethod(NSClassFromString(@"NSUserDefaults"), @selector(setObject:forKey:), @selector(hookSetObject:forKey:));
        swizzleInstanceMethod(NSClassFromString(@"NSUserDefaults"), @selector(removeObjectForKey:), @selector(hookRemoveObjectForKey:));
    });
}
- (id) hookObjectForKey:(NSString *)defaultName
{
    if (defaultName) {
        return [self hookObjectForKey:defaultName];
    }
    return nil;
}

- (void) hookSetObject:(id)value forKey:(NSString*)aKey
{
    if (aKey) {
        [self hookSetObject:value forKey:aKey];
    } else {
        SFAssert(NO, @"NSUserDefaults invalid args hookSetObject:[%@] forKey:[%@]", value, aKey);
    }
}
- (void) hookRemoveObjectForKey:(NSString*)aKey
{
    if (aKey) {
        [self hookRemoveObjectForKey:aKey];
    } else {
        SFAssert(NO, @"NSUserDefaults invalid args hookRemoveObjectForKey:[%@]", aKey);
    }
}

@end
