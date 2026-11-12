#import "ZWNetworkTransport.h"
#import "ZWDokitLog.h"

@implementation ZWNetworkTransport
+ (AFHTTPSessionManager *)defaultManager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 6;
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 原始数据由业务解析，HTTP 状态合法性仍由 AFNetworking 校验。
        manager.responseSerializer.acceptableContentTypes = nil;
    });
    return manager;
}

+ (NSURLSessionDataTask *)sendRequest:(NSURLRequest *)request manager:(AFHTTPSessionManager *)manager
                             taskKey:(NSString *)taskKey uploadProgress:(void (^)(NSProgress *))uploadProgress
                    downloadProgress:(void (^)(NSProgress *))downloadProgress
                          completion:(void (^)(NSURLSessionDataTask *, id, NSError *))completion {
    NSURLRequest *snapshot = [request copy];
#if defined(DEBUG) || defined(DOKIT)
    NSString *identifier = NSUUID.UUID.UUIDString;
    NSTimeInterval started = NSProcessInfo.processInfo.systemUptime;
#endif

    // AFSessionManager 持有任务与回调；弱引用避免 task -> block -> task 循环。
    __block __weak NSURLSessionDataTask *taskReference = nil;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:snapshot uploadProgress:uploadProgress downloadProgress:downloadProgress
        completionHandler:^(NSURLResponse *response, id data, NSError *error) {
            NSURLSessionDataTask *finishedTask = taskReference;
#if defined(DEBUG) || defined(DOKIT)
            // 请求结束后一次输出请求与响应，流式请求体仅记录摘要。
            id body = snapshot.HTTPBody;
            if (snapshot.HTTPBodyStream) body = @"<流式请求体，未读取>";
            NSString *contentType = [snapshot valueForHTTPHeaderField:@"Content-Type"];
            if ([contentType containsString:@"application/x-www-form-urlencoded"] && snapshot.HTTPBody.length < 16384) {
                NSString *form = [[NSString alloc] initWithData:snapshot.HTTPBody encoding:NSUTF8StringEncoding];
                NSURLComponents *components = [NSURLComponents new];
                components.percentEncodedQuery = form;
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                for (NSURLQueryItem *item in components.queryItems) parameters[item.name] = item.value ?: @"";
                body = parameters;
            }
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            for (NSURLQueryItem *item in [NSURLComponents componentsWithURL:snapshot.URL resolvingAgainstBaseURL:NO].queryItems) {
                query[item.name] = item.value ?: @"";
            }
            NSInteger status = [response isKindOfClass:NSHTTPURLResponse.class] ? [(NSHTTPURLResponse *)response statusCode] : 0;
            NSDictionary *responseHeaders = [response isKindOfClass:NSHTTPURLResponse.class] ? [(NSHTTPURLResponse *)response allHeaderFields] : @{};
            [ZWDokitLog event:error ? @"请求失败" : @"请求完成" category:@"Network" fields:@{
                @"requestId": identifier, @"method": snapshot.HTTPMethod ?: @"GET", @"url": snapshot.URL.absoluteString ?: @"",
                @"headers": snapshot.allHTTPHeaderFields ?: @{}, @"query": query, @"body": body ?: NSNull.null,
                @"status": @(status), @"durationMs": @((NSProcessInfo.processInfo.systemUptime - started) * 1000),
                @"responseHeaders": responseHeaders,
                @"response": data ?: error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] ?: NSNull.null,
                @"errorDomain": error.domain ?: @"", @"errorCode": @(error.code)}];
#endif
            dispatch_async(dispatch_get_main_queue(), ^{ if (completion) completion(finishedTask, data, error); });
        }];
    taskReference = task;
    task.taskDescription = taskKey;
    [task resume];
    return task;
}

+ (void)cancelTasksForManager:(AFHTTPSessionManager *)manager key:(NSString *)key {
    // NSURLSessionTask 不属于 operationQueue，必须取消真实任务。
    for (NSURLSessionTask *task in manager.tasks) {
        if (!key || [task.taskDescription isEqualToString:key]) [task cancel];
    }
}
@end
