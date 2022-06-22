//
//  ZWHttpNetworkManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWHttpNetworkManager.h"
#import "ZWHttpResponseData.h"
#import "UIKit+AFNetworking.h"
#import <objc/message.h>
#import "NSObject+UUID.h"
#import "ZWDataParsing.h"
#import "ZWDataCache.h"
#import "MJExtension.h"
#import "NSString+URLEncode.h"

//#import "LoadingUtil.h"

#import "ZWSDK.h"
#import "LogUtil.h"
#import "LoadingUtil.h"
//#import "CMLogManagement.h"
#import "GCDCommon.h"
#import "DataFormatter.h"
//#import "PASNavigator.h"

#include <sys/time.h>

static inline int64_t ZWGetSystemMilTime(void)
{
    struct timeval tv;
    //获取一个时间结构
    
    gettimeofday(&tv, NULL);
    int64_t t = tv.tv_sec * 1000 + tv.tv_usec / 1000;
    return t;
}



#pragma mark - TestJsonModel
@interface TestJsonModel : ZWHttpResponseData

@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *alevel;
@property (nonatomic, strong) NSString *lat;

@end

@implementation TestJsonModel

@end


#pragma mark - ZWHttpNetworkManager

@interface ZWHttpNetworkManager ()

@property (nonatomic, strong) RestIOManager *httpManager; // 用于json的请求,非json的每次new，非域名认证通道
@property (nonatomic, strong) RestIOManager *binaryHttpManager; // 用于非json的请求,返回源数据
@property (nonatomic, strong) RestIOManager *h5HttpManager; // h5通道
@property (nonatomic, strong) RestIOManager *httpStockManager; // 用于json的请求,非json的每次new,stock域名认证通道
@property (nonatomic, strong) RestIOManager *httpMStockManager; // 用于json的请求,非json的每次new,mstock域名认证通道
@property (nonatomic, strong) RestIOManager *httpCDNStockManager; // 用于json的请求,非json的每次new,CDNstock域名认证通道

@property (nonatomic, strong) NSURLCache *httpNetworkCache;

@end

@implementation ZWHttpNetworkManager

- (void)testZWNetwork
{
    NSString *testUrl = @"http://10.25.27.90:30074/frontend_medias/mobile/pazq/home/AppMainConf_test.json";
    [self sendRequestWithUrl:@"http://gc.ditu.aliyun.com/geocoding"
                     msgDict:@{@"a" : @"上海市"}
                  httpMethod:HttpMethodPOST
           constructingBlock:^(ZWHttpEventInfo *eventInfo) {
               eventInfo.responseClass = [TestJsonModel class];
               eventInfo.isUsingSelfCache = YES;
               //               eventInfo.requstEventKey = @"TestCache";
           } completionBlock:^(ZWHttpResponseData *responseData, NSError *error) {
               NSLog(@"responseData = %@", responseData);
           }];
    
    testUrl = @"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png";
    [self sendRequestWithUrl:testUrl
                     msgDict:nil
                  httpMethod:HttpMethodGET
           constructingBlock:^(ZWHttpEventInfo *eventInfo) {
               eventInfo.parseType = DataParseTypeData;
           } completionBlock:^(id responseData, NSError *error) {
               UIImage *image = [UIImage imageWithData:responseData];
               NSLog(@"image = %@", image);
           }];
    
    testUrl = @"http://open.eastmoney.com/data/API/PingAnInfo/EMSelfSelectInfoNews?callbackname=callbackfun&secucodes=600004.SH&count=20";
    [self sendRequestWithUrl:testUrl
                     msgDict:nil
                  httpMethod:HttpMethodGET
           constructingBlock:^(ZWHttpEventInfo *eventInfo) {
               //               eventInfo.acceptableContentType = @"text/html, text/plain";
               eventInfo.parseType = DataParseTypeData;
           } completionBlock:^(id responseData, NSError *error) {
               //               NSLog(@"responseData = %@", responseData);
           }];
}


+ (NSString *)certNameWithHost:(NSURL *)url
{
    NSString *certName = nil;
    
    if ([ZWHttpNetworkManager sharedHttpManager].httpsCertConfigDic && [[url.absoluteString lowercaseString] hasPrefix:@"https:/"]){
        certName = [ZWHttpNetworkManager sharedHttpManager].httpsCertConfigDic[url.host];
        
        //6.0添加新开关，如果有问题，走默认证书  只有https才校验
        BOOL bRet = [ZWHttpNetworkManager sharedHttpManager].httpsCertCheckAction ? [ZWHttpNetworkManager sharedHttpManager].httpsCertCheckAction() : NO;
        if (!bRet) {
            return @"";
        }
    }
    
    return certName;
}

+ (void)initialize
{
    //在networkmo中统一管理
    //    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (instancetype)sharedHttpManager
{
    static ZWHttpNetworkManager *httpNetworkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpNetworkManager = [[ZWHttpNetworkManager alloc] init];
    });
    return httpNetworkManager;
}

- (void)initializeData
{
    //调大http每个端口默认的并发session
    [NSURLSessionConfiguration defaultSessionConfiguration].HTTPMaximumConnectionsPerHost = 6;
    
    NSSet <NSString *> *contentType = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    self.httpManager = [[RestIOManager alloc] initWithData:10 acceptableContenttypes:contentType userAgent:self.userAgent];
    
    self.httpStockManager = [[RestIOManager alloc] initWithData:10 acceptableContenttypes:contentType userAgent:self.userAgent];
    
    self.httpMStockManager = [[RestIOManager alloc] initWithData:10 acceptableContenttypes:contentType userAgent:self.userAgent];
    
    self.httpCDNStockManager = [[RestIOManager alloc] initWithData:6 acceptableContenttypes:contentType userAgent:self.userAgent];
    
    self.binaryHttpManager = [[RestIOManager alloc] initWithData:6 acceptableContenttypes:nil userAgent:self.userAgent];
    self.binaryHttpManager.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    self.h5HttpManager = [[RestIOManager alloc] initWithData:10 acceptableContenttypes:contentType userAgent:self.userAgent];
    
    self.httpsCertConfigDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HttpsCertConfig" ofType:@"plist"]];
    
    // 开启网络指示和网络状态监控
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:NO];
    
    [self openNetMonitoring];
}


/* 开启网络状态监听 */
- (void)openNetMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *network = [NSString stringWithFormat:@"Network status change to %@", @(status)];
        [LogUtil debug:network flag:@"监控网络变化" context:self];
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                self.isConnect = NO;
//                break;
//
//            case AFNetworkReachabilityStatusNotReachable:
//                self.isConnect = NO;
//                break;
//
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                self.isConnect = YES;
//                break;
//
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//
//                break;
//
//            default:
//                break;
//        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


// 监控网络变化情况
- (void)monitoringNetworkStatus
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *network = [NSString stringWithFormat:@"Network status change to %@", @(status)];
        [LogUtil debug:network flag:@"监控网络变化" context:self];
    }];
}

#pragma mark -- 发送请求的方法

- (NSURLSessionDataTask *)sendRequest:(ZWHttpEventInfo *)requestEvent completionBlock:(ZWCompletionBlock)completionBlock
{
    NSURLSessionDataTask *task  =
    [self sendHttpRequest:requestEvent completionBlock:^(id responseData, NSError *error, NSURLResponse *response) {
        if (completionBlock) {
            completionBlock(responseData, error);
        }
    }];
    return task;
}

- (NSURLSessionDataTask *)sendRequestWithUrl:(NSString *)url
                                     msgDict:(NSDictionary *)msgDict
                                  httpMethod:(HttpMethod)httpMethod
                           constructingBlock:(ZWConstructingBlock)constructingBlock
              completionWithURLResponseBlock:(ZWCompletionWithResponseBlock)completionBlock
{
    ZWHttpEventInfo *requestEvent = [[ZWHttpEventInfo alloc] init];
    requestEvent.relativePath = url;
    requestEvent.httpMethod = httpMethod;
    if (msgDict)
        requestEvent.parameters = [NSDictionary dictionaryWithDictionary:msgDict];
    
    if (constructingBlock)
        constructingBlock(requestEvent);
    
    return [self sendHttpRequest:requestEvent completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)sendRequestWithUrl:(NSString *)url
                                     msgDict:(NSDictionary *)msgDict
                                  httpMethod:(HttpMethod)httpMethod
                           constructingBlock:(ZWConstructingBlock)constructingBlock
                             completionBlock:(ZWCompletionBlock)completionBlock
{
    
    NSURLSessionDataTask *task  =
    [self sendRequestWithUrl:url msgDict:msgDict httpMethod:httpMethod constructingBlock:constructingBlock completionWithURLResponseBlock:^(id responseData, NSError *error, NSURLResponse *response) {
        if (completionBlock) {
            completionBlock(responseData, error);
        }
    }];
    return task;
}

- (NSURLSessionDataTask *)sendRequestWithFuncId:(NSInteger)funcId
                                      subFuncId:(NSInteger)subFuncId
                                        msgDict:(NSDictionary *)msgDict
                                     httpMethod:(HttpMethod)httpMethod
                              constructingBlock:(ZWConstructingBlock)constructingBlock
                 completionWithURLResponseBlock:(ZWCompletionWithResponseBlock)completionBlock
{
    ZWHttpEventInfo *requestEvent = [[ZWHttpEventInfo alloc] init];
    //    requestEvent.relativePath = url;
    requestEvent.httpMethod = httpMethod;
    if (msgDict)
        requestEvent.parameters = [NSDictionary dictionaryWithDictionary:msgDict];
    
    if (constructingBlock)
        constructingBlock(requestEvent);
    
    return [self sendHttpRequest:requestEvent completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)sendRequestWithFuncId:(NSInteger)funcId
                                      subFuncId:(NSInteger)subFuncId
                                        msgDict:(NSDictionary *)msgDict
                                     httpMethod:(HttpMethod)httpMethod
                              constructingBlock:(ZWConstructingBlock)constructingBlock
                                completionBlock:(ZWCompletionBlock)completionBlock

{
    
    NSURLSessionDataTask *task  =
    [self sendRequestWithFuncId:funcId subFuncId:subFuncId msgDict:msgDict httpMethod:httpMethod constructingBlock:constructingBlock completionWithURLResponseBlock:^(id responseData, NSError *error, NSURLResponse *response) {
        if (completionBlock) {
            completionBlock(responseData, error);
        }
    }];
    return task;
}

#pragma mark -- private

- (RestIOManager *)getNeedHttpManage:(ZWHttpEventInfo *)requestEvent
{
    RestIOManager *manager = nil;
    // 如果请求的json数据，并且不修改acceptableContentType，直接使用httpManager，
    // 否则设置成新的httpManager，保证数据解析失败时可以返回原始二进制数据
    if (HttpChannelTypeH5 == requestEvent.httpChannelType) {
        manager = self.h5HttpManager;
    } else {
        if (requestEvent.parseType == DataParseTypeJSON && requestEvent.acceptableContentType.length == 0) {
            NSString *requestUrl = [NSString stringWithFormat:@"%@%@",requestEvent.hostName ?:@"", requestEvent.relativePath ?:@""];
//            NSURL *url = [NSURL URLWithString:[requestUrl  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURL *url = [NSURL URLWithString:[requestUrl URLEncodedString]];

            [NSString availableStringEncodings];
            NSString *httpsCer = [ZWHttpNetworkManager certNameWithHost:url];
            
            if ([httpsCer containsString:@"ZWtockCert"]) {
                manager = self.httpStockManager;
            } else if ([httpsCer containsString:@"ZWMStockCert"]) {
                manager = self.httpMStockManager;
            } else if ([httpsCer containsString:@"ZWStgStockCert"]) { //cdn域名认证改为stg测试环境
                manager = self.httpCDNStockManager;
            }  else {
                manager = self.httpManager;
            }
            
        } else {
            manager = self.binaryHttpManager;
        }
    }
    
    return manager;
    
    ////    鉴于AFN ARC模式下 AFHTTPSessionManager 每次创建时会出现mem leak, 所以需使用同一的 AFHTTPSessionManager
    //    return self.httpManager;
}

- (void)httpResponseAction:(ZWHttpEventInfo *)requestEvent
            responseObject:(id)responseObject
                     error:(NSError *)error
               urlResponse:(NSURLResponse *)response
           completionBlock:(ZWCompletionWithResponseBlock)completionBlock
{
    // 请求返回时间标记
    requestEvent.responseTime = ZWGetSystemMilTime();
    
    if (error) {
        // 如果有错误也返回responseObject，保证解析有问题时返回二进制数据
        [self handlerFinishBlock:completionBlock responseData:responseObject error:error urlResponse:response];
    } else {
        // 自动解析,解析失败会直接返回原对象
        [ZWDataParsing parseResponseData:responseObject requestEventInfo:requestEvent parsedCompletionBlock:^(id parsedData, NSError *error)
         {
             [self handlerFinishBlock:completionBlock responseData:parsedData error:nil urlResponse:response];
         }];
    }
    
    // 如果没有错误，根据配置保存数据到缓存
    if (!error && requestEvent.isUsingSelfCache) {
        [self cacheResponseData:responseObject requestEvent:requestEvent];
    }
    
    // 接收数据结束后先调此方法
    [self endReceiveDataRequestTask:requestEvent];
}

- (NSURLSessionDataTask *)sendHttpRequest:(ZWHttpEventInfo *)requestEvent completionBlock:(ZWCompletionWithResponseBlock)completionBlock
{
    RestIOManager *httpManager = [self getNeedHttpManage:requestEvent];
    
    // 如果需要缓存，先处理缓存数据,再根据设置判断是否需要继续请求
    if (requestEvent.isUsingSelfCache) {
        BOOL isExistCache = [self handleResponseDataFormSelfCache:requestEvent completionBlock:completionBlock];
        if (isExistCache && (requestEvent.returnCachePolicy == HttpReturnCacheDataDontLoad||HttpReturnCacheDataOnlyCache == requestEvent.returnCachePolicy)) {
            return nil;
        }
        
        //处理缓存不存在，且不加载网络的情况
        if (!isExistCache && HttpReturnCacheDataOnlyCache == requestEvent.returnCachePolicy) {
            [self handlerFinishBlock:completionBlock responseData:nil error:nil urlResponse:nil];
            return nil;
        }
    }
    
    // 无网络的情况直接返回error
    if (![httpManager.manager.reachabilityManager isReachable]
        && httpManager.manager.reachabilityManager.networkReachabilityStatus != AFNetworkReachabilityStatusUnknown) {
        NSError *error = [NSError errorWithDomain:@"NSURLErrorNotConnectedToInternet" code:NSURLErrorNotConnectedToInternet userInfo:nil];
        [self handlerFinishBlock:completionBlock responseData:nil error:error urlResponse:nil];
        return nil;
    }
    
    // 构建NSMutableURLRequest
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self generateURLRequest:requestEvent httpManager:httpManager.manager serializationError:&serializationError];
    
    // 如果解析request失败，直接回调错误信息
    if (serializationError) {
        [self handlerFinishBlock:completionBlock responseData:nil error:serializationError urlResponse:nil];
        return nil;
    }
    
    // 请求发起时间标记
    requestEvent.requestTime = ZWGetSystemMilTime();
    
    // 发送和接收请求
    
    @pas_weakify_self
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [httpManager dataTaskWithRequest:request
                          sessionManagerSetting:^BOOL(RestIOManager * _Nonnull manager) {
                              @pas_strongify_self
                              // 修改Serializer配置
                              [self setupSerializerConfig:requestEvent manager:manager];
                              
                              // 发送请求之前操作
                              [self prepareSendDataRequestTask:requestEvent];
                              
                              NSData *certData = nil;
                              
                              if (manager != self.binaryHttpManager) { // AFSSLPinningModeCertificate 使用证书验证模式相关设置
                                  // 先导入证书，找到证书的路径
                                  NSString *cerPath = [[NSBundle mainBundle] pathForResource:[ZWHttpNetworkManager certNameWithHost:request.URL] ofType:nil];
                                  certData  = [NSData dataWithContentsOfFile:cerPath];
                              }
                              
                              [manager updateSecurityPolicyWithCert:certData];
                              
                              // 降级开关判断
                              NSError *error = nil;
                              BOOL bCheck = self.trafficAction ? self.trafficAction(request.URL.path, &error) : NO;
                              if (bCheck) {
                                  [self handlerFinishBlock:completionBlock responseData:nil error:error urlResponse:nil];
                                  return NO;
                              }
                              
                              return YES;
                          }
                                 uploadProgress:requestEvent.uploadProgressBlock
                               downloadProgress:requestEvent.downloadProgressBlock
                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                  @pas_strongify_self
                                  self.trafficStatistics += dataTask.countOfBytesSent + dataTask.countOfBytesReceived;
                                  [self httpResponseAction:requestEvent responseObject:responseObject error:error urlResponse:response completionBlock:completionBlock];
                                  NSString *url = [NSString stringWithFormat:@"url = %@", response.URL.absoluteString];
                                  NSString *msg = [NSString stringWithFormat:@"responseObject = %@", responseObject];
                                  [LogUtil debug:msg flag:url context:self];
//                                  CMLogDebug(LogBusinessPublicService, @"url = %@",response.URL.absoluteString);
//                                  CMLogDebug(LogBusinessPublicService, @"responseObject = %@",responseObject);
                                  
                              }];
    
    // 设置task的key，用于cache或者cancel
    if ([requestEvent.requstEventKey length] > 0) {
        dataTask.uuidTag = requestEvent.requstEventKey;
    }
    
    return dataTask;
}

#pragma mark -- setup request Config

// 修改Serializer配置
- (void)setupSerializerConfig:(ZWHttpEventInfo *)requestEvent manager:(RestIOManager *)manager
{
    NSSet<NSString *> *contentType = nil;
    // 根据需要设置ContentType,针对不是json时重新生成的Serializer赋值
    if (requestEvent.acceptableContentType.length > 0 && requestEvent.parseType != DataParseTypeJSON) {
        contentType = [NSSet setWithObjects:requestEvent.acceptableContentType, nil];
    }
    
    [manager updateSerializerConfig:contentType timeout:requestEvent.timeoutInterval cachePolicy:requestEvent.cachePolicy];
}

// 构建NSMutableURLRequest
- (NSMutableURLRequest *)generateURLRequest:(ZWHttpEventInfo *)requestEvent
                                httpManager:(AFHTTPSessionManager *)httpManager
                         serializationError:(NSError **)error
{
    // 拼接url
    NSString *url = [NSString stringWithFormat:@"%@%@",requestEvent.hostName ?:@"", requestEvent.relativePath ?:@""];
//    NSString *requestUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestUrl = [url urlNewEncodeString];

    // 根据设置生成request
    NSString *method = httpMethods[requestEvent.httpMethod];
    NSMutableURLRequest *request = nil;
    
    // 如果有需要form，则调用post的multipartFormRequestWithMethod方法
    if (requestEvent.afFormDataBlock && (requestEvent.httpMethod == HttpMethodPOSTForm || requestEvent.httpMethod == HttpMethodPOSTFormProgress)) {
        request = [httpManager.requestSerializer multipartFormRequestWithMethod:method URLString:requestUrl parameters:requestEvent.parameters constructingBodyWithBlock:requestEvent.afFormDataBlock error:error];
    } else {
        request = [httpManager.requestSerializer requestWithMethod:method URLString:requestUrl parameters:requestEvent.parameters error:error];
    }
    
    return request;
}

# pragma mark -- handle data cache

// 如果设置了缓存，先获取缓存数据
- (BOOL)handleResponseDataFormSelfCache:(ZWHttpEventInfo *)requestEvent completionBlock:(ZWCompletionWithResponseBlock)completionBlock
{
    NSData *cacheData = nil;
    if (requestEvent.absoluteCachePath) {
        cacheData = [[ZWDataCache sharedZWDataCache] objectFromCacheWithPath:requestEvent.absoluteCachePath];
    } else if (requestEvent.requstEventKey) {
        cacheData = [[ZWDataCache sharedZWDataCache] objectFromCacheWithKey:requestEvent.requstEventKey];
    }
    
    if (cacheData) // 如果获取到了缓存数据，返回YES，然后返回解析后的对象或者data
    {
        @pas_weakify_self;
        [ZWDataParsing parseResponseData:cacheData requestEventInfo:requestEvent parsedCompletionBlock:^(id parsedData, NSError *error)
         {
             @pas_strongify_self;
             [self handlerFinishBlock:completionBlock responseData:parsedData error:nil urlResponse:nil];
         }];
        return YES;
    }
    return NO;
}

// 根据缓存策略，缓存返回数据
- (void)cacheResponseData:(id)responseData requestEvent:(ZWHttpEventInfo *)requestEvent
{
    //如果bolcachekey存在，那么做bolcachekey检测
    if ([requestEvent.bolCacheKey length]) {
        id cacheValue = [responseData valueForKey:requestEvent.bolCacheKey];
        //cachevalue不存在或者存在但和预设值不同，都不缓存
        if (!cacheValue || cacheValue == [NSNull null] || (requestEvent.bolCacheValue && ![requestEvent.bolCacheValue isEqual:cacheValue])) {
            return;
        }
    }
    //缓存数据block
    void (^toCacheBlock)(id) = ^(id rspDict){
        NSData *cacheData = [rspDict mj_JSONData];
        // 优先处理指定绝对路径的情况
        if (requestEvent.absoluteCachePath) {
            [[ZWDataCache sharedZWDataCache] saveData:cacheData toCacheWithPath:requestEvent.absoluteCachePath];
        } else if (requestEvent.requstEventKey) {
            [[ZWDataCache sharedZWDataCache] saveObject:cacheData toCacheWithKey:requestEvent.requstEventKey];
        }
    };
    //组合请求更新cache
    if (requestEvent.groupCacheUpdateMapDict && requestEvent.groupCacheUpdateMapDict.allKeys.count > 0 && [responseData isKindOfClass:NSDictionary.class]) {
        
        NSData *oldCacheData = nil;
        if (requestEvent.absoluteCachePath) {
            oldCacheData = [[ZWDataCache sharedZWDataCache] objectFromCacheWithPath:requestEvent.absoluteCachePath];
        } else if (requestEvent.requstEventKey) {
            oldCacheData = [[ZWDataCache sharedZWDataCache] objectFromCacheWithKey:requestEvent.requstEventKey];
        }
        
        if (!oldCacheData) { //没有缓存直接缓存
            toCacheBlock(responseData);
            return;
        }
        
        NSMutableDictionary *oldRspDict = [NSMutableDictionary dictionaryWithDictionary:[DataFormatterFunc validDictionaryValue:[oldCacheData mj_JSONObject]]];
        
        BOOL bolNeedUpdateCache = NO;
        for (NSString *updatePath in requestEvent.groupCacheUpdateMapDict.allKeys) { //查找是否需要更新
            NSArray *updatePathArr = [updatePath componentsSeparatedByString:@"."];//查找返回的数据中是否存在这个路径
            NSDictionary *tempDict = responseData;
            for (NSInteger i = 0;i < updatePathArr.count ; i ++) {
                NSString *pathStr = [updatePathArr objectAtIndex:i];
                if ([tempDict isKindOfClass:NSDictionary.class]) {
                    tempDict = [self getJsonDictFromObjcet:[tempDict objectForKey:pathStr]];
                } else {
                    tempDict = nil;
                }
                
                if (i == updatePathArr.count - 1 && tempDict) {//有更新，遍历value路径找到需要更新的内容，替换旧cache
                    bolNeedUpdateCache = YES;
                    
                    NSString *updateValuePath = [requestEvent.groupCacheUpdateMapDict objectForKey:updatePath];
                    NSArray *updateValuePathArr = [updateValuePath componentsSeparatedByString:@"."];
                    NSDictionary *updateNewDict = responseData;
                    NSMutableDictionary *needUpdateDict = oldRspDict;
                    
                    for (NSInteger j = 0; j < updateValuePathArr.count; j++) {
                        NSString *pathValueStr = [updateValuePathArr objectAtIndex:j];
                        updateNewDict = [updateNewDict objectForKey:pathValueStr];
                        
                        if (j == updateValuePathArr.count - 1) {//最后一层更新缓存内容
                            if (updateNewDict) {
                                [needUpdateDict setObject:updateNewDict forKey:pathValueStr];
                            }
                            break;
                        }
                        
                        if ([updateNewDict isKindOfClass:NSArray.class]) {
                            updateNewDict = [(NSArray *)updateNewDict firstObject];
                            
                            if (![updateNewDict isKindOfClass:NSDictionary.class]) {
                                break;
                            }
                            
                            NSMutableDictionary *tempMuDict = [NSMutableDictionary dictionaryWithDictionary:updateNewDict];
                            [needUpdateDict setObject:@[tempMuDict] forKey:pathValueStr];
                            needUpdateDict = tempMuDict;
                        } else {
                            NSMutableDictionary *tempMuDict = [NSMutableDictionary dictionary];
                            
                            if ([updateNewDict isKindOfClass:[NSDictionary class]]) {
                                [tempMuDict addEntriesFromDictionary:updateNewDict];
                            }
                            
                            [needUpdateDict setObject:tempMuDict forKey:pathValueStr];
                            needUpdateDict = tempMuDict;
                        }
                    }
                }
            }
        }
        
        if (bolNeedUpdateCache) {
            toCacheBlock(oldRspDict);
        }
        
    } else {
        toCacheBlock(responseData);
    }
}

/**
 *  从obj中获取最近一层的字典
 */
- (NSDictionary *)getJsonDictFromObjcet:(id)obj
{
    if ([obj isKindOfClass:NSDictionary.class]) {
        return obj;
    } else if ([obj isKindOfClass:NSArray.class]) {
        return [self getJsonDictFromObjcet:[obj firstObject]];
    }
    return nil;
}

# pragma mark -- 联网的回调

// 联网结束（包括正确和错误结果）后，在主线程回调上层
- (void)handlerFinishBlock:(ZWCompletionWithResponseBlock)completionBlock responseData:(ZWHttpResponseData *)responseData error:(NSError *)error urlResponse:(NSURLResponse *)response
{
    if (completionBlock)
    {
        // 切回主线程处理
        performBlockOnMainQueue(NO, ^{
            if (completionBlock) {
                completionBlock(responseData, error, response);
            }
        });
    }
}

# pragma mark -- 发送前和结束后相关操作

// 处理发送前相关事项
- (void)prepareSendDataRequestTask:(ZWHttpEventInfo *)requestEvent
{
    // 添加hud
    if (requestEvent.progressMaskType != HttpProgressMaskTypeNone)
    {
        performBlockOnMainQueue(YES, ^{
            [LoadingUtil show];
        });
        //        UIView *targetView = requestEvent.progressTargetView;
        //        if (targetView) // app启动时，target为空，不处理
        //        {
        //            performBlockOnMainQueue(YES, ^{
        //                [LoadingUtil show];
        //            });
        //        }
    }
}

// 处理接收数据结束后事项
- (void)endReceiveDataRequestTask:(ZWHttpEventInfo *)requestEvent
{
    // 移除hud
    if (requestEvent.progressMaskType != HttpProgressMaskTypeNone) {
        performBlockOnMainQueue(YES, ^{
            [LoadingUtil hide];
        });
        //        UIView *targetView = requestEvent.progressTargetView;
        //        if (targetView) // app启动时，target为空，不处理
        //        {
        //            performBlockOnMainQueue(YES, ^{
        //                [LoadingUtil hide];
        //            });
        //        }
    }
}

#pragma mark -- 取消网络相关
- (void)cancelAllTask
{
    [self.httpManager cancelAllTask];
    [self.binaryHttpManager cancelAllTask];
    [self.httpMStockManager cancelAllTask];
    [self.httpCDNStockManager cancelAllTask];
    [self.h5HttpManager cancelAllTask];
    [self.httpStockManager cancelAllTask];
}

- (void)cancelTaskWithKey:(NSString *)eventKey
{
    [self.httpManager cancelTaskWithKey:eventKey];
    [self.binaryHttpManager cancelTaskWithKey:eventKey];
    [self.httpMStockManager cancelTaskWithKey:eventKey];
    [self.httpCDNStockManager cancelTaskWithKey:eventKey];
    [self.h5HttpManager cancelTaskWithKey:eventKey];
    [self.httpStockManager cancelTaskWithKey:eventKey];
}

#pragma 获取method对应的索引
+ (HttpMethod)transHttpMethodToIndex:(NSString *)methodStr
{
    HttpMethod hMethod = HttpMethodPOST;
    if ([methodStr isKindOfClass:[NSString class]]) {
        NSInteger count = sizeof(httpMethods)/sizeof(httpMethods[0]);
        for (NSInteger i = 0; i < count; i++) {
            NSString *str = httpMethods[i];
            if ([str isEqualToString:methodStr]) {
                hMethod = i;
                break;
            }
        }
    }
    
    return hMethod;
}

- (void)resetH5RequestSerializerWithHeaderParam:(NSDictionary *)headerDict
{
    if (!([headerDict allKeys].count == 0 && [self.h5HttpManager.manager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]])) {
        
        NSString *contentType = [DataFormatterFunc validStringValue:headerDict[@"Content-Type"]];
        
        if (![[headerDict allKeys] containsObject:@"Content-Type"] || [contentType containsString:@"application/json"]) {
            self.h5HttpManager.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        } else {
            self.h5HttpManager.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        
        [self.h5HttpManager updateRequestHeaderWithKeymap:headerDict];
        [self.h5HttpManager appendCustomUserAgent:self.userAgent];
    }
}

//6.12 添加特殊header后还原
- (void)resetBHttpRequestHead
{
    [self.binaryHttpManager resetHttpHeaderWithUserAgent:self.userAgent];
}

// 针对二进制通道添加特殊header  同花顺接口需要
- (void)addSpecialHeader:(NSDictionary *)headDict
{
    [self.binaryHttpManager updateRequestHeaderWithKeymap:headDict];
}


@end
