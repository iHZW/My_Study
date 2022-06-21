//
//  RestIOManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "RestIOManager.h"

@implementation RestIOManager

#pragma mark - priviate's

/**
 增加指定的userAgent信息

 @param userAgent 需要增加的userAgent信息
 */
- (void)updateUserAgentInfo:(NSString *)userAgent
{
    NSString *oldAgent = [self.manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
    NSString *newAgent  = [NSString stringWithFormat:@"%@ %@", oldAgent, userAgent];
    [self.manager.requestSerializer setValue:newAgent forHTTPHeaderField:@"User-Agent"];
}

/**
 通过指定的task标记查找对应的NSURLSessionDataTask

 @param eventKey task标记
 @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)taskWithEventKey:(nullable NSString *)eventKey
{
    NSArray *operations = [self.manager.operationQueue operations];
    
    if ([operations count] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.uuidTag == %@", eventKey];
        NSArray *array = [operations filteredArrayUsingPredicate:predicate];
        return [array lastObject];
    }
    
    return nil;
}

#pragma mark - public's
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
    }
    
    return self;
}

/**
 使用operationQueue最大并发数、返回包体的格式、附加的userAgent信息创建AFHTTPSessionManager

 @param maxConncurrentCount operationQueue最大并发数
 @param acceptableContentTypes 返回包体的格式
 @param userAgent 附加的userAgent信息
 @return AFHTTPSessionManager
 */
- (instancetype)initWithData:(NSInteger)maxConncurrentCount
      acceptableContenttypes:(nullable NSSet <NSString *> *)acceptableContentTypes
                   userAgent:(NSString *)userAgent
{
    self = [super init];
    
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
        self.manager.operationQueue.maxConcurrentOperationCount = maxConncurrentCount;
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        if (acceptableContentTypes) {
            self.manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
        }
        
        if ([userAgent length] > 0) {
            [self updateUserAgentInfo:userAgent];
        }
    }
    
    return self;
}

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
{
    BOOL bRet = YES;
    if (sessionManagerSettingBlock) {
        bRet = sessionManagerSettingBlock(self);
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    if (bRet) {
        dataTask = [self.manager dataTaskWithRequest:request
                                      uploadProgress:uploadProgressBlock
                                    downloadProgress:downloadProgressBlock
                                   completionHandler:completionHandler];
        
        [dataTask resume];
    }
    
    return dataTask;
}

/**
 使用自定义的UserAgent信息重置HTTP包头UserAgent信息

 @param userAgent 用户自定义UserAgent信息
 */
- (void)resetHttpHeaderWithUserAgent:(nullable NSString *)userAgent
{
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self updateUserAgentInfo:userAgent];
}

/**
 向当前UserAgent信息中增加自定义信息

 @param userAgent 增加自定义的userAgent信息
 */
- (void)appendCustomUserAgent:(nullable NSString *)userAgent
{
    [self updateUserAgentInfo:userAgent];
}

/**
 取消当前AFHTTPSessionManager所有Task
 */
- (void)cancelAllTask
{
    [self.manager.operationQueue cancelAllOperations];
}

/**
 取消当前AFHTTPSessionManager指定的NSURLSessionDataTask

 @param eventKey taskKey
 */
- (void)cancelTaskWithKey:(nullable NSString *)eventKey
{
    NSURLSessionDataTask *op = (NSURLSessionDataTask *)[self taskWithEventKey:eventKey];
    [op cancel];
}

/**
 更新安全策略

 @param certData 证书设置
 */
- (void)updateSecurityPolicyWithCert:(nullable NSData *)certData
{
    AFSecurityPolicy *securityPolicy = nil;
    
    if ([certData length] > 0) {
        // AFSSLPinningModeCertificate 使用证书验证模式
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        
        // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
        // 如果是需要验证自建证书或者已过期证书，需要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName      = YES;
        
        // validatesDomainName 是否需要验证域名，默认为YES；
        // 假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
        // 置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
        // 如置为NO，建议自己添加对应域名的校验逻辑。
        securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData, nil];
        
    } else {
        securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName = YES;
    }
    
    self.manager.securityPolicy = securityPolicy;
}

/**
 更新reponse contentType、请求超时时间以及缓存策略

 @param acceptableContentType 返回包体的格式
 @param timeout 超时时间
 @param cachePolicy 缓存策略
 */
- (void)updateSerializerConfig:(nullable NSSet <NSString *> *)acceptableContentType timeout:(NSTimeInterval)timeout cachePolicy:(NSURLRequestCachePolicy)cachePolicy
{
    if (acceptableContentType) {
        NSMutableSet *curContentTypes = [NSMutableSet setWithSet:self.manager.responseSerializer.acceptableContentTypes];
        [curContentTypes addObject:acceptableContentType];
        self.manager.responseSerializer.acceptableContentTypes = curContentTypes;
    }
    
    if (timeout != self.manager.requestSerializer.timeoutInterval) {
        self.manager.requestSerializer.timeoutInterval = timeout;
    }
    
    self.manager.requestSerializer.cachePolicy = cachePolicy;
}

/**
 通过给定的用户键值信息设置AFHTTPSessionManager的请求包头信息

 @param keymap 包头键值信息
 */
- (void)updateRequestHeaderWithKeymap:(nullable NSDictionary *)keymap
{
    [keymap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

@end
