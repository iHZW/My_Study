//
//  WMSafeProxy.h
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define SFAssert(condition, ...) \
if (!(condition)){ WMSafeLog(__FILE__, __FUNCTION__, __LINE__, __VA_ARGS__);} \

void WMSafeLog(const char* _Nullable file, const char* _Nullable func, int line, NSString* _Nullable fmt, ...);

void swizzleClassMethod(Class _Nonnull cls, SEL _Nonnull origSelector, SEL _Nonnull newSelector);

void swizzleInstanceMethod(Class _Nonnull cls, SEL _Nonnull origSelector, SEL _Nonnull newSelector);

NSUInteger NSSafeMaxRange(NSRange range);


@interface WMSafeProxy : NSObject

+ (void)dealException:(nullable NSException *)exception;

@end

