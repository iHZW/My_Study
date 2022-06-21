//
//  RestIOManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

/** http请求方式 */
typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethodPOST,
    HttpMethodGET,
    HttpMethodGETProgress,
    HttpMethodHEAD,
    HttpMethodPOSTForm,
    HttpMethodPOSTProgress,
    HttpMethodPOSTFormProgress,
    HttpMethodPUT,
    HttpMethodPATCH,
    HttpMethodDELETE,
};

static NSString * _Nonnull httpMethods[] = {
    [HttpMethodPOST]             = @"POST",
    [HttpMethodGET]              = @"GET",
    [HttpMethodGETProgress]      = @"GET",
    [HttpMethodHEAD]             = @"HEAD",
    [HttpMethodPOSTForm]         = @"POST",
    [HttpMethodPOSTProgress]     = @"POST",
    [HttpMethodPOSTFormProgress] = @"POST",
    [HttpMethodPUT]              = @"PUT",
    [HttpMethodPATCH]            = @"PATCH",
    [HttpMethodDELETE]           = @"DELETE",
};


@interface RestIOManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *manager;

/**
 使用operationQueue最大并发数、返回包体的格式、附加的userAgent信息创建AFHTTPSessionManager
 
 @param maxConncurrentCount operationQueue最大并发数
 @param acceptableContentTypes 返回包体的格式
 @param userAgent 附加的userAgent信息
 @return AFHTTPSessionManager
 */
- (instancetype)initWithData:(NSInteger)maxConncurrentCount
      acceptableContenttypes:(nullable NSSet <NSString *> *)acceptableContentTypes
                   userAgent:(NSString *)userAgent;

/**
 发起一个网络请求NSURLSessionDataTask
 
 @param request 请求地址
 @param sessionManagerSettingBlock 开启NSURLSessionDataTask前，对AFHTTPSessionManager进行自定义操作回调
 @param uploadProgressBlock 上传进度回调
 @param downloadProgressBlock 下载进度回调
 @param completionHandler 请求返回进度回调
 @return 返回当前NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                        sessionManagerSetting:(nullable BOOL (^)(RestIOManager *manager))sessionManagerSettingBlock
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

/**
 使用自定义的UserAgent信息重置HTTP包头UserAgent信息
 
 @param userAgent 用户自定义UserAgent信息
 */
- (void)resetHttpHeaderWithUserAgent:(nullable NSString *)userAgent;

/**
 向当前UserAgent信息中增加自定义信息
 
 @param userAgent 增加自定义的userAgent信息
 */
- (void)appendCustomUserAgent:(nullable NSString *)userAgent;

/**
 取消当前AFHTTPSessionManager所有Task
 */
- (void)cancelAllTask;

/**
 取消当前AFHTTPSessionManager指定的NSURLSessionDataTask
 
 @param eventKey taskKey
 */
- (void)cancelTaskWithKey:(nullable NSString *)eventKey;

/**
 更新安全策略
 
 @param certData 证书设置
 */
- (void)updateSecurityPolicyWithCert:(nullable NSData *)certData;

/**
 更新reponse contentType、请求超时时间以及缓存策略
 
 @param acceptableContentType 返回包体的格式
 @param timeout 超时时间
 @param cachePolicy 缓存策略
 */
- (void)updateSerializerConfig:(nullable NSSet <NSString *> *)acceptableContentType timeout:(NSTimeInterval)timeout cachePolicy:(NSURLRequestCachePolicy)cachePolicy;

/**
 通过给定的用户键值信息设置AFHTTPSessionManager的请求包头信息
 
 @param keymap 包头键值信息
 */
- (void)updateRequestHeaderWithKeymap:(nullable NSDictionary *)keymap;

@end

NS_ASSUME_NONNULL_END
