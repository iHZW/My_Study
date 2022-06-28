//
//  Router.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouterLifeCycleDelegate.h"
#import "RouterNavigateDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef RouterParam *_Nullable (^RouterParseblock) (NSString *routerURL);

@interface Router : NSObject
/** 回调返回  RouterParam  */
@property (nonatomic, copy) RouterParseblock routerParseBlock;
/** 生命周期代理 RouterLifeCycleDelegate  */
@property (nonatomic, strong) id<RouterLifeCycleDelegate> delegate;
/** 路由跳转代理  */
@property (nonatomic, strong) id<RouterNavigateDelegate> navigateObject;
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
