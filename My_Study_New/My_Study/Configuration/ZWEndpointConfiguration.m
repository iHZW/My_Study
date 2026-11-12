#import "ZWEndpointConfiguration.h"
NSString *const ZWEndpointErrorDomain = @"ZWEndpointConfiguration";

@implementation ZWEndpointConfiguration
+ (NSString *)nameForEnvironment:(EnvironmentType)environment {
    NSArray *names = @[@"dev", @"qa", @"pl", @"online"];
    return environment < names.count ? names[environment] : @"";
}
+ (EnvironmentType)environmentForName:(NSString *)name {
    NSUInteger index = [@[@"dev", @"qa", @"pl", @"online"] indexOfObject:name ?: @""];
    return index == NSNotFound ? EnvironmentTypeNotFound : (EnvironmentType)index;
}
+ (NSURL *)fail:(NSString *)message error:(NSError **)error {
    if (error) *error = [NSError errorWithDomain:ZWEndpointErrorDomain code:NSURLErrorBadURL
                                      userInfo:@{NSLocalizedDescriptionKey: message}];
    return nil;
}
+ (NSURL *)validatedBaseURL:(NSString *)baseURL allowHTTP:(BOOL)allowHTTP error:(NSError **)error {
    if (![baseURL isKindOfClass:NSString.class] || !baseURL.length || [baseURL containsString:@"$("]) {
        return [self fail:@"当前环境尚未配置 API Base URL，请填写 NetworkEnvironments.xcconfig 中的对应地址" error:error];
    }
    if (![baseURL isEqualToString:[baseURL stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]]) {
        return [self fail:@"API 地址不能包含首尾空白" error:error];
    }
    NSURLComponents *components = [NSURLComponents componentsWithString:baseURL];
    BOOL schemeOK = [components.scheme.lowercaseString isEqualToString:@"https"] ||
        (allowHTTP && [components.scheme.lowercaseString isEqualToString:@"http"]);
    if (!schemeOK || !components.host.length || components.user || components.password || components.query || components.fragment || !components.URL) {
        return [self fail:@"API 地址必须是合法 HTTPS 地址，不能包含账号、查询参数或片段；调试环境允许 HTTP" error:error];
    }
    return components.URL;
}
+ (NSURL *)resolvePath:(NSString *)path baseURL:(NSString *)baseURL allowHTTP:(BOOL)allowHTTP error:(NSError **)error {
    if (![path isKindOfClass:NSString.class] || !path.length || [path hasPrefix:@"//"] || [path containsString:@"\\"]) {
        return [self fail:@"请求路径无效" error:error];
    }
    NSURLComponents *relative = [NSURLComponents componentsWithString:path];
    if (relative.scheme.length) {
        if (relative.fragment) return [self fail:@"请求 URL 不能包含片段" error:error];
        NSURLComponents *origin = [relative copy];
        origin.query = nil;
        if (![self validatedBaseURL:origin.string allowHTTP:allowHTTP error:error]) return nil;
        return relative.URL;
    }
    if (!relative || relative.host || relative.fragment) return [self fail:@"请求路径不能包含主机或片段" error:error];
    for (NSString *part in [relative.path componentsSeparatedByString:@"/"]) {
        if ([part isEqualToString:@".."] || [part isEqualToString:@"."]) return [self fail:@"请求路径不能跨越 API 基础路径" error:error];
    }
    NSURL *base = [self validatedBaseURL:baseURL allowHTTP:allowHTTP error:error];
    if (!base) return nil;
    NSString *prefix = [base.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *suffix = [path hasPrefix:@"/"] ? [path substringFromIndex:1] : path;
    NSURL *result = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", prefix, suffix]];
    return result ?: [self fail:@"请求路径无法生成合法 URL" error:error];
}
@end
