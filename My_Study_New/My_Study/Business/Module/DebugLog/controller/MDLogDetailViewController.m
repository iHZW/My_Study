//
//  MDLogDetailViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogDetailViewController.h"
#import "MDFileManager.h"
#import "MDLogManager.h"
#import "LogDAO.h"
#import <WebKit/WebKit.h>
#import "DateUtil.h"
#import "Toast.h"
#import "ZWCommonWebPage.h"

@interface MDLogDetailViewController ()

@property (nonatomic, strong) NSDictionary *info;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) ZWCommonWebPage *zwWebView;

@end

@implementation MDLogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日志详情";

    [self initUI];
        
    [self reloadData];
    
}

- (void)initUI{
    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 40, 40, 40)];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [backBtn setImage:[UIImage imageNamed:@"icon_nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
        
    UIButton *copyBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [copyBtn setTitle:@"复制" forState:UIControlStateNormal];
    [copyBtn setTitleColor:UIColorFromRGB(0x6495ED) forState:UIControlStateNormal];
    [copyBtn addTarget:self action:@selector(copyRequestMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *copyBarButton = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(copyRequestMethod:)];
    copyBarButton = [[UIBarButtonItem alloc] initWithCustomView:copyBtn];
    
    self.navigationItem.rightBarButtonItem = copyBarButton;
    
//    self.zwWebView.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - kMainNavHeight - kSysStatusBarHeight);
    [self addChildViewController:self.zwWebView];
    [self.view addSubview:self.zwWebView.view];
    
//    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - kMainNavHeight - kSysStatusBarHeight)];
//    [self.view addSubview:self.webView];
//
    [self.zwWebView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    UIButton *upButton = [[UIButton alloc] init];
    [upButton setBackgroundImage:[UIImage imageNamed:@"Icon_Log_Up"] forState:UIControlStateNormal];
    [upButton addTarget:self action:@selector(btnUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upButton];
    
    UIButton *downButton = [[UIButton alloc] init];
    [downButton setBackgroundImage:[UIImage imageNamed:@"Icon_Log_Down"] forState:UIControlStateNormal];
    [downButton addTarget:self action:@selector(btnDownAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downButton];
    
    [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        make.width.height.equalTo(@50);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
    }];
    
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(downButton.mas_top).offset(-20);
        make.width.height.equalTo(@50);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
    }];
    
}


- (void)reloadData{
    LogModel *logModel = [LogDAO queryLogDetails:self.identity];

    self.title = [NSString stringWithFormat:@"%@ - %lu",logModel.flag,(unsigned long)self.identity];
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
//                            "<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\" name=\"viewport\">\n"
                            "<style type=\"text/css\"> \n"
                            "body {-webkit-text-size-adjust:100%}\n"
                            "textarea {width:100%%; height:100%%;border-width: 0px;font-size: 50px;}\n"
                            "</style> \n"
                            "</head> \n"
                            "<body>"
                            "<textarea readonly>Context:%@<br/>时间:%@ <br/><br/>%@</textarea>"
                            "</body>"
                            "</html>",
                            logModel.context,
                            [DateUtil prettyDateStringForDate:logModel.createTime],
                            logModel.msg];
    
    [self.zwWebView.webView loadHTMLString:htmlString baseURL:nil];
//    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (IBAction)btnUpAction:(id)sender{
    NSUInteger identity = self.queryIdentityBlock(YES,self.index);
    if (identity != NSNotFound){
           self.index = self.index - 1;
           self.identity = identity;
           [self reloadData];
       }
}

- (IBAction)btnDownAction:(id)sender{
    NSUInteger identity =  self.queryIdentityBlock(NO,self.index);
    if (identity != NSNotFound){
        self.index = self.index + 1;
        self.identity = identity;
        [self reloadData];
    }
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  点击复制
 */
- (void)copyRequestMethod:(id)sender{
    
    /** 加载白屏  */
    [self.zwWebView loadUrlString:@"http://people.mozilla.org/~rnewman/fennec/mem.html"];
    
//    LogModel *logModel = [LogDAO queryLogDetails:self.identity];
//
//    NSString *copyString = logModel.msg;
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    if (copyString) {
//        [pasteboard setString:copyString];
//        [Toast show:@"复制成功"];
//    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePopToRoot:) name:@"kPASWebViewNSControllerWillPopToRootNotification" object:nil];
    
    if (!CGAffineTransformIsIdentity(self.view.transform)) {
        [self showVertical];
    }
}


/**< 切换横竖屏 */
- (void)showHorizon
{
//    if ([[[UIDevice currentDevice] systemVersion]hasPrefix:@"6"])//解决ios6横屏状态栏不消失bug
//    {
//        if (!_horWindow) {
//            _horWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//            _horWindow.windowLevel = UIWindowLevelStatusBar+1;
//            _horWindow.backgroundColor = self.view.backgroundColor;
//        }
//        verticalSuperView = self.view.superview;
//        [_horWindow addSubview:self.view];
//        [_horWindow makeKeyAndVisible];
//        _horWindow.hidden = NO;
//    }
//    self.disableScreenEdgeGesture       = YES;
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
    [UIViewController attemptRotationToDeviceOrientation];
    
}

- (void)showVertical
{
//    if ([[[UIDevice currentDevice] systemVersion]hasPrefix:@"6"])//解决ios6横屏状态栏不消失bug
//    {
//        _horWindow.hidden = YES;
//        [verticalSuperView addSubview:self.view];
//    }
//    self.disableScreenEdgeGesture       = NO;
    
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /** 离开页面保证竖屏  */
//    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
//    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /** 离开页面保证竖屏  */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kPASWebViewNSControllerWillPopToRootNotification" object:nil];
    [self showVertical];
    
}

#pragma mark - lazyLoad
- (ZWCommonWebPage *)zwWebView
{
    if (!_zwWebView) {
        _zwWebView  = [[ZWCommonWebPage alloc] init];
    }
    return _zwWebView;
}


#pragma mark - Rotational
- (void)handlePopToRoot:(NSNotification *)notify
{
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    if (ori != UIInterfaceOrientationPortrait) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
}


#pragma mark - IOS6 Rotation

- (BOOL)shouldAutorotate
{
    return (self.navigationController.topViewController == self) ? YES : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
