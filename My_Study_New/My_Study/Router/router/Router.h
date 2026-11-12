//
//  Router.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterParam.h"
#import "RouterPageItem.h"
#import "RouterLifeCycleDelegate.h"
#import "RouterNavigateDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef RouterParam *_Nullable (^RouterParseblock) (NSString *routerURL);

typedef NS_ENUM(NSInteger, RouterErrorCode) {
    RouterErrorInvalidRequest = 1,
    RouterErrorNotRegistered,
    RouterErrorIntercepted,
    RouterErrorUnavailable,
    RouterErrorNavigationBusy
};

@interface Router : NSObject
/// 诊断观察器，仅接收事件与字段，不参与跳转决策。
@property (nonatomic, copy, nullable) void (^eventLogger)(NSString *event, NSDictionary *fields);
- (void)recordEvent:(NSString *)event request:(nullable RouterParam *)request details:(nullable NSDictionary *)details;
/// 注册时建立索引；重复路径直接返回错误，不覆盖已有注册。
- (BOOL)registerPages:(NSArray<RouterPageItem *> *)pages error:(NSError * _Nullable * _Nullable)error;
- (nullable RouterPageItem *)pageForPath:(NSString *)path;
- (nullable RouterPageItem *)pageForClassName:(NSString *)className;
- (nullable RouterParam *)resolveURL:(NSString *)url;
/// App 内统一入口，参数无需先转成 JSON 或 URL。
- (void)openPath:(NSString *)path parameters:(nullable NSDictionary *)parameters
        context:(nullable id)context success:(nullable RouterSuccessBlock)success
        failure:(nullable RouterFailBlock)failure;
+ (NSDictionary *)decodeRoute:(NSString *)route;
+ (NSString *)encodeRoute:(NSString *)path parameters:(nullable NSDictionary *)parameters;
+ (NSError *)errorWithCode:(RouterErrorCode)code message:(NSString *)message;
/** 回调返回  RouterParam  */
@property (nonatomic, copy) RouterParseblock routerParseBlock;
/** 生命周期代理 RouterLifeCycleDelegate  */
@property (nonatomic, strong) id<RouterLifeCycleDelegate> delegate;
/** 路由跳转代理  */
@property (nonatomic, strong, nullable) id<RouterNavigateDelegate> navigateObject;
/** 路由配置信息  */
@property (nonatomic, copy) NSArray *routerConfigs;
/** 需要拦截的路由配置,  从接口返回  */
@property (nonatomic, copy) NSArray *interceptRoute;
/** 拦截器  */
@property (nonatomic, copy) NSArray *interceptors;

/**
 *  执行路由
 *
 *  @param routerURL    路由url
 *
 */
- (void)executeURL:(NSString *)routerURL;

/**
 *  业务成功之后的回调，successBlock 不再作为路由执行成功的回调
 *
 *  @param routerURL   路由url
 *  @param successBlock    成功回调
 *  @param failBlock 失败回调
 *
 */
- (void)executeURL:(NSString *)routerURL
           success:(nullable void (^)(id))successBlock
              fail:(nullable void (^)(NSError *))failBlock;


/**
 *  业务成功之后的回调，successBlock 不再作为路由执行成功的回调
 *
 *  @param routerParam    路由参数
 *  @param successBlock    成功回调
 *  @param failBlock 失败回调
 *
 */
- (void)execute:(RouterParam *)routerParam
        success:(nullable void (^)(id))successBlock
           fail:(nullable void (^)(NSError *))failBlock;

/**
 *  执行路由不需回调
 *
 *  @param routerURL    路由url
 */
- (void)executeURLNoCallBack:(NSString *)routerURL;

/**
 *  执行路由
 *
 *  @param routerParam    路由参数
 */
- (void)executeRouterParam:(RouterParam *)routerParam;

@end

NS_ASSUME_NONNULL_END
