//
//  NSObject+WFObserver.m
//  My_Study
//
//  Created by HZW on 2020/4/5.
//  Copyright © 2020 HZW. All rights reserved.
//

#import "NSObject+WFObserver.h"
#import <objc/message.h>

static const char observerKey;

@implementation NSObject (WFObserver)

- (void)wf_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"WFClass_%@",oldClassName];
    
    /**< 创建一个类 */
    Class myClass = objc_allocateClassPair(self.class, newClassName.UTF8String, 0);
    /**< 注册类 */
    objc_registerClassPair(myClass);
    
    NSString *selecName = keyPath;
    NSString *impName = keyPath;
    if (selecName.length > 0) {
        selecName = [keyPath stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[keyPath substringToIndex:1] capitalizedString]];
        selecName = [NSString stringWithFormat:@"set%@:",selecName];
        
//        impName = [keyPath stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[keyPath substringToIndex:1] capitalizedString]];
//        impName = [NSString stringWithFormat:@"set%@",impName];
    }
    SEL sel = NSSelectorFromString(selecName);
    /**< 重写set方法 */
    class_addMethod(myClass, sel, (IMP)setName, "v@:@");
    /**< 修改isa指针 */
    object_setClass(self, myClass);
    /**< 讲观察者保存到当前对象 */
    objc_setAssociatedObject(self, &observerKey, observer, OBJC_ASSOCIATION_ASSIGN);
 
}

void setName(id self, SEL _cmd, NSString *name){
    NSLog(@"来了老弟~%@", name);
    /**< 调用父类的setName方法 */
    Class class = [self class];
    /**< 设置为父类 */
    object_setClass(self, class_getSuperclass(class));
    /**< 调用父类的方法 */
    ((void (*)(id, SEL, NSString *))objc_msgSend)(self, @selector(setName:), name);
    id observer = objc_getAssociatedObject(self, &observerKey);
    if (observer) {
        ((void (*)(id, SEL, NSString *, id, id, void *))objc_msgSend)(observer, @selector(observeValueForKeyPath:ofObject:change:context:), @"name", self, @{@"new" : name, @"kind" : @10}, nil);
    }
    /**< 改回子类 */
    object_setClass(self, class);
}



- (void)wf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    
}


@end

