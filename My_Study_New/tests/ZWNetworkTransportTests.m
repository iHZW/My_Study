#import <Foundation/Foundation.h>
#import "ZWNetworkTransport.h"
#import "ZWDokitLog.h"

static NSUInteger passed = 0;
static void Check(BOOL condition, NSString *message) {
    if (!condition) { NSLog(@"失败：%@", message); exit(1); }
    passed++;
}

@interface TestHTTPProtocol : NSURLProtocol
@end
@implementation TestHTTPProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request { return [request.URL.host isEqualToString:@"network.test"]; }
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request { return request; }
- (void)startLoading {
    if ([self.request.URL.path isEqualToString:@"/slow"]) return;
    NSInteger status = [self.request.URL.path isEqualToString:@"/failure"] ? 500 : 200;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"path": self.request.URL.path, @"method": self.request.HTTPMethod}
                                                 options:0 error:NULL];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:status HTTPVersion:@"HTTP/1.1"
                                                          headerFields:@{@"Content-Type": @"application/json"}];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}
- (void)stopLoading {}
@end

int main(void) {
    @autoreleasepool {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.protocolClasses = @[[TestHTTPProtocol class]];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        __block NSUInteger finished = 0;
        for (NSString *method in @[@"GET", @"POST", @"PUT", @"DELETE"]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://network.test/%@", method]]];
            request.HTTPMethod = method;
            [ZWNetworkTransport sendRequest:request manager:manager taskKey:nil uploadProgress:nil downloadProgress:nil
                completion:^(NSURLSessionDataTask *task, NSData *data, NSError *error) {
                    Check(NSThread.isMainThread, @"回调在主线程");
                    Check(!error && task != nil, @"并发请求成功且任务可用");
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    Check([json[@"method"] isEqual:method], @"各请求回调不串线");
                    finished++;
                }];
            request.HTTPMethod = @"PATCH";
        }
        NSURLRequest *failure = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://network.test/failure"]];
        [ZWNetworkTransport sendRequest:failure manager:manager taskKey:nil uploadProgress:nil downloadProgress:nil
            completion:^(NSURLSessionDataTask *task, id data, NSError *error) {
                Check(error != nil && [(NSHTTPURLResponse *)task.response statusCode] == 500, @"HTTP 500 作为失败返回");
                finished++;
            }];
        for (NSUInteger index = 0; index < 2; index++) {
            NSURLRequest *slow = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://network.test/slow"]];
            [ZWNetworkTransport sendRequest:slow manager:manager taskKey:@"same-key" uploadProgress:nil downloadProgress:nil
                completion:^(NSURLSessionDataTask *task, id data, NSError *error) {
                    Check(error.code == NSURLErrorCancelled, @"同 key 的真实任务均被取消");
                    finished++;
                }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [ZWNetworkTransport cancelTasksForManager:manager key:@"same-key"];
        });
        NSDictionary *safe = [ZWDokitLog sanitizedValue:@{@"password": @"private", @"nested": @[@{@"accessToken": @"private"}],
            @"url": @"https://network.test/a?token=private&name=ok"}];
        Check([safe[@"password"] isEqual:@"***"], @"密码脱敏");
        Check([safe[@"nested"][0][@"accessToken"] isEqual:@"***"], @"嵌套令牌脱敏");
        Check(![safe[@"url"] containsString:@"private"], @"URL 查询参数脱敏");
        Check([[ZWDokitLog sanitizedValue:[NSMutableData dataWithLength:20000]] isKindOfClass:NSString.class], @"大响应不展开");
        NSString *routeLog = [ZWDokitLog formattedEvent:@"路由跳转" category:@"Router" fields:@{
            @"result": @"已提交 push", @"type": @0, @"path": @"member/detail", @"target": @"MemberPage",
            @"parameters": @{@"memberId": @123, @"token": @"private"}}];
        Check([routeLog hasPrefix:@"member/detail\n"], @"日志首行直接展示实际路径");
        Check([routeLog containsString:@"\n路径：member/detail\n"], @"路由字段使用真实换行");
        Check([routeLog containsString:@"入参：\n{\n"], @"入参 JSON 缩进换行展示");
        Check(![routeLog containsString:@"private"], @"多行格式保留脱敏");
        NSString *networkLog = [ZWDokitLog formattedEvent:@"请求完成" category:@"Network" fields:@{
            @"method": @"POST", @"url": @"https://network.test/members", @"requestId": @"test-id",
            @"status": @200, @"durationMs": @12.5, @"headers": @{@"Authorization": @"private"},
            @"query": @{@"page": @1}, @"body": @{@"name": @"测试"}, @"response": @{@"ok": @YES}}];
        Check([networkLog hasPrefix:@"POST https://network.test/members\n"], @"网络首行显示方法与请求路径");
        Check([networkLog containsString:@"请求头：\n{\n"] && [networkLog containsString:@"入参（Body）：\n{\n"]
            && [networkLog containsString:@"响应：\n{\n"], @"请求头入参与响应合并并换行");
        Check([networkLog containsString:@"状态码：200"] && [networkLog containsString:@"12.50 ms"], @"合并日志显示状态与耗时");
        Check(![networkLog containsString:@"private"], @"合并网络日志保持请求头脱敏");
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:8];
        while (finished < 7 && deadline.timeIntervalSinceNow > 0) {
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
        Check(finished == 7, @"所有请求恰好完成一次");
        [manager invalidateSessionCancelingTasks:YES resetSession:NO];
        NSLog(@"网络验证通过，共 %lu 项", (unsigned long)passed);
    }
    return 0;
}
