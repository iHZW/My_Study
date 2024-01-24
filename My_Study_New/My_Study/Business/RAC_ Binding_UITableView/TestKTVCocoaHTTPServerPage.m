//
//  TestKTVCocoaHTTPServerPage.m
//  My_Study
//
//  Created by hzw on 2024/1/23.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "KTVCocoaHTTPServer/KTVCocoaHTTPServer.h"
#import "TestKTVCocoaHTTPServerPage.h"
#import "PathConstants.h"
#import "ZWCommonWebPage.h"

@interface TestKTVCocoaHTTPServerPage ()

#pragma mark - HTTPServer
/**本地服务器端口*/
@property(strong, nonatomic) NSString *serverPort;
/**本地服务器*/
@property(strong, nonatomic) HTTPServer *httpServer;
/**是否启动了本地服务器*/
@property(nonatomic, assign) BOOL startServerStatus;

@property (nonatomic, strong) ZWCommonWebPage *webPage;

@end

@implementation TestKTVCocoaHTTPServerPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"测试本地服务";
    
    self.view.backgroundColor = UIColor.whiteColor;

    [self _setUI];
}

- (void)_setUI {
    [self.view addSubview:self.webPage.view];
    [self.webPage.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(SafeAreaTopStatusNavBarHeight);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 开启本地服务器
    [self openServer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.startServerStatus) {
        self.startServerStatus = [self startServer];
    }
    
    [self _testLoadDebugHml];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.startServerStatus) { // 停止本地服务器
        [self stopServer];
    }
}


- (void)_testLoadDebugHml {
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString * webPath = [NSString stringWithFormat:@"%@/demo.html",hybridserverPath];
//    NSString * webPath = [NSString stringWithFormat:@"%@/debug1/debug.html",hybridserverPath];

    NSURL *webUrl = [NSURL fileURLWithPath:webPath];

    [self.webPage loadUrl:webUrl];
    return;
    
    
//    
////    NSString *str = [NSString stringWithFormat:@"http://localhost:%@/debug.html", self.serverPort];
////    NSString *str = [NSString stringWithFormat:@"http://localhost:%@", self.serverPort];
////    NSString *str = [NSString stringWithFormat:@"http://localhost:%@/debug1/debug1.html", self.serverPort];
//    NSString *str = [NSString stringWithFormat:@"http://localhost:%@/safe/index.html", self.serverPort];
//
////    NSString *str = [NSString stringWithFormat:@"http://0.0.0.0:%@/demo.html", self.serverPort];
////    NSString *str = [NSString stringWithFormat:@"http://localhost:%@/demo.html", self.serverPort];
//
//    NSURL *url = [NSURL URLWithString:str];
//
////    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
////    [self.webPage loadURLRequest:request];
//
//    [self.webPage loadUrl:url];

}




#pragma mark - HTTPServer

#pragma mark - 开启本地服务器
- (void)openServer {
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];
    NSInteger tempPort = 8080;
    [self.httpServer setPort:tempPort];               // 6080
    NSString *webPath = [PathConstants gcdWebServerRootDirectory]; //[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HtmlFile"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:webPath]) {
        NSLog(@"File path error!");
    } else {
        [self.httpServer setDocumentRoot:webPath];
        NSLog(@"服务器路径：%@", webPath);
        self.startServerStatus = [self startServer];
        // 本地服务器有时会启动失败，这里更改端口号直到启动成功
        if (self.startServerStatus == NO) {
            for (int i = 0; i < 20; i++) {
                [self.httpServer setPort:tempPort + i + 1]; // 6080
                self.startServerStatus = [self startServer];
                if (self.startServerStatus == YES) {
                    break;
                }
            }
        }
    }
}

#pragma mark - 启动服务
- (BOOL)startServer {
    BOOL ret = NO;
    NSError *error = nil;
    if ([self.httpServer start:&error]) {
        NSLog(@"HTTP服务器启动成功端口号为： %hu", [self.httpServer listeningPort]);
        self.serverPort = [NSString stringWithFormat:@"%d", [self.httpServer listeningPort]];
        ret = YES;
    } else {
        NSLog(@"启动HTTP服务器出错: %@", error);
    }
    return ret;
}

#pragma mark - 停止服务
- (void)stopServer {
    if (self.httpServer != nil) {
        [self.httpServer stop];
        self.startServerStatus = NO;
    }
}



#pragma mark -  Lazy loading
- (ZWCommonWebPage *)webPage {
    if (!_webPage) {
        _webPage = [[ZWCommonWebPage alloc] init];
    }
    return _webPage;
}

@end
