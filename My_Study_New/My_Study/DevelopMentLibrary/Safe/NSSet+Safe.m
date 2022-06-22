//
//  NSSet+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSSet+Safe.h"
#import "WMSafeProxy.h"

@implementation NSSet (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSSet swizzleClassMethod:@selector(setWithObject:) withMethod:@selector(hookSetWithObject:)];
    });
}
+ (instancetype)hookSetWithObject:(id)object
{
    if (object){
        return [self hookSetWithObject:object];
    }
    SFAssert(NO, @"NSSet invalid args hookSetWithObject:[%@]", object);
    return nil;
}
@end
