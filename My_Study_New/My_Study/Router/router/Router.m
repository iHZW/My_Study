#import "Router.h"
#import "BaseRouterIntercept.h"

@interface Router ()
@property (nonatomic, copy) NSDictionary<NSString *, RouterPageItem *> *pathIndex;
@property (nonatomic, copy) NSDictionary<NSString *, RouterPageItem *> *classIndex;
@end

@implementation Router

- (NSDictionary *)diagnosticFieldsForRequest:(RouterParam *)request {
    NSString *path = [Router decodeRoute:request.originUrl][@"path"] ?: [self pageForClassName:request.destURL].url
        ?: [request.originUrl componentsSeparatedByString:@"?"].firstObject ?: @"";
    return @{@"path": path, @"target": request.destURL ?: @"", @"type": @(request.type), @"parameters": request.params ?: @{}};
}

- (void)recordEvent:(NSString *)event request:(RouterParam *)request details:(NSDictionary *)details {
    if (!self.eventLogger) return;
    NSMutableDictionary *fields = [[self diagnosticFieldsForRequest:request] mutableCopy];
    [fields addEntriesFromDictionary:details ?: @{}];
    self.eventLogger(event, fields);
}

+ (NSError *)errorWithCode:(RouterErrorCode)code message:(NSString *)message {
    return [NSError errorWithDomain:@"Router" code:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (BOOL)registerPages:(NSArray<RouterPageItem *> *)pages error:(NSError **)error {
    NSMutableDictionary *paths = [NSMutableDictionary dictionary];
    NSMutableDictionary *classes = [NSMutableDictionary dictionary];
    for (RouterPageItem *page in pages) {
        if (!page.url.length || !page.clsName.length || paths[page.url]) {
            if (error) *error = [Router errorWithCode:RouterErrorInvalidRequest message:@"路由路径为空或重复注册"];
            return NO;
        }
        // 保存注册快照，调用方后续修改配置不会污染索引。
        RouterPageItem *snapshot = [RouterPageItem makeWithUrl:page.url clsName:page.clsName
                                                       type:page.type attachValue:[page.attachValue copy]];
        paths[snapshot.url] = snapshot;
        if (!classes[snapshot.clsName]) classes[snapshot.clsName] = snapshot;
    }
    @synchronized (self) {
        self.pathIndex = paths;
        self.classIndex = classes;
        _routerConfigs = [pages copy];
    }
    return YES;
}

- (void)setRouterConfigs:(NSArray *)routerConfigs {
    NSError *error = nil;
    if (![self registerPages:routerConfigs error:&error]) {
        [NSException raise:NSInvalidArgumentException format:@"%@", error.localizedDescription];
    }
}

- (RouterPageItem *)pageForPath:(NSString *)path {
    if (!path.length) return nil;
    @synchronized (self) { return self.pathIndex[path]; }
}

- (RouterPageItem *)pageForClassName:(NSString *)className {
    if (!className.length) return nil;
    @synchronized (self) { return self.classIndex[className]; }
}

+ (NSDictionary *)decodeRoute:(NSString *)route {
    if (![route isKindOfClass:NSString.class] || !route.length) return @{};
    NSRange separator = [route rangeOfString:@"?"];
    NSString *path = separator.location == NSNotFound ? route : [route substringToIndex:separator.location];
    path = [path stringByRemovingPercentEncoding];
    if (!path.length) return @{};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (separator.location != NSNotFound) {
        NSString *query = [route substringFromIndex:separator.location + 1];
        for (NSString *pair in [query componentsSeparatedByString:@"&"]) {
            NSRange equals = [pair rangeOfString:@"="];
            if (equals.location == NSNotFound) return @{};
            NSString *key = [[pair substringToIndex:equals.location] stringByRemovingPercentEncoding];
            NSString *value = [[pair substringFromIndex:equals.location + 1] stringByRemovingPercentEncoding];
            if (!key.length || !value) return @{};
            if ([key isEqualToString:@"param"]) {
                NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                id object = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
                if (![object isKindOfClass:NSDictionary.class]) return @{};
                [parameters addEntriesFromDictionary:object];
            } else {
                parameters[key] = value;
            }
        }
    }
    return @{@"path": path, @"data": [parameters copy]};
}

+ (NSString *)encodeRoute:(NSString *)path parameters:(NSDictionary *)parameters {
    NSDictionary *decoded = [self decodeRoute:path];
    if (!decoded[@"path"]) return @"";
    NSMutableDictionary *merged = [decoded[@"data"] mutableCopy];
    if (parameters) [merged addEntriesFromDictionary:parameters];
    if (!merged.count) return decoded[@"path"];
    if (![NSJSONSerialization isValidJSONObject:merged]) return @"";
    NSData *data = [NSJSONSerialization dataWithJSONObject:merged options:NSJSONWritingSortedKeys error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    return [NSString stringWithFormat:@"%@?param=%@", decoded[@"path"], [json stringByAddingPercentEncodingWithAllowedCharacters:allowed]];
}

- (RouterParam *)resolveURL:(NSString *)url {
    NSDictionary *decoded = [Router decodeRoute:url];
    RouterPageItem *page = [self pageForPath:decoded[@"path"]];
    if (!page) return nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:page.attachValue ?: @{}];
    [parameters addEntriesFromDictionary:decoded[@"data"] ?: @{}];
    return [RouterParam makeWith:url destURL:page.clsName params:parameters type:page.type context:nil];
}

- (void)openPath:(NSString *)path parameters:(NSDictionary *)parameters context:(id)context
        success:(RouterSuccessBlock)success failure:(RouterFailBlock)failure {
    RouterParam *request = [self resolveURL:path];
    if (!request) {
        [self executeURL:path success:success fail:failure];
        return;
    }
    NSMutableDictionary *merged = [request.params mutableCopy];
    [merged addEntriesFromDictionary:parameters ?: @{}];
    request.params = merged;
    request.context = context;
    [self execute:request success:success fail:failure];
}

- (void)executeURL:(NSString *)url { [self executeURL:url success:nil fail:nil]; }
- (void)executeURLNoCallBack:(NSString *)url { [self executeURL:url success:nil fail:nil]; }
- (void)executeRouterParam:(RouterParam *)param { [self execute:param success:nil fail:nil]; }

- (void)executeURL:(NSString *)url success:(RouterSuccessBlock)success fail:(RouterFailBlock)failure {
    // 所有解析、拦截和导航均在主线程执行，后台来源不直接触碰 UIKit。
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self executeURL:url success:success fail:failure]; });
        return;
    }
    RouterParam *request = [self resolveURL:url];
    if (!request && self.routerParseBlock) request = self.routerParseBlock(url);
    if (!request) { request = [RouterParam new]; request.originUrl = url ?: @""; }
    [self execute:request success:success fail:failure];
}

- (void)setInterceptors:(NSArray *)interceptors {
    _interceptors = [interceptors sortedArrayUsingComparator:^NSComparisonResult(BaseRouterIntercept *a, BaseRouterIntercept *b) {
        NSInteger left = a.interceptPriority, right = b.interceptPriority;
        return left < right ? NSOrderedAscending : (left > right ? NSOrderedDescending : NSOrderedSame);
    }];
}

- (void)execute:(RouterParam *)request success:(RouterSuccessBlock)success fail:(RouterFailBlock)failure {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self execute:request success:success fail:failure]; });
        return;
    }
    request.navigationResult = nil;
    RouterFailBlock originalFailure = request.failBlock ?: failure;
    __weak Router *weakRouter = self;
    // 日志字段独立于请求保存，失败闭包不反向持有请求；每次执行只输出一次。
    __block NSDictionary *diagnosticFields = [self diagnosticFieldsForRequest:request];
    __block BOOL emitted = NO;
    RouterFailBlock report = ^(NSError *error) {
        Router *router = weakRouter;
        if (!emitted) {
            emitted = YES;
            NSMutableDictionary *fields = [diagnosticFields mutableCopy];
            [fields addEntriesFromDictionary:@{@"result": @"失败", @"errorDomain": error.domain,
                @"errorCode": @(error.code), @"message": error.localizedDescription}];
            if (router.eventLogger) router.eventLogger(@"路由跳转", fields);
        }
        if (originalFailure) originalFailure(error);
    };
    if (!request || !request.destURL.length || (request.params && ![request.params isKindOfClass:NSDictionary.class])) {
        if (report) report([Router errorWithCode:RouterErrorInvalidRequest message:@"路由未注册或参数无效"]);
        return;
    }
    request.successBlock = request.successBlock ?: success;
    request.failBlock = report;
    NSArray *interceptors = self.interceptors;
    for (BaseRouterIntercept *interceptor in interceptors) {
        RouterParam *next = [interceptor doIntercept:request];
        if (!next) {
            if (report) report([Router errorWithCode:RouterErrorIntercepted message:@"路由已被拦截"]);
            return;
        }
        next.successBlock = next.successBlock ?: request.successBlock;
        next.failBlock = next.failBlock ?: request.failBlock;
        request = next;
    }
    diagnosticFields = [self diagnosticFieldsForRequest:request];
    if (!request.destURL.length || ![request.params isKindOfClass:NSDictionary.class]) {
        if (report) report([Router errorWithCode:RouterErrorInvalidRequest message:@"拦截器返回了无效路由"]);
        return;
    }
    id<RouterNavigateDelegate> navigator = self.navigateObject;
    if (!navigator) {
        if (report) report([Router errorWithCode:RouterErrorUnavailable message:@"导航执行器尚未注册"]);
        return;
    }
    switch (request.type) {
        case RouterTypeNavigate: [navigator navigateTo:request]; break;
        case RouterTypeNavigatePresent: [navigator presentTo:request]; break;
        case RouterTypeNavigateTab: [navigator tabTo:request]; break;
        case RouterTypeAction: [navigator doAction:request]; break;
        default:
            if (report) report([Router errorWithCode:RouterErrorInvalidRequest message:@"不支持的导航类型"]);
            break;
    }
    if (!emitted) {
        emitted = YES;
        [self recordEvent:@"路由跳转" request:request details:@{@"result": request.navigationResult ?: @"已提交"}];
    }
}
@end
