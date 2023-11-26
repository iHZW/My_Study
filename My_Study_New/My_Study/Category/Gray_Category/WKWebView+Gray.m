//
//  WKWebView+Gray.m


#import "WKWebView+Gray.h"
#import "NSObject+Customizer.h"

@implementation WKWebView (Gray)

+ (void)load {
    return;
    Class cls = object_getClass(self);

    Method originalMethod = class_getInstanceMethod([self class], @selector(initWithFrame:configuration:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(lg_initWithFrame:configuration:));
//    method_exchangeImplementations(originalMethod, swizzledMethod);

    [NSObject swizzledInstanceMethod:[WKWebView class] originalSelector:@selector(initWithFrame:configuration:) swizzledSelector:@selector(lg_initWithFrame:configuration:)];

}


- (instancetype)lg_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    // js脚本
    NSString *jScript = @"var filter = '-webkit-filter:grayscale(100%);-moz-filter:grayscale(100%); -ms-filter:grayscale(100%); -o-filter:grayscale(100%) filter:grayscale(100%);';document.getElementsByTagName('html')[0].style.filter = 'grayscale(100%)';";
    // 注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
       [wkUController addUserScript:wkUScript];
    // 配置对象
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    configuration = wkWebConfig;
    WKWebView *webView = [self lg_initWithFrame:frame configuration:configuration];
    return webView;
}


@end
