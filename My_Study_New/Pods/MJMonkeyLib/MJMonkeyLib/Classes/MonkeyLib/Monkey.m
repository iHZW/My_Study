//
//  Monkey.m
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//

#import "Monkey.h"
#import "objc/runtime.h"
#import "Dog.h"

void sendMessage(id self, SEL _cmd, NSString *str){
    NSLog(@"str = %@", str);
}


@implementation Monkey

- (void)monkeyPlayMethod:(NSString *)play
{
    NSLog(@"play = %@", play);
}


/**< 动态方法解析   添加方法处理 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"sendMessage:"]) {
        /**< c */
//        return class_addMethod([self class], sel, (IMP)sendMessage, "v@:@");
        /**< OC */
//        return class_addMethod([self class], sel, (IMP)class_getMethodImplementation([self class], @selector(monkeyPlayMethod:)), "v@:@");
    }
    return NO;
}


/**< 快速转发 备用接收者*/
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendMessage:"]) {
//        return [Dog new];
    }
    return [super forwardingTargetForSelector:aSelector];
}


/**< 方法签名 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendMessage:"]) {
       return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

/**< 慢速转发 */
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL sel = [anInvocation selector];
    Dog *dog = [Dog new];
    if ([dog respondsToSelector:sel]){
        [anInvocation invokeWithTarget:dog];
    }else{
        [super forwardInvocation:anInvocation];
    }
    /**< 动态创建一个类 */
//    objc_allocateClassPair(<#Class  _Nullable __unsafe_unretained superclass#>, <#const char * _Nonnull name#>, <#size_t extraBytes#>)
}


#pragma mark -----------------------------类 消息传递---------------------------------------------------

void sendClassMessage(id self, SEL _cmd, NSString *msg){
    NSLog(@"class msg = %@", msg);
}

+ (void)ocSendClassMessage:(NSString *)msg{
    NSLog(@"OC---class msg = %@", msg);
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"sendClassMessage:"]) {
//        return class_addMethod(object_getClass([Monkey class]), sel, (IMP)sendClassMessage, "v@:@");
//        return class_addMethod(object_getClass([Monkey class]), sel, class_getMethodImplementation(object_getClass([Monkey class]), @selector(ocSendClassMessage:)), "v@:@");
    }
    return NO;
}

+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendClassMessage:"]) {
//        return [Dog class];
    }
    return [super forwardingTargetForSelector:aSelector];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendClassMessage:"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL sel = [anInvocation selector];
    if ([[Dog class] respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:[Dog class]];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

@end
