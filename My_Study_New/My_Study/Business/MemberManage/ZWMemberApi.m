//
//  ZWMemberApi.m
//  My_Study
//

#import "ZWMemberApi.h"

static NSString *const kBaseURLKey = @"ZWMemberBaseURL";
static NSString *const kTokenKey = @"ZWMemberToken";
static NSString *const kUserKey = @"ZWMemberUser";
static NSString *const kDefaultBaseURL = @"http://127.0.0.1:3000";

@implementation ZWMemberApi

+ (NSString *)baseURL
{
    NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:kBaseURLKey];
    return url.length ? url : kDefaultBaseURL;
}

+ (void)setBaseURL:(NSString *)baseURL
{
    NSString *url = [baseURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([url hasSuffix:@"/"]) {
        url = [url substringToIndex:url.length - 1];
    }
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:kBaseURLKey];
}

+ (BOOL)hasToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTokenKey].length > 0;
}

+ (NSString *)token
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTokenKey] ?: @"";
}

+ (void)clearToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kTokenKey];
    [defaults removeObjectForKey:kUserKey];
}

+ (NSDictionary *)currentUser
{
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:kUserKey];
    return [user isKindOfClass:[NSDictionary class]] ? user : nil;
}

+ (void)logout
{
    [self clearToken];
}

#pragma mark - Public

+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(ZWMemberApiCompletion)completion
{
    [self requestWithMethod:@"POST"
                       path:@"/api/auth/login"
                      query:nil
                       body:@{@"username": username, @"password": password}
                 completion:^(NSDictionary *data, NSError *error) {
        NSString *token = data[@"token"];
        if (!error && [token isKindOfClass:[NSString class]] && token.length) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:kTokenKey];
            NSDictionary *user = data[@"user"];
            if ([user isKindOfClass:[NSDictionary class]]) {
                [defaults setObject:user forKey:kUserKey];
            }
        }
        completion(data, error);
    }];
}

+ (void)fetchMembersWithPage:(NSInteger)page
                        size:(NSInteger)size
                     keyword:(NSString *)keyword
                  completion:(ZWMemberApiCompletion)completion
{
    [self requestWithMethod:@"GET"
                       path:@"/api/members"
                      query:@{
                          @"page": @(page),
                          @"size": @(size),
                          @"keyword": keyword ?: @"",
                      }
                       body:nil
                 completion:completion];
}

+ (void)fetchMemberDetail:(NSInteger)memberId completion:(ZWMemberApiCompletion)completion
{
    [self requestWithMethod:@"GET"
                       path:[NSString stringWithFormat:@"/api/members/%@", @(memberId)]
                      query:nil
                       body:nil
                 completion:completion];
}

+ (void)fetchMemberOrders:(NSInteger)memberId completion:(ZWMemberApiCompletion)completion
{
    [self requestWithMethod:@"GET"
                       path:@"/api/orders"
                      query:@{@"memberId": @(memberId), @"page": @1, @"size": @10}
                       body:nil
                 completion:completion];
}

+ (void)createMemberWithName:(NSString *)name
                       phone:(NSString *)phone
                  completion:(ZWMemberApiCompletion)completion
{
    [self requestWithMethod:@"POST"
                       path:@"/api/members"
                      query:nil
                       body:@{@"name": name, @"phone": phone}
                 completion:completion];
}

#pragma mark - Core

+ (void)requestWithMethod:(NSString *)method
                     path:(NSString *)path
                    query:(NSDictionary *)query
                     body:(NSDictionary *)body
               completion:(ZWMemberApiCompletion)completion
{
    NSURLComponents *components = [NSURLComponents componentsWithString:[[self baseURL] stringByAppendingString:path]];
    if (query.count) {
        NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
        [query enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [items addObject:[NSURLQueryItem queryItemWithName:key value:[obj description]]];
        }];
        components.queryItems = items;
    }
    NSURL *url = components.URL;
    if (!url) {
        completion(nil, [self errorWithMessage:@"服务器地址不合法"]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    request.timeoutInterval = 15;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if ([self hasToken]) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", [self token]] forHTTPHeaderField:@"Authorization"];
    }
    if (body) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    }

    NSURLSessionDataTask *task = [NSURLSession.sharedSession
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    completion(nil, [self errorWithMessage:[NSString stringWithFormat:@"网络异常：%@", error.localizedDescription]]);
                    return;
                }
                NSInteger httpCode = [(NSHTTPURLResponse *)response statusCode];
                NSDictionary *json = nil;
                if (data.length) {
                    json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                }
                if (httpCode == 401) {
                    [self clearToken];
                }
                if (![json isKindOfClass:[NSDictionary class]]) {
                    completion(nil, [self errorWithMessage:[NSString stringWithFormat:@"服务响应异常（HTTP %@）", @(httpCode)]]);
                    return;
                }
                NSString *status = json[@"status"];
                if ([status isKindOfClass:[NSString class]] && [status isEqualToString:@"1"]) {
                    id payload = json[@"data"];
                    completion([payload isKindOfClass:[NSDictionary class]] ? payload : @{}, nil);
                } else {
                    NSString *message = json[@"errmsg"];
                    completion(nil, [self errorWithMessage:message.length ? message : @"请求失败"]);
                }
            });
        }];
    [task resume];
}

+ (NSError *)errorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:@"ZWMemberApi" code:-1 userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
