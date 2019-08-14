//
//  NSObject+Customizer.h
//  Video
//
//  Created by Howard on 13-5-15.
//  Copyright (c) 2013年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kRefreshType;      // 刷新方式
extern NSString *kForceRefresh;     // 是否强制刷新
extern NSString *kReqPageNo;        // 请求叶号
extern NSString *kReqPos;           // 请求位置
extern NSString *kReqNum;           // 请求数目

/**
 *  数据列表刷新类型
 */
typedef NS_ENUM(NSInteger, RefreshDataType){
    /**
     *  收到消息更新新数据（有提示）
     */
    refreshDataTypeRefreshNotif         = 0,
    /**
     *  收到消息更新新数据（无提示）
     */
    refreshDataTypeRefreshNotifNoTip    = 1,
    /**
     *  下拉刷新数据
     */
    refreshDataTypeRefreshPulling       = 2,
    /**
     *  累计更新数据
     */
    refreshDataTypeAppending            = 3,
};

/**
 *  对应类支持类型
 */
typedef NS_OPTIONS(NSInteger, ObjectClassType) {
    /**
     *  默认类型(页面展示类处理)
     */
    ObjectClass_Default             = 0,
    /**
     *  对应类单例展示处理
     */
    ObjectClass_Singleton           = 1 << 0,
    /**
     *  对应类管理服务类处理
     */
    ObjectClass_ManagerClass        = 1 << 1,
};

/**
 *  SchemeURL检测处理回调方法
 */
typedef void (^URLParamMapPropertyCheckBlock)();

@protocol NSObjectEx <NSObject>

@property (nonatomic, strong) NSString *objectTag;      // < 为对象生成一个UUID标记值

/**
 *  当前对象对应到TabbarViewController中对应tabBar Item值（默认为nil当前选中的tabBar item）
 */
@property (nonatomic, strong) NSString *tabBarItemKey;

/**
 *  为对象生成一个UUID标记值
 *
 *  @return 返回UUID标记值
 */
+ (NSString *)uuidString;

/**
 *  对应Class支持类型(默认ObjectClass_Default)
 */
+ (ObjectClassType)objectClassType;

/**
 *  如果是ObjectClass_ManagerClass类型, 启动服务入口
 */
- (void)startService;

/**
 *  获取实际对应的SchemeURL键值
 *
 *  @return 返回键值字典
 */
+ (NSDictionary *)propertyURLSchemeParamKeyMap;

/**
 *  Scheme参数经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 *
 *  @param protocol    Scheme调用中对应URLMap的protocol
 *  @param params      Scheme参数
 *  @param actionBlock SchemeURL检测处理回调方法
 */
- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol params:(NSDictionary *)params actionBlock:(URLParamMapPropertyCheckBlock)actionBlock;

/**
 Scheme参数经过特殊处理后回调方法(子类如果调用super方法时，避免重复调用actionBlock)
 
 @param protocol Scheme调用中对应URLMap的protocol
 @param object object description
 @param actionBlock protocol 检测处理回调方法
 */
- (void)propertyURLSchemeParamCallbackAction:(Protocol *)protocol object:(id)object actionBlock:(URLParamMapPropertyCheckBlock)actionBlock;

@end

@interface NSObject (Customizer) <NSObjectEx>

/**
 多参数performSelecor 实现
 
 @param aSelector 方法名
 @param parameters 参数列表
 @return 对应函数返回值
 */
- (id)performSelector:(SEL)aSelector withParameters:(NSArray *)parameters;

/**
 类实例方法替换
 
 @param className 类名
 @param originalSel 原方法
 @param swizzledSel 替换后方法
 */
+ (void)swizzledInstanceMethod:(Class)className originalSelector:(SEL)originalSel swizzledSelector:(SEL)swizzledSel;

/**
 类方法替换
 
 @param className 类名
 @param originalSel 原方法
 @param swizzledSel 替换后方法
 */
+ (void)swizzleClassMethods:(Class)className originalSelector:(SEL)originalSel swizzledSelector:(SEL)swizzledSel;

/**
 *  是否是单例类(默认NO)
 */
+ (BOOL)isSingleton;

/**
 *  是否支持预加载webView(默认YES：支持)
 */
+ (BOOL)isPrestrainWebview;


@end
