//
//  Cat.m
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//

#import "Cat.h"
#import "objc/runtime.h"
#import "Dog.h"

void catSendMessage(id self, SEL _cmd, NSString *msg, NSInteger age){
    NSLog(@" C语言  cat mag = %@ \n age = %@", msg, @(age));

}

@implementation Cat

- (void)ocSendMessage:(NSString *)msg age:(NSInteger)age
{
    NSLog(@"OC语言 cat mag = %@ \n age = %@", msg, @(age));
}

/**< 动态解析   添加方法实现 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *methodName = NSStringFromSelector(sel);
    
    if ([methodName isEqualToString:@"sendMessageName:age:"]) {
        /**< C语言 IMP*/
//        return class_addMethod([self class], sel, (IMP)catSendMessage, "v@:@@");
        /**< OC IMP*/
//        return class_addMethod([self class], sel, (IMP)class_getMethodImplementation_stret([self class], @selector(ocSendMessage:age:)), "v@:@@");
    }
    return NO;
}

/**< 找一个备用接受者 */
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendMessageName:age:"]) {
//        return [Dog new];
    }
    return [super forwardingTargetForSelector:aSelector];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"sendMessageName:age:"]) {
       return [NSMethodSignature signatureWithObjCTypes:"v@:@@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    Dog *tempDog = [Dog new];
    if ([tempDog respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:tempDog];
    }else{
        [super forwardInvocation:anInvocation];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    
}


@end
