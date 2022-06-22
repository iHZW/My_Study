//
//  CMBusMediaAppDelegate.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMBusMediaAppDelegate.h"
#import "NSObject+Customizer.h"


@interface CMBusMediaAppDelegate ()
/**
 记录注册组件的相关信息(元素为生成的对象示例)
 */
@property (nonatomic, strong) NSMutableArray<id<UIApplicationDelegate>> *connectorMap;


@end

@implementation CMBusMediaAppDelegate

DEFINE_SINGLETON_T_FOR_CLASS(CMBusMediaAppDelegate);

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _connectorMap = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

/**
 服务组件调用方法

 @param selector 方法名
 @param params 相关参数
 */
+ (void)serviceManager:(SEL)selector withParameters:(NSArray *)params
{
    for (NSObject *service in [CMBusMediaAppDelegate services]) {
        if ([service respondsToSelector:selector]){
            [service performSelector:selector withParameters:params];
        }
    }
}

/**
 指定服务组件执行指定方法

 @param service 指定的组件服务实例
 @param selector 方法名
 @param params 相关参数
 */
+ (void)performAction:(NSObject *)service selector:(SEL)selector withParameters:(NSArray *)params
{
    if ([service respondsToSelector:selector]) {
        [service performSelector:selector withParameters:params];
    }
}

/**
 注册UIApplicationDelegate服务组件
 
 @param service 实现UIApplicationDelegate协议的服务组件
 */
+ (void)regisertService:(id<UIApplicationDelegate>)service
{
    @synchronized ([CMBusMediaAppDelegate sharedCMBusMediaAppDelegate].connectorMap) {
        if (service && ![[CMBusMediaAppDelegate sharedCMBusMediaAppDelegate].connectorMap containsObject:service]) {
            [[CMBusMediaAppDelegate sharedCMBusMediaAppDelegate].connectorMap addObject:service];
        }
    }
}

/**
 获取当前注册组件列表信息
 */
+ (NSArray<id<UIApplicationDelegate>> *)services
{
    return [CMBusMediaAppDelegate sharedCMBusMediaAppDelegate].connectorMap;
}

/**
 通过类名获取当前实例对象

 @param className 类名
 @return 返回对应实例对象
 */
+ (id<UIApplicationDelegate>)service:(Class)className
{
    __block id retObj = nil;
    [[CMBusMediaAppDelegate sharedCMBusMediaAppDelegate].connectorMap enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<UIApplicationDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:className]) {
            retObj  = obj;
            *stop   = YES;
        }
    }];
    
    return retObj;
}


@end
