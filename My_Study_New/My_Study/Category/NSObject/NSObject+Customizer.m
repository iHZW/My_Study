//
//  NSObject+Customizer.m
//  Video
//
//  Created by Howard on 13-5-15.
//  Copyright (c) 2013年 PAS. All rights reserved.
//

#import "NSObject+Customizer.h"
#import <objc/runtime.h>


const NSString *kRefreshType        = @"refreshType";      // 刷新方式
const NSString *kForceRefresh       = @"forceRefresh";     // 是否强制刷新
const NSString *kReqPageNo          = @"reqPageNo";        // 请求叶号
const NSString *kReqPos             = @"reqPos";           // 请求位置
const NSString *kReqNum             = @"reqNum";           // 请求数目

static const char *ObjectTagKey = "ObjectTag";
static const char *TabBarItemKey    = "TabBarItemKey";

@implementation NSObject (Customizer)
@dynamic objectTag;
@dynamic tabBarItemKey;

- (NSString *)objectTag
{
    NSString *tag = objc_getAssociatedObject(self, ObjectTagKey);
    if ([tag length] <= 0)
    {
        tag = [NSObject uuidString];
        self.objectTag = tag;
    }
    return [tag copy];
}

- (void)setObjectTag:(NSString *)newObjectTag
{
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tabBarItemKey
{
    return objc_getAssociatedObject(self, TabBarItemKey);
}

- (void)setTabBarItemKey:(NSString *)tabBarItemKey
{
    objc_setAssociatedObject(self, TabBarItemKey, tabBarItemKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)uuidString
{
    CFUUIDRef uuid          = CFUUIDCreate(NULL);
    NSString *uuidString    = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

/**
 *  对应Class支持类型(默认ObjectClass_Default)
 */
+ (ObjectClassType)objectClassType
{
    return ObjectClass_Default;
}

/**
 *  如果是ObjectClass_ManagerClass类型, 启动服务入口
 */
- (void)startService
{
    
}

/**
 *  获取实际对应的SchemeURL键值
 *
 *  @return 返回键值字典
 */
+ (NSDictionary *)propertyURLSchemeParamKeyMap
{
    return nil;
}

/**
 *  Scheme参数经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 *
 *  @param protocol    Scheme调用中对应URLMap的protocol
 *  @param params      Scheme参数
 *  @param actionBlock SchemeURL检测处理回调方法
 */
- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol params:(NSDictionary *)params actionBlock:(URLParamMapPropertyCheckBlock)actionBlock
{
    if (actionBlock)
        actionBlock();
}

/**
 Scheme参数经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 
 @param protocol Scheme调用中对应URLMap的protocol
 @param object object description
 @param actionBlock protocol 检测处理回调方法
 */
- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol object:(id)object actionBlock:(URLParamMapPropertyCheckBlock)actionBlock
{
    if (actionBlock) {
        actionBlock();
    }
}

/**
 多参数performSelecor 实现

 @param aSelector 方法名
 @param parameters 参数列表
 @return 对应函数返回值
 */
- (id)performSelector:(SEL)aSelector withParameters:(NSArray *)parameters
{
    if (aSelector == nil || ![self respondsToSelector:aSelector]) {
        return nil;
    }
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:aSelector];
    
    if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:aSelector];
        
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
        NSInteger signatureParamCount = methodSignature.numberOfArguments - 2;
        NSInteger requireParamCount = parameters.count;
        NSInteger resultParamCount = MIN(signatureParamCount, requireParamCount);
        
        for (NSInteger i = 0; i < resultParamCount; i++) {
            const char *type = [methodSignature getArgumentTypeAtIndex:2 + i];
            
            // 需要做参数类型判断然后解析成对应类型，这里默认所有参数均为OC对象
            if (strcmp(type, "@") == 0) {
                id obj = parameters[i];
                if ([obj isKindOfClass:[NSNull class]]) {
                    obj = nil;
                }
                [invocation setArgument:&obj atIndex:2+i];
            }
        }
        
        [invocation invoke];
        
        id callBackObject = nil;
        if (strcmp(methodSignature.methodReturnType, "@") == 0) {
            [invocation getReturnValue:&callBackObject];
        }
        
        return callBackObject;
    }
    
    return nil;
}

/**
 类实例方法替换

 @param className 类名
 @param originalSel 原方法
 @param swizzledSel 替换后方法
 */
+ (void)swizzledInstanceMethod:(Class)className originalSelector:(SEL)originalSel swizzledSelector:(SEL)swizzledSel {
    if (!className) return;

    Method originalMethod = class_getInstanceMethod(className, originalSel);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSel);

    IMP origIMP = method_getImplementation(originalMethod);
    IMP swizIMP = method_getImplementation(swizzledMethod);

    const char *origType = method_getTypeEncoding(originalMethod);
    const char *swizType = method_getTypeEncoding(swizzledMethod);

    BOOL didAddMethod = class_addMethod(className, originalSel, swizIMP, swizType);

    if (didAddMethod) {
        class_replaceMethod(className, swizzledSel, origIMP, origType);
    } else {
        //        method_exchangeImplementations(originalMethod, swizzledMethod);
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(className,
                            swizzledSel,
                            class_replaceMethod(className,
                                                originalSel,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

/**
 类方法替换

 @param className 类名
 @param originalSel 原方法
 @param swizzledSel 替换后方法
 */
+ (void)swizzleClassMethods:(Class)className originalSelector:(SEL)originalSel swizzledSelector:(SEL)swizzledSel {
    if (!className) return;

    Method origMethod = class_getClassMethod(className, originalSel);
    Method swizMethod = class_getClassMethod(className, swizzledSel);

    IMP origIMP = method_getImplementation(origMethod);
    IMP swizIMP = method_getImplementation(swizMethod);

    const char *origType = method_getTypeEncoding(origMethod);
    const char *swizType = method_getTypeEncoding(swizMethod);

    Class metaClass = object_getClass(className);

    BOOL didAddMethod = class_addMethod(metaClass, originalSel, swizIMP, swizType);
    if (didAddMethod) {
        class_replaceMethod(metaClass, swizzledSel, origIMP, origType);
    } else {
        //        method_exchangeImplementations(origMethod, swizMethod);
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(metaClass,
                            swizzledSel,
                            class_replaceMethod(metaClass,
                                                originalSel,
                                                method_getImplementation(swizMethod),
                                                method_getTypeEncoding(swizMethod)),
                            method_getTypeEncoding(origMethod));
    }
}

+ (BOOL)isSingleton
{
    return NO;
}

/**
 *  是否支持预加载webView(默认YES：支持)
 */
+ (BOOL)isPrestrainWebview
{
    return YES;
}

@end
