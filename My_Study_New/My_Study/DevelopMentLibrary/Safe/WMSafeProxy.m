//
//  WMSafeProxy.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#define WMSafeNotification @"_WMSafeNotification_"

#import "WMSafeProxy.h"

void WMSafeLog(const char* file, const char* func, int line, NSString* fmt, ...)
{
    NSString *reason = @"";
    va_list args;
    va_start(args, fmt);
    reason = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    
    @try {
        NSException *exception = [NSException exceptionWithName:@"WMSafeException" reason:reason userInfo:nil];
        @throw exception;
    } @catch (NSException *exception) {
        [WMSafeProxy dealException:exception];
    }
}

void swizzleClassMethod(Class cls, SEL origSelector, SEL newSelector)
{
    if (!cls) return;
    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method swizzledMethod = class_getClassMethod(cls, newSelector);
    
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(metacls,
                            newSelector,
                            class_replaceMethod(metacls,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

void swizzleInstanceMethod(Class cls, SEL origSelector, SEL newSelector)
{
    if (!cls) {
        return;
    }
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    // 私有类可能随系统版本变化，方法不存在时不能安装无法回调的 Hook。
    if (!originalMethod || !swizzledMethod || origSelector == newSelector) {
        return;
    }

    // 子类可能继承了父类已安装的 Hook；再次交换会让回调指向 Hook 自身。
    if (method_getImplementation(originalMethod) == method_getImplementation(swizzledMethod)) {
        return;
    }

    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            newSelector,
                            class_replaceMethod(cls,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

/**
 * 1: negative value
 *  - NSUInteger  > NSIntegerMax
 * 2: overflow
 *  - (a+ b) > a
 */
NSUInteger NSSafeMaxRange(NSRange range) {
    // negative or reach limit
    if (range.location >= NSNotFound
        || range.length >= NSNotFound){
        return NSNotFound;
    }
    // overflow
    if ((range.location + range.length) < range.location){
        return NSNotFound;
    }
    return (range.location + range.length);
}

@implementation WMSafeProxy

+ (void)dealException:(NSException *)exception
{
    NSLog(@"==========================WMSAFE============================\n%@",exception);
    NSDictionary *errorInfoDic = @{
                                   @"exception" :exception
                                   };
    //将错误信息放在字典里，用通知的形式发送出去
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WMSafeNotification object:nil userInfo:errorInfoDic];
    });
    
}

@end
