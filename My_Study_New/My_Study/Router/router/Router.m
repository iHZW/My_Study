//
//  Router.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Router.h"
#import "BaseRouterIntercept.h"

@implementation Router

/**
 *  执行路由
 *
 *  @param routerURL    路由url
 *
 */
- (void)executeURL:(NSString *)routerURL
{
    [self executeURL:routerURL success:^(id _Nonnull objc) {
        NSLog(@"executeURL---success: %@", objc);
    } fail:^(NSError * _Nonnull objc) {
        NSLog(@"executeURL---fail: %@",objc);
    }];
}

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
              fail:(nullable void (^)(NSError *))failBlock
{
    [LogUtil debug:routerURL flag:@"执行路由URL" context:self];
    RouterParam * routerParam = BlockSafeRun(self.routerParseBlock,routerURL);
    if (routerParam){
        [self execute:routerParam success:successBlock fail:failBlock];
    } else {
        NSError *error = [NSError errorWithDomain:@"Router" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"路由解析返回空"}];
        BlockSafeRun(failBlock,error);
    }
}


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
           fail:(nullable void (^)(NSError *))failBlock
{
    if (routerParam.successBlock == nil && successBlock){
        routerParam.successBlock = successBlock;
    }
    
    if (routerParam.failBlock == nil && failBlock){
        routerParam.failBlock = failBlock;
    }
    
//    RACSignal *signal = [RACSignal return:routerParam];
    if (self.interceptors.count > 0){
        for (BaseRouterIntercept *intercept in self.interceptors){
            [intercept doIntercept:routerParam];
        }
    }
    
    BOOL isSuccess = [self _execute:routerParam];
    NSLog(@"isSuccess = %@", @(isSuccess));
    
//    [[signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
//        return [self _execute:value];
//    }] subscribeNext:^(id  _Nullable x) {
//        //Do noting 路由可跳转
//    } error:^(NSError * _Nullable error) {
//        BlockSafeRun(failBlock,error);
//    }];
}

- (BOOL)_execute:(RouterParam *)routerParam{
    BOOL isSuccess = NO;
    if (routerParam == nil){
        return NO;
    }
    
    switch (routerParam.type) {
        case RouterTypeNavigate:
        {
            isSuccess = YES;
            [self.navigateObject navigateTo:routerParam];
        }
            break;
        case RouterTypeNavigatePresent:
        {
            isSuccess = YES;
            [self.navigateObject presentTo:routerParam];
        }
            break;
        case RouterTypeNavigateTab:
        {
            isSuccess = YES;
            [self.navigateObject tabTo:routerParam];
        }
            break;
        case RouterTypeAction:
        {
            isSuccess = YES;
            [self.navigateObject doAction:routerParam];
        }
            break;
        default:
            break;
    }
    return isSuccess;
}

/**
 *  执行路由不需回调
 *
 *  @param routerURL    路由url
 */
- (void)executeURLNoCallBack:(NSString *)routerURL
{
    [self executeURL:routerURL success:nil fail:nil];
}

/**
 *  执行路由
 *
 *  @param routerParam    路由参数
 */
- (void)executeRouterParam:(RouterParam *)routerParam
{
    [self execute:routerParam success:nil fail:nil];
}


@end
