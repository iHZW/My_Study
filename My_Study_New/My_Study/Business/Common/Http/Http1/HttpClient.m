#import "HttpClient.h"
#import "ZWSiteAddressManager.h"
#import "ZWNetworkTransport.h"
#import "ZWDokitLog.h"

@implementation HttpClient
+ (HttpClient *)defaultClient {
    static HttpClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ client = [HttpClient new]; });
    return client;
}

- (NSURLSessionDataTask *)requestWithPath:(NSString *)path method:(HttpRequestType)method
                           paramenters:(NSDictionary *)parameters prepareExecute:(PrepareExecuteBlock)prepare
                               success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure {
    // 每次请求拥有独立回调和序列化器，不将回调存入单例属性。
    NSArray *methods = @[@"GET", @"POST", @"PUT", @"DELETE"];
    NSError *error = nil;
    NSURL *target = [ZWSiteAddressManager URLForPath:path error:&error];
    NSString *url = target.absoluteString;
    NSMutableURLRequest *request = nil;
    if (method < methods.count && target.host.length &&
        ([@[@"http", @"https"] containsObject:target.scheme.lowercaseString])) {
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        serializer.timeoutInterval = 30;
        request = [serializer requestWithMethod:methods[method] URLString:url parameters:[parameters copy] error:&error];
    } else {
        error = error ?: [NSError errorWithDomain:@"ZWNetwork" code:NSURLErrorBadURL
                               userInfo:@{NSLocalizedDescriptionKey: @"请求地址或 HTTP 方法无效"}];
    }
    if (!request || error) {
        [ZWDokitLog event:@"请求构建失败" category:@"Network" fields:@{@"url": url ?: path ?: @"", @"method": method < methods.count ? methods[method] : @"UNKNOWN", @"body": parameters ?: @{}, @"errorCode": @(error.code), @"message": error.localizedDescription ?: @""}];
        dispatch_async(dispatch_get_main_queue(), ^{ if (failure) failure(nil, error); });
        return nil;
    }
    if (prepare) prepare();
    return [ZWNetworkTransport sendRequest:request manager:[ZWNetworkTransport defaultManager] taskKey:nil
        uploadProgress:nil downloadProgress:nil completion:^(NSURLSessionDataTask *task, id data, NSError *requestError) {
            if (requestError) { if (failure) failure(task, requestError); }
            else if (success) success(task, data);
        }];
}
@end
