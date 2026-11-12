#import <Foundation/Foundation.h>
#import "Router.h"
#import "BaseRouterIntercept.h"

static NSUInteger checks = 0;
static void Verify(BOOL condition, NSString *message) {
    checks++;
    if (!condition) { NSLog(@"失败：%@", message); exit(1); }
}

@interface TestNavigator : NSObject <RouterNavigateDelegate>
@property (nonatomic) NSUInteger count;
@property (nonatomic, strong) RouterParam *last;
@end
@implementation TestNavigator
- (void)navigateTo:(RouterParam *)param { self.count++; self.last = param; Verify(NSThread.isMainThread, @"导航必须在主线程"); }
- (void)presentTo:(RouterParam *)param { [self navigateTo:param]; }
- (void)tabTo:(RouterParam *)param { [self navigateTo:param]; }
- (void)doAction:(RouterParam *)param { [self navigateTo:param]; }
@end

@interface StopInterceptor : BaseRouterIntercept
@end
@implementation StopInterceptor
- (RouterParam *)doIntercept:(RouterParam *)param { return nil; }
@end

@interface RewriteInterceptor : BaseRouterIntercept
@end
@implementation RewriteInterceptor
- (RouterParam *)doIntercept:(RouterParam *)param {
    return [RouterParam makeWith:param.originUrl destURL:@"RewrittenPage" params:param.params type:param.type context:nil];
}
- (NSInteger)interceptPriority { return 1; }
@end

int main(void) {
    @autoreleasepool {
        Router *router = [Router new];
        TestNavigator *navigator = [TestNavigator new];
        router.navigateObject = navigator;
        NSMutableArray *events = [NSMutableArray array];
        router.eventLogger = ^(NSString *event, NSDictionary *fields) {
            [events addObject:@{@"event": event, @"fields": fields}];
        };
        RouterPageItem *page = [RouterPageItem makeWithUrl:@"member/detail" clsName:@"MemberPage" type:RouterTypeNavigate attachValue:@{@"default": @1}];
        NSError *error = nil;
        Verify([router registerPages:@[page] error:&error], @"注册有效路由");
        Verify(![router registerPages:@[page, page] error:&error], @"拒绝重复路径");
        Verify([router pageForPath:@"member/detail"] != nil, @"注册失败保留旧索引");
        Verify([router resolveURL:@"missing"] == nil, @"未知路由返回空");
        Verify([router resolveURL:@"member/detail?param=%5B1%5D"] == nil, @"拒绝数组参数");
        NSDictionary *special = @{@"text": @"中文 & = ? # % + /", @"nested": @{@"value": @[@1, @2]}};
        NSString *url = [Router encodeRoute:@"member/detail" parameters:special];
        Verify([[Router decodeRoute:url][@"data"] isEqual:special], @"特殊字符和嵌套参数往返一致");
        Verify([Router decodeRoute:@"member/detail?param=%GG"].count == 0, @"拒绝错误百分号编码");
        Verify([Router decodeRoute:@"member/detail?param=null"].count == 0, @"拒绝空参数对象");
        [router openPath:@"member/detail" parameters:@{@"id": @7} context:nil success:nil failure:nil];
        Verify(events.count == 1, @"成功跳转只记录一条日志");
        Verify(navigator.count == 1 && [navigator.last.params[@"default"] isEqual:@1], @"默认参数与业务参数合并");
        Verify([events.firstObject[@"fields"][@"path"] isEqual:@"member/detail"], @"观察器记录实际路由路径");
        Verify([events.firstObject[@"fields"][@"parameters"][@"id"] isEqual:@7], @"观察器记录合并入参");
        router.interceptors = @[[RewriteInterceptor new]];
        [router executeURL:url];
        Verify([navigator.last.destURL isEqual:@"RewrittenPage"], @"拦截器替换请求生效");
        Verify(events.count == 2 && [events.lastObject[@"fields"][@"target"] isEqual:@"RewrittenPage"], @"改写目标合并到最终日志");
        router.interceptors = @[[StopInterceptor new]];
        __block NSUInteger failures = 0;
        [router executeURL:url success:nil fail:^(NSError *failure) { failures++; }];
        Verify(events.count == 3, @"拦截失败只记录一条日志");
        Verify(failures == 1 && navigator.count == 2, @"拦截后不导航且只回调一次");
        router.interceptors = @[];
        [router executeURL:@"missing" success:nil fail:^(NSError *failure) { failures++; }];
        Verify(failures == 2, @"未知路由报告错误");
        Verify(events.count == 4 && [events.lastObject[@"fields"][@"path"] isEqual:@"missing"], @"解析失败只记录一条且保留原路径");
        Verify([events.lastObject[@"fields"][@"result"] isEqual:@"失败"], @"失败结果合并在单条日志中");
        router.navigateObject = nil;
        [router executeURL:url success:nil fail:^(NSError *failure) { failures++; }];
        Verify(failures == 3, @"未注册导航器报告错误");
        router.navigateObject = navigator;
        __block BOOL finished = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            [router executeURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{ finished = YES; });
        });
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:5];
        while (!finished && deadline.timeIntervalSinceNow > 0) {
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        }
        Verify(finished && navigator.count == 3, @"后台调用调度到主线程");
        NSLog(@"路由核心验证通过，共 %lu 项", (unsigned long)checks);
    }
    return 0;
}
