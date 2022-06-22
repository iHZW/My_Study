//
//  CacheDataLoader+ZWNIO.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader.h"
#import "ZWHttpResponseData.h"
#import "RestIOManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface CacheDataLoader (ZWNIO)

/**
 *  封装请求，包含检测token失效
 *
 *  @param url               url
 *  @param params            参数
 *  @param method            httpmethod
 *  @param constructingBlock 构建请求
 *  @param block             返回回调
 */
- (void)sendRequest:(NSString *)url
             params:(NSDictionary *)params
         httpMethod:(HttpMethod)method
  constructingBlock:(ZWConstructingBlock)constructingBlock
      responseBlock:(ResponseLoaderBlock)block;


/**
 统一处理返回错误信息
 */
+ (void)handleCompletionErrorWithData:(id)data
                                error:(NSError *)error
                                block:(ResponseLoaderBlock)block
                             oldToken:(NSString *)oldToken
                                  url:(NSString *)url
                       chekLoginToken:(BOOL)checkLoginToken;

@end

NS_ASSUME_NONNULL_END
