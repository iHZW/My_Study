//
//  ZYWeakObject.m
//  test1
//
//  Created by zhouyang on 2018/8/2.
//  Copyright © 2018年 zhouyang. All rights reserved.
//

#import "ZYWeakObject.h"

@interface ZYWeakObject()

@property (weak, nonatomic) id weakObject;


@end

@implementation ZYWeakObject

- (instancetype)initWithWeakObject:(id)obj {
    _weakObject = obj;
    return self;
}

+ (instancetype)proxyWithWeakObject:(id)obj {
    return [[ZYWeakObject alloc] initWithWeakObject:obj];
}

/**
 * 消息转发，对象转发，让_weakObject响应事件
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _weakObject;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_weakObject respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (Class)class {
    return [_weakObject class];
}

- (Class)superclass {
    return [_weakObject superclass];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_weakObject isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_weakObject isMemberOfClass:aClass];
}

@end



