//
//  NSMutableSet+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSMutableSet+Safe.h"
#import "WMSafeProxy.h"

@implementation NSMutableSet (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 普通方法 */
        NSMutableSet* obj = [NSMutableSet setWithObjects:@0, nil];
        [obj swizzleInstanceMethod:@selector(addObject:) withMethod:@selector(hookAddObject:)];
        [obj swizzleInstanceMethod:@selector(removeObject:) withMethod:@selector(hookRemoveObject:)];
    });
}
- (void) hookAddObject:(id)object {
    @synchronized (self) {
        if (object) {
            [self hookAddObject:object];
        } else {
            SFAssert(NO, @"NSMutableSet invalid args hookAddObject[%@]", object);
        }
    }
}

- (void) hookRemoveObject:(id)object {
    @synchronized (self) {
        if (object) {
            [self hookRemoveObject:object];
        } else {
            SFAssert(NO, @"NSMutableSet invalid args hookRemoveObject[%@]", object);
        }
    }
}

@end
