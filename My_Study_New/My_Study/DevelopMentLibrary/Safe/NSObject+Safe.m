//
//  NSObject+Safe.m
//  CRM
//
//  Created by 杜文杰 on 2022/5/6.
//  Copyright © 2022 CRM. All rights reserved.
//

#import "NSObject+Safe.h"
#import "WMSafeProxy.h"

@implementation NSObject (Safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), @selector(hookAddObserver:forKeyPath:options:context:));
        swizzleInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), @selector(hookRemoveObserver:forKeyPath:));
        swizzleInstanceMethod([NSObject class], @selector(methodSignatureForSelector:), @selector(hookMethodSignatureForSelector:));
        swizzleInstanceMethod([NSObject class], @selector(forwardInvocation:), @selector(hookForwardInvocation:));
    });
}
- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (!observer || !keyPath.length) {
        SFAssert(NO, @"hookAddObserver invalid args: %@", self);
        return;
    }
    @try {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }
    @catch (NSException *exception) {
        NSLog(@"hookAddObserver ex: %@", [exception callStackSymbols]);
    }
}
- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if (!observer || !keyPath.length) {
        SFAssert(NO, @"hookRemoveObserver invalid args: %@", self);
        return;
    }
    @try {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSLog(@"hookRemoveObserver ex: %@", [exception callStackSymbols]);
    }
}

- (NSMethodSignature*)hookMethodSignatureForSelector:(SEL)aSelector {
    /* 如果 当前类有methodSignatureForSelector实现，NSObject的实现直接返回nil
     * 子类实现如下：
     *          NSMethodSignature* sig = [super methodSignatureForSelector:aSelector];
     *          if (!sig) {
     *              //当前类的methodSignatureForSelector实现
     *              //如果当前类的methodSignatureForSelector也返回nil
     *          }
     *          return sig;
     */
    NSMethodSignature* sig = [self hookMethodSignatureForSelector:aSelector];
    if (!sig){
        if (class_getMethodImplementation([NSObject class], @selector(methodSignatureForSelector:))
            != class_getMethodImplementation(self.class, @selector(methodSignatureForSelector:)) ){
            return nil;
        }
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return sig;
}

- (void)hookForwardInvocation:(NSInvocation*)invocation
{
    NSString* info = [NSString stringWithFormat:@"unrecognized selector [%@] sent to %@", NSStringFromSelector(invocation.selector), NSStringFromClass(self.class)];

    NSString* msg = [NSString stringWithFormat:@"SafeProxy: %@", info];
    SFAssert(0, msg);
}
@end
