//
//  ZWHttpNetworkManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWHttpEventInfo.h"
#import "RestIOManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 API调用限制回调
 
 @param apiName api
 @return YES:api限制 否则NO
 */
typedef BOOL (^CheckTrafficBlock)(NSString *apiName, NSError **error);

/**
 HTTPS证书校验检测Block回调
 
 @return YES:HTTPS证书校验检测处理 否则NO
 */
typedef BOOL (^HttpsCertCheckBlock)(void);


@interface ZWHttpNetworkManager : NSObject
/**
 *  AFSSLPinningModeCertificate 使用证书验证模式相关设置域名与证书对应关系
 */
@property (nonatomic, strong) NSDictionary *httpsCertConfigDic;

/**
 *  流量统计
 */
@property (nonatomic, assign) NSUInteger trafficStatistics;

/**
 API调用限制回调
 */
@property (nonatomic, copy) CheckTrafficBlock trafficAction;

/**
 HTTPS证书校验检测Block回调
 */
@property (nonatomic, copy) HttpsCertCheckBlock httpsCertCheckAction;

@property (nonatomic, strong) NSString *userAgent;

#pragma mark -- 初始化

/**
 *  获取单例
 */
+ (instancetype)sharedHttpManager;

/**
 初始化处理
 
 @param userAgentInfo userAgentIfo信息
 @return ZWHttpNetworkManager 对象
 */
- (instancetype)initWihtCustomUserAgentInfo:(NSString *)userAgentInfo;

/**
 *  数据初始化
 */
- (void)initializeData;

#pragma mark -- 发送请求的方法

/**
 *  通过自建requestEvent发送请求
 *
 *  @param requestEvent    请求的eventinfo
 *  @param completionBlock 联网回调
 *
 *  @return 本次请求的task，可以用于取消联网(如果不存在，返回nil)
 */
- (NSURLSessionDataTask *)sendRequest:(ZWHttpEventInfo *)requestEvent completionBlock:(ZWCompletionBlock)completionBlock;

/**
 *  创建默认的requestEvent用于发送请求，可以传入快捷参数，通过constructingBlock可以修改
 *
 *  @param url               请求完整的url
 *  @param msgDict           post对应的参数
 *  @param httpMethod        httpMethod
 *  @param constructingBlock 抛出默认创建的requestEvent，用于修改参数
 *  @param completionBlock   联网回调
 *
 *  @return 本次请求的task，可以用于取消联网(如果不存在，返回nil)
 */
- (NSURLSessionDataTask *)sendRequestWithUrl:(NSString *)url
                                     msgDict:(NSDictionary *)msgDict
                                  httpMethod:(HttpMethod)httpMethod
                           constructingBlock:(ZWConstructingBlock)constructingBlock
              completionWithURLResponseBlock:(ZWCompletionWithResponseBlock)completionBlock;

/**
 *  创建默认的requestEvent用于发送请求，可以传入快捷参数，通过constructingBlock可以修改
 *
 *  @param url               请求完整的url
 *  @param msgDict           post对应的参数
 *  @param httpMethod        httpMethod
 *  @param constructingBlock 抛出默认创建的requestEvent，用于修改参数
 *  @param completionBlock   联网回调
 *
 *  @return 本次请求的task，可以用于取消联网(如果不存在，返回nil)
 */
- (NSURLSessionDataTask *)sendRequestWithUrl:(NSString *)url
                                     msgDict:(NSDictionary * _Nullable)msgDict
                                  httpMethod:(HttpMethod)httpMethod
                           constructingBlock:(ZWConstructingBlock)constructingBlock
                             completionBlock:(ZWCompletionBlock)completionBlock;


- (NSURLSessionDataTask *)sendRequestWithFuncId:(NSInteger)funcId
                                      subFuncId:(NSInteger)subFuncId
                                        msgDict:(NSDictionary *)msgDict
                                     httpMethod:(HttpMethod)httpMethod
                              constructingBlock:(ZWConstructingBlock)constructingBlock
                 completionWithURLResponseBlock:(ZWCompletionWithResponseBlock)completionBlock;


/**
 *  通过功能号获取对应url，同时创建默认的requestEvent用于发送请求，可以传入快捷参数，通过constructingBlock可以修改
 *  需要对应的功能编号和url对应表（暂未使用）
 *
 *  @param funcId            功能号
 *  @param subFuncId         子功能号
 *  @param msgDict           post对应的参数
 *  @param httpMethod        httpMethod
 *  @param constructingBlock 抛出默认创建的requestEvent，用于修改参数
 *  @param completionBlock   联网回调
 *
 *  @return 本次请求的task，可以用于取消联网(如果不存在，返回nil)
 */
- (NSURLSessionDataTask *)sendRequestWithFuncId:(NSInteger)funcId
                                      subFuncId:(NSInteger)subFuncId
                                        msgDict:(NSDictionary *)msgDict
                                     httpMethod:(HttpMethod)httpMethod
                              constructingBlock:(ZWConstructingBlock)constructingBlock
                                completionBlock:(ZWCompletionBlock)completionBlock;

#pragma mark -- 取消网络相关

/** 取消当前队列里面所有请求 */
-(void)cancelAllTask;

/** 根据key取消对应的请求 */
-(void)cancelTaskWithKey:(NSString *)eventKey;

+ (HttpMethod)transHttpMethodToIndex:(NSString *)methodStr;

/** 根据header参数重置h5通道的RequestSerializer */
- (void)resetH5RequestSerializerWithHeaderParam:(NSDictionary *)headerDict;

//6.12 二进制通道添加特殊header后还原
- (void)resetBHttpRequestHead;
// 针对二进制通道添加特殊header  同花顺接口需要  比方 httpRequest.addHeader("Referer", "native-ios");
- (void)addSpecialHeader:(NSDictionary *)headDict;

@end

NS_ASSUME_NONNULL_END
