//
//  CacheDataLoader+ZWNIO.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader+ZWNIO.h"
#import "NSObject+UUID.h"
#import "ZWHttpNetworkManager.h"
#import "ZWUserInfoBridgeModule.h"

#define KResponseRestStatus998  998     //998status，登录态异常 token失效
#define KResponseRestStatus997  997     //997status，登录态异常 未检测到token
#define KResponseMacsErrorNo2012 -20121012
#define KTokenInvalidErrorNo  -5000  //登录态失效
#define KJsonModelFailedErrorNo  -6000 //jsonmodel化失败，返回原数据


@implementation CacheDataLoader (ZWNIO)

/**
 *  封装请求，包含检测token失效
 *
 *  @param url               url
 *  @param params            参数
 *  @param method            httpmethod
 *  @param constructingBlock 构建请求
 *  @param completionBlock   拿到的原始数据
 *  @param block 回调
 */
- (void)sendRequest:(NSString *)url
             params:(NSDictionary *)params
         httpMethod:(HttpMethod)method
  constructingBlock:(ZWConstructingBlock)constructingBlock
    completionBlock:(ZWCompletionBlock)completionBlock
      responseBlock:(ResponseLoaderBlock)block
{
    @pas_weakify_self
    NSString *oldToken = [ZWUserInfoBridgeModule tokenId];
    [[ZWHttpNetworkManager sharedHttpManager] sendRequestWithUrl:url msgDict:params httpMethod:method constructingBlock:constructingBlock completionBlock:^(id data, NSError *error) {
        @pas_strongify_self
        if (completionBlock) {
            completionBlock(data,error);
        }
        [[self class] handleCompletionErrorWithData:data error:error block:block oldToken:oldToken url:url chekLoginToken:!self.bolNoCheckLoginToken];
    }];
    
}

- (void)sendRequest:(NSString *)url
             params:(NSDictionary *)params
         httpMethod:(HttpMethod)method
  constructingBlock:(ZWConstructingBlock)constructingBlock
      responseBlock:(ResponseLoaderBlock)block
{
    [self sendRequest:url params:params httpMethod:method constructingBlock:constructingBlock completionBlock:nil responseBlock:block];
}



/**
 * 统一处理返回错误信息
 */
+ (void)handleCompletionErrorWithData:(id)data
                                error:(NSError *)error
                                block:(ResponseLoaderBlock)block
                             oldToken:(NSString *)oldToken
                                  url:(NSString *)url
                       chekLoginToken:(BOOL)checkLoginToken
{
    ZWHttpResponseData *tempData = data;
    if ([tempData isKindOfClass:[ZWHttpResponseData class]]) {
        if ([tempData.status length] && [tempData.status integerValue] != 1) {
            [ZWHttpResponseData BI_restError:url status:tempData.status errmsg:TransToString(tempData.errmsg)];
        } else if([tempData isKindOfClass:[NSDictionary class]]) {
            NSString *status = [DataFormatterFunc strValueForKey:@"status" ofDict:(NSDictionary *)tempData];
            NSString *errmsg = [DataFormatterFunc strValueForKey:@"errmsg" ofDict:(NSDictionary *)tempData];
            if (status.length && [status integerValue] != 1) {
                [ZWHttpResponseData BI_restError:url status:status errmsg:errmsg];
            }
        }
    }
    
    if (error) {
        tempData = [ZWHttpResponseData getErrorResponseData:error];
    }
    
    if ([tempData isKindOfClass:[ZWHttpResponseData class]] && block) {
        if ((KResponseRestStatus997 == [tempData.status integerValue]
             || [tempData.status integerValue] == KResponseRestStatus998
             || KResponseMacsErrorNo2012 == [tempData.status integerValue] ) && checkLoginToken) {
            block(KTokenInvalidErrorNo,nil);
            /* 检测登录态 */
//            if ([PASLoginManager checkTokenInvalidAuth:[tempData.status integerValue] oldToken:oldToken auth:tempData.actionAuth bolGoLogin:NO url:url responseBlock:block]) {
//                return ;
//            }
        }
        NSInteger status = ValidString(tempData.status) ? [tempData.status integerValue] : (tempData.errcode == 0 ? 1 : 0);
        block(status,tempData);
    } else if (block) {
        block(KJsonModelFailedErrorNo,data);
    }
}

@end
