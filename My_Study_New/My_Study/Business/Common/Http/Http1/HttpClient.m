//
//  HttpClient.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/18.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HttpClient.h"
#import "NSString+URLEncode.h"
#import "MJExtension.h"
#import "ZWSiteAddressManager.h"

#define HttpClient_HTTP_StatusCode @"HttpClient_HTTP_StatusCode"


@interface HttpClient ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, assign) BOOL isConnect;

@end

@implementation HttpClient

- (instancetype)init
{
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
        /* 设置请求类型 */
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        /* 设置响应类型 */
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        /* 设置可接受响应类型 */
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                  @"application/json",
                                                                  @"text/html",
                                                                  @"text/json",
                                                                  @"text/javascript",
                                                                  @"text/plain",
                                                                  @"image/gif", nil];
        
        /* 开启监听 */
        [self openNetMonitoring];
        
    }
    
    return self;
}

/* 开启网络状态监听 */
- (void)openNetMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {

        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                self.isConnect = NO;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                self.isConnect = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                self.isConnect = YES;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.isConnect = YES;
                break;
                
            default:
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    self.isConnect = YES;
    
}


+ (HttpClient *)defaultClient {
    static HttpClient * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}



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
         prepareExecute:(PrepareExecuteBlock _Nullable)prepare
                success:(HttpSuccessBlock)success
                failure:(HttpFailureBlock)failure
{
    /* 判断是否存在 http/https  不存在取 baseURL */
    if (!([url hasPrefix:@"http"]||[url hasPrefix:@"https"])) {
        url = [NSString stringWithFormat:@"%@%@", [ZWSiteAddressManager getBaseHttpURL], url]  ;
    }
    
    @pas_weakify_self
    self.httpSuccessBlock = ^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        @pas_strongify_self
//        NSString *url = task.response.URL.path;
        NSString *logMsg = [NSString stringWithFormat:@"接口: %@ \n-入参: %@ \n-返回: %@", url, [JSONUtil jsonString:params], [JSONUtil jsonString:responseObject]];
        
        /* 测试解析URL中的参数方法 */
//        NSString *testUrl = @"http://127.0.0.1:4523/m1/1102411-0-default/zq/wecomchat/chatrecord/detailList?pageNo=1&count=20&titleName=home";
//        NSDictionary *dict = [testUrl queryStringToDic];
//        NSLog(@"http-client-url-dict = %@", dict);
        
        [LogUtil debug:logMsg flag:url context:self];
        BlockSafeRun(success, task, responseObject);
    };
    
    self.httpFailureBlock = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        @pas_strongify_self
        NSError *httpError = error;
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]){
            NSInteger httpStatusCode = [(NSHTTPURLResponse *)task.response statusCode];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            [userInfo setObject:@(httpStatusCode) forKey:HttpClient_HTTP_StatusCode];
            
            httpError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
        }
        
        NSString *errorMsg = [NSString stringWithFormat:@"%@", httpError];
        NSString *logMsg = [NSString stringWithFormat:@"接口: %@ \n-入参: %@ \n-返回: %@", url, [params mj_JSONString], httpError];
//        [LogUtil debug:logMsg flag:url context:self];
        [LogUtil warn:logMsg flag:url context:self];
        [Toast show:errorMsg];
        BlockSafeRun(failure, task, error);
    };
    
    NSLog(@"请求网络地址为: %@", url);
    if ([self isconnectionAvailable]) {
        /* 预处理 */
        BlockSafeRun(prepare);
        
        switch (method) {
            case HttpRequestGet:
                [self.manager GET:url parameters:params progress:nil success:success failure:failure];
                break;
                
            case HttpRequestPost:
                [self.manager POST:url parameters:params progress:nil success:self.httpSuccessBlock failure:self.httpFailureBlock];
                break;
                
            case HttpRequestPut:
                [self.manager PUT:url parameters:params success:success failure:failure];
                break;
                
            case HttpRequestDelete:
                [self.manager DELETE:url parameters:params success:success failure:failure];
                break;
                
            default:
                break;
        }
        
    } else {
        [self showExceptionDialog];
    }
}

- (BOOL)isconnectionAvailable
{
    return self.isConnect;
}

- (void)showExceptionDialog
{
    [Toast show:@"网络连接异常，请检查网络连接"];
}


@end
