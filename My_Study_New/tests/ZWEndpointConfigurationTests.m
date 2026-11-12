#import <Foundation/Foundation.h>
#import "ZWEndpointConfiguration.h"
static NSUInteger count = 0;
static void Check(BOOL result, NSString *message) {
    count++;
    if (!result) { NSLog(@"失败：%@", message); exit(1); }
}
int main(void) {
    @autoreleasepool {
        NSError *error = nil;
        Check(![ZWEndpointConfiguration validatedBaseURL:@"" allowHTTP:YES error:&error] && error != nil, @"缺失配置明确失败");
        Check(![ZWEndpointConfiguration validatedBaseURL:@"$(ZW_API_BASE_URL_DEV)" allowHTTP:YES error:NULL], @"未展开变量不能发送请求");
        Check(![ZWEndpointConfiguration validatedBaseURL:@"http://localhost:3000" allowHTTP:NO error:NULL], @"生产环境拒绝 HTTP");
        Check([ZWEndpointConfiguration validatedBaseURL:@"http://localhost:3000" allowHTTP:YES error:NULL] != nil, @"调试环境允许本地 HTTP");
        Check(![ZWEndpointConfiguration validatedBaseURL:@"https://user:password@api.test" allowHTTP:NO error:NULL], @"拒绝内嵌账号密码");
        Check(![ZWEndpointConfiguration validatedBaseURL:@"https://api.test/v1?token=x" allowHTTP:NO error:NULL], @"基础地址不能带查询参数");
        Check(![ZWEndpointConfiguration validatedBaseURL:@"https://api.test/#x" allowHTTP:NO error:NULL], @"基础地址不能带片段");
        Check(![ZWEndpointConfiguration validatedBaseURL:@" https://api.test" allowHTTP:NO error:NULL], @"拒绝首尾空白");
        NSString *base = @"https://api.test/api/v1/";
        NSURL *url = [ZWEndpointConfiguration resolvePath:@"/members?page=2" baseURL:base allowHTTP:NO error:NULL];
        Check([url.absoluteString isEqual:@"https://api.test/api/v1/members?page=2"], @"相对路径保留版本前缀和查询参数");
        Check([[ZWEndpointConfiguration resolvePath:@"members" baseURL:base allowHTTP:NO error:NULL].absoluteString isEqual:@"https://api.test/api/v1/members"], @"无前导斜杠路径拼接一致");
        Check(![ZWEndpointConfiguration resolvePath:@"//other.test/x" baseURL:base allowHTTP:NO error:NULL], @"拒绝协议相对地址");
        Check(![ZWEndpointConfiguration resolvePath:@"../private" baseURL:base allowHTTP:NO error:NULL], @"拒绝基础路径穿越");
        Check(![ZWEndpointConfiguration resolvePath:@"%2e%2e/private" baseURL:base allowHTTP:NO error:NULL], @"拒绝编码路径穿越");
        Check(![ZWEndpointConfiguration resolvePath:@"/members#token" baseURL:base allowHTTP:NO error:NULL], @"拒绝请求片段");
        Check(![ZWEndpointConfiguration resolvePath:@"/members" baseURL:@"" allowHTTP:YES error:NULL], @"无后台不生成相对请求");
        Check([[ZWEndpointConfiguration resolvePath:@"https://other.test/a?q=1" baseURL:@"" allowHTTP:NO error:NULL].absoluteString isEqual:@"https://other.test/a?q=1"], @"显式独立服务保留绝对 URL 查询参数");
        Check([ZWEndpointConfiguration environmentForName:@"invalid"] == EnvironmentTypeNotFound, @"未知环境不误选开发环境");
        for (NSUInteger index = 0; index < 4; index++) {
            Check([ZWEndpointConfiguration environmentForName:[ZWEndpointConfiguration nameForEnvironment:index]] == index, @"四种环境标识往返一致");
        }
        NSLog(@"域名配置验证通过，共 %lu 项", (unsigned long)count);
    }
    return 0;
}
