//
//  HttpClient.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/18.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger,HttpRequestType) {
     HttpRequestGet = 0,
     HttpRequestPost,
     HttpRequestPut,
     HttpRequestDelete,
};

/*
 * 请求前预处理block
 */
typedef void(^PrepareExecuteBlock)(void);

typedef void(^HttpSuccessBlock)(NSURLSessionDataTask *_Nullable task, id _Nullable responseObject);

typedef void(^HttpFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface HttpClient : NSObject

@property (nonatomic, copy) HttpSuccessBlock httpSuccessBlock;

@property (nonatomic, copy) HttpFailureBlock httpFailureBlock;

+ (HttpClient *)defaultClient;


/**
 *  HTTP请求（GET,POST,PUT,DELETE）
 *
 *  @param url     请求地址
 *  @param method  请求类型
 *  @param params  请求参数
 *  @param prepare 请求前预处理
 *  @param success 请求成功处理
 *  @param failure 请求失败处理
 */
- (void)requestWithPath:(NSString *)url
                 method:(HttpRequestType)method
            paramenters:(NSDictionary *)params
         prepareExecute:(PrepareExecuteBlock)prepare
                success:(HttpSuccessBlock)success
                failure:(HttpFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
