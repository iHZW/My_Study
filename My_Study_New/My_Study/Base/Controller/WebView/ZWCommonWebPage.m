//
//  ZWCommonWebPage.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCommonWebPage.h"
#import "URLUtil.h"
#import "ZWNative.h"
#import "GCDCommon.h"
#import "UIImage+Addition.h"
#import "WKWebViewConfiguration+Conslog.h"
#import "JSWeakObject.h"
#import <TDWebViewSwipeBack/UIViewController+GCWebViewSwipeBack.h>
#import "UIViewController+Gesture.h"


typedef NS_ENUM(NSUInteger,webviewLoadingStatus) {
    
    WebViewNormalStatus = 0, //正常
    
    WebViewErrorStatus, //白屏
    
    WebViewPendStatus, //待决
};


@interface ZWCommonWebPage () <WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZWWebView *webView;

@property (nonatomic ,strong) ZWNative * native;

@property (nonatomic, strong) NSURL *nsurl;

@property (nonatomic, assign) BOOL videoFullScreen;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftSwipGes;

@property (nonatomic, strong) UIControl *leftControl;

@end

@implementation ZWCommonWebPage

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initExtendedData
{
    [super initExtendedData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];

    [self loadData];

    //    [self regiseterNotification];

//        [self addWkwebView:self.webView swipeBackAble:YES];
    
//    self.leftSwipGes = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipGesAction:)];
//    self.leftSwipGes.edges = UIRectEdgeLeft;
//    self.leftSwipGes.delegate = self;
//    [self.webView addGestureRecognizer:self.leftSwipGes];
    
    NSLog(@"self.webView.gestureRecognizers = %@",self.webView.gestureRecognizers);
}


- (void)leftSwipGesAction:(UISwipeGestureRecognizer *)ges {
    if (UIGestureRecognizerStateEnded == ges.state) {
        if (self.webView.backForwardList.backList.count > 0) {
            WKBackForwardListItem *item = self.webView.backForwardList.backList.lastObject;
            if (![self.webView.URL.absoluteString isEqualToString:self.url]) {
                [self.webView goToBackForwardListItem:item];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                [self.webView goToBackForwardListItem:item];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)leftSwipeGesAction2:(UISwipeGestureRecognizer *)swipeGes {
    if (UIGestureRecognizerStateEnded == swipeGes.state) {
        if (self.webView.backForwardList.backList.count > 0) {
            WKBackForwardListItem *item = self.webView.backForwardList.backList.lastObject;
            if (![self.webView.URL.absoluteString isEqualToString:self.url]) {
                [self.webView goToBackForwardListItem:item];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                [self.webView goToBackForwardListItem:item];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)willMoveToParentViewController:(UIViewController*)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        
    }
}
- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
    
    if(!parent){
        NSLog(@"离开了页面");
    }
}


- (void)regiseterNotification {
    /// 监听全屏
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoBeginFullScreen)
                                                 name:UIWindowDidResignKeyNotification
                                               object:nil];
    /// 监听结束全屏
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoStopFullScreen)
                                                         name:UIWindowDidBecomeHiddenNotification
                                                       object:nil];
}



- (void)loadSubViews
{
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.leftControl];

    [self.leftControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(15);
    }];
}

- (void)willResignActive
{
    if ([self isVisible]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)didBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    if ([self isVisible]) { // viewController is visible
        /** 从后台进去app, 检测白屏  */
        
        
    }
}



- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.title = titleName;
}

- (void)setUrl:(NSString *)url
{
    _url = url;
}


/** 加载数据  */
- (void)loadData
{
    NSString *url = [self getRouterUrl];
    if (url.length > 0) {
        if (![url hasPrefix:@"http"]) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
    } else {
        url = self.url;
    }
    [self loadUrlString:url];
}

/** 加载url  */
- (void)loadUrlString:(NSString *)urlString{
    NSURL *url = [URLUtil formateToGetURL:urlString];
    self.nsurl = url;
    if (url){
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

/** 加载url  */
- (void)loadUrl:(NSURL *)url {
    self.nsurl = url;
    if (url){
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}


- (ZWWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.showConsole = YES;
        _webView = [[ZWWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _webView.navigationDelegate  = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.userInteractionEnabled = YES;
    }
    return _webView;
}

- (ZWNative *)native
{
    if (!_native) {
        _native = [[ZWNative alloc] init];
    }
    return _native;
}

- (UIControl *)leftControl {
    if (!_leftControl) {
        _leftControl = [[UIControl alloc] initWithFrame:CGRectZero];
        _leftControl.userInteractionEnabled = YES;
        _leftControl.backgroundColor = UIColor.cyanColor;
        
        /** 侧边栏添加左划手势,支持WKWebView侧滑逐级返回  */
        UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesAction2:)];
        [_leftControl addGestureRecognizer:swipeGes];
    }
    return _leftControl;
}

#pragma mark - 获取路由中的参数
- (NSString *)getRouterUrl{
    return __String_Not_Nil([self.routerParams objectForKey:@"url"]);
}

- (void)getCurrRoutePathCompletionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;{
    [self.webView evaluateJavaScript:@"window.WRouter.getCurrRoutePath()" completionHandler:completionHandler];
}


- (NSString *)apiGroup
{
    return [NSString stringWithFormat:@"%p", self.native];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /** 判断title为空  */
    [self checkWebViewhiteScreen];
    
    [UIViewController popGestureClose:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIViewController popGestureOpen:self];
}

/**
 *  1: 当 WKWebView 总体内存占用过大，页面即将白屏的时候，
 *  系统会调用`-webViewWebContentProcessDidTerminate:`回调函数，
 *  然后在该函数里执行`[webView reload]`去解决白屏问题。

 *
 *  @param <#parameter#>    <#annotation#>
 *  @param  <#parameter#>    <#annotation#>
 *
 */

/**
 *  检测白屏
 *  1: 判断webView.title 是否存在
 *  2: 截取导航栏以下, tabBar以上内容判断是否95%以上是白色
 *  3: 通过WKWebView  的代理 webViewWebContentProcessDidTerminate  来白屏
 */
- (void)checkWebViewhiteScreen
{
    /** 检测webView 的 title是否存子啊  */
    if (!self.webView.title) {
        [self gatherWhiteScreenInfo];
        if (!self.webView.URL) {
            NSLog(@"self.webView.URL 不存在");
        }
        NSLog(@"self.webView.URL = %@--- viewWillAppear", self.webView.URL);
        if (self.nsurl) {
            NSURLRequest * request = [NSURLRequest requestWithURL:self.nsurl];
            [self.webView loadRequest:request];
        }
    } else {
        @pas_weakify_self
        performBlockDelay(dispatch_get_main_queue(), .5, ^{
            @pas_strongify_self
            [self judgeLoadingStatus:self.webView withBlock:^(webviewLoadingStatus status) {
                @pas_strongify_self
                if (WebViewErrorStatus) {
                    /** 白屏  */
                    [self gatherWhiteScreenInfo];
                }
                NSLog(@"self.webView.URL = %@ --- self.webView.title = %@ -- status = %@", self.webView.URL, self.webView.title, @(status));
            }];
        });
    }
}

/**
 *  收集白屏信息
 */
- (void)gatherWhiteScreenInfo
{
    /** 上传  */

    
}



// 获取标题
//- (void) getTitle {
//    @pas_weakify_self
//    NSString *titleJs = @"document.title";
//    [self.webView evaluateJavaScript:titleJs completionHandler:^(id result, NSError *error) {
//        @pas_strongify_self
//        if (error == nil) {
//            if (result != nil) {
//                NSString *resultString = [NSString stringWithFormat:@"%@", result];
////                self.title = resultString;
//            }
//        }
//    }];
//}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    [self getTitle];
    /** 网页之后0.5s检测白屏  */
    [self checkWebViewhiteScreen];
}

#pragma mark - 白屏检测
/** WebContent  Progress Crash */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    /** 进程被终止 说明白屏,   */
    [self checkWebViewhiteScreen];
    /** 进程被终止时   webView.URL 取值尚不为 nil 重新reload 解决白屏  */
    if (webView.URL) {
        [webView reload];
    }
}

/** 判断是否白屏  */
- (void)judgeLoadingStatus:(WKWebView *)webview
                 withBlock:(void (^)(webviewLoadingStatus status))completionBlock
{
    webviewLoadingStatus __block status = WebViewPendStatus;
    if (@available(iOS 11.0, *)) {
        if (webview && [webview isKindOfClass:[WKWebView class]]) {
            
            WKSnapshotConfiguration *shotConfiguration = [[WKSnapshotConfiguration alloc] init];
            shotConfiguration.rect = CGRectMake(0, SafeAreaTopStatusNavBarHeight, webview.bounds.size.width, (webview.bounds.size.height - SafeAreaTopStatusNavBarHeight - kMainTabbarHeight - SafeAreaBottomAreaHeight)); //仅截图检测导航栏以下和底部tabBar以上的部分
            [webview takeSnapshotWithConfiguration:shotConfiguration completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
                if (snapshotImage) {
                    UIImage *scaleImage = [self scaleImage:snapshotImage];
                    /** 保存图片到相册  */
//                    UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    
                    BOOL isWhiteScreen = [self searchEveryPixel:scaleImage];
                    if (isWhiteScreen) {
                       status = WebViewErrorStatus;
                    }else{
                       status = WebViewNormalStatus;
                    }
                }
                if (completionBlock) {
                    completionBlock(status);
                }
            }];
        }
    } else {
        /** 处理iOS 11 以下  截屏  */
        UIImage *screenShot = [self getScreenShot];
        if (screenShot) {
            UIImage *scaleImage = [self scaleImage:screenShot];
            /** 保存图片到相册  */
//            UIImageWriteToSavedPhotosAlbum(screenShot, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            BOOL isWhiteScreen = [self searchEveryPixel:scaleImage];
            if (isWhiteScreen) {
               status = WebViewErrorStatus;
            }else{
               status = WebViewNormalStatus;
            }
        }
        if (completionBlock) {
            completionBlock(status);
        }
    }
}

/** 获取截屏  */
- (UIImage *)getScreenShot
{
    return [UIImage screenShotsImageInView:self.webView size:CGSizeMake(CGRectGetWidth(self.webView.frame), CGRectGetHeight(self.webView.frame))];
}


#pragma mark -- <保存到相册>
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error) {
        msg = @"保存图片失败" ;
    }else {
        msg = @"保存图片成功" ;
    }
}

// 遍历像素点 白色像素占比大于95%认定为白屏
- (BOOL)searchEveryPixel:(UIImage *)image {
    CGImageRef cgImage = [image CGImage];
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage); //每个像素点包含r g b a 四个字节
    size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8 * buffer;
    if (data) {
        buffer = (UInt8*)CFDataGetBytePtr(data);
    } else {
        return NO;
    }
    
    int whiteCount = 0;
    int totalCount = 0;
    
    for (int j = 0; j < height; j ++ ) {
        for (int i = 0; i < width; i ++) {
            UInt8 * pt = buffer + j * bytesPerRow + i * (bitsPerPixel / 8);
            UInt8 red   = * pt;
            UInt8 green = *(pt + 1);
            UInt8 blue  = *(pt + 2);
//            UInt8 alpha = *(pt + 3);
        
            totalCount ++;
            if (red >= 254 && green >= 254 && blue >= 254) {
                whiteCount ++;
            }
        }
    }
    float proportion = (float)whiteCount / totalCount ;
    NSLog(@"当前像素点数：%d,白色像素点数:%d , 占比: %f",totalCount , whiteCount , proportion );
    if (proportion > 0.95) {
        return YES;
    }else{
        return NO;
    }
}

//缩放图片
- (UIImage *)scaleImage: (UIImage *)image {
    CGFloat scale = 0.2;
    CGSize newsize;
    newsize.width = floor(image.size.width * scale);
    newsize.height = floor(image.size.height * scale);
    if (@available(iOS 10.0, *))
    {
        UIGraphicsImageRenderer * renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newsize];
          return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
             
              [image drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
          }];
    }else{
        return image;
    }
}


#pragma mark - 处理视屏全屏
- (void)videoBeginFullScreen {
    self.videoFullScreen = YES;
    [self switchLaunchScreen:YES];

}

- (void)videoStopFullScreen {
    self.videoFullScreen       = NO;
    [self switchLaunchScreen:NO];
}


- (void)switchLaunchScreen:(BOOL)isLaunchScreen {
    
    if (@available(iOS 16.0, *)) {
        // setNeedsUpdateOfSupportedInterfaceOrientations 方法是 UIViewController 的方法
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *scene = [array firstObject];
        // 屏幕方向
        UIInterfaceOrientationMask orientation = isLaunchScreen ? UIInterfaceOrientationMaskLandscape: UIInterfaceOrientationMaskPortrait;
        UIWindowSceneGeometryPreferencesIOS *geometryPreferencesIOS = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientation];
        // 开始切换
        [scene requestGeometryUpdateWithPreferences:geometryPreferencesIOS errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"错误:%@", error);
        }];
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIDeviceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        [UIViewController attemptRotationToDeviceOrientation];
    }
}


@end
