//
//  FindViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "AlertHead.h"
#import "FindViewController.h"
#import "LoadingUtil.h"
#import "ZWWebView.h"
#import "ZWCommonWebPage.h"
#import <QMUIKit/QMUIKit.h>
#import "ZWLaunchManage.h"

static NSString * const ZWFindCustomURLDefaultsKey = @"ZWFindCustomURL";

typedef NS_ENUM(NSUInteger, UIBorderSideType) {
    UIBorderSideTypeAll    = 0,
    UIBorderSideTypeTop    = 1 << 0,
    UIBorderSideTypeLeft   = 1 << 1,
    UIBorderSideTypeRight  = 1 << 2,
    UIBorderSideTypeBottom = 1 << 3,
};

@interface FindViewController () <WKNavigationDelegate>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) ZWWebView *webView;

@property (nonatomic, strong) ZWCommonWebPage *webPage;
/** 名称  */
@property (nonatomic, copy) NSArray *nameArray;
/** 链接  */
@property (nonatomic, copy) NSArray *urlArray;
/** 电影网站数据源  */
@property (nonatomic, strong) NSMutableArray *dataArray;
/** 显示popup 视图  */
@property (nonatomic, strong) QMUIPopupMenuView *popupAtBarButtonItem;
/** 使用方法 2，以 UIWindow 的形式显示到界面上，这种无需默认隐藏，也无需 add 到某个 UIView 上  */
@property (nonatomic, strong) QMUIPopupMenuView *popupByWindow;

@property (nonatomic, strong) UIBarButtonItem *backForwardItem;

@property (nonatomic, strong) UIButton *backForwardBtn;

- (void)showCustomURLAlert;
- (nullable NSString *)normalizedWebURLString:(nullable NSString *)input;
- (void)showInvalidURLAlert;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VIP影视";
    [self loadNav];
    
//    [self.view addSubview:self.webView];
//    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.equalTo(self.view);
//    }];
    
    [self addChildViewController:self.webPage];
    [self.view addSubview:self.webPage.view];
    [self.webPage.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
    VideoModel *model = [self.dataArray firstObject];
    NSString *url     = TransToString(model.videoUrl);
    [self loadUrlString:url];
}

- (void)loadNav {
    //    QMUINavigationButton *navBtn = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeNormal title:@"切换"];
    //    UIBarButtonItem *btnItem     = [UIBarButtonItem qmui_itemWithButton:navBtn target:self action:@selector(rightAction)];

    //    QMUINavigationButton *navBtn = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeImage];
    //    [navBtn setImage:[UIImage imageNamed:@"icon_nav_switch"] forState:UIControlStateNormal];
    /** 切换网站  */
    UIImage *image           = [[UIImage imageNamed:@"icon_nav_switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *btnItem = [UIBarButtonItem qmui_itemWithImage:image target:self action:@selector(rightAction)];
    //    [self.navigationItem setRightBarButtonItem:btnItem];
    /** 前进后退  */
    UIImage *backForward     = [[UIImage imageNamed:@"icon_nav_switch_back_forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *backForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backForwardBtn setImage:backForward forState:UIControlStateNormal];
    [backForwardBtn addTarget:self action:@selector(backForwardAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backForwardItem = [[UIBarButtonItem alloc] initWithCustomView:backForwardBtn];

    //    UIBarButtonItem *backForwardItem = [UIBarButtonItem qmui_itemWithImage:image target:self action:@selector(backForwardAction)];
    self.backForwardItem = backForwardItem;
    self.backForwardBtn  = backForwardBtn;
    [self.navigationItem setRightBarButtonItems:@[backForwardItem, btnItem]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ZWLaunchManage sharedInstance].isVIP = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ZWLaunchManage sharedInstance].isVIP = NO;
}

- (void)rightAction {
    NSLog(@" right navbar action");
    /** 显示系统的actionsheet  */
    //    [self loadAlertSheet];
    /** 显示自定义的actionsheet  */
    //    [self showAlertView];
    /** 显示popview  */
    [self showPopView];
}

- (void)backForwardAction {
    [self.popupByWindow showWithAnimated:YES];
}

- (void)showPopView {
    if (self.popupAtBarButtonItem.isShowing) {
        [self.popupAtBarButtonItem hideWithAnimated:YES];
    } else {
        // 相对于右上角的按钮布局
        self.popupAtBarButtonItem.sourceBarItem = [self.navigationItem.rightBarButtonItems lastObject];
        [self.popupAtBarButtonItem showWithAnimated:NO];
    }
}

/** 显示自定义网址输入框。 */
- (void)showCustomURLAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"自定义网址"
                                                                              message:@"请输入完整网址；未填写协议时默认使用 https://"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    NSString *savedURL = [[NSUserDefaults standardUserDefaults] stringForKey:ZWFindCustomURLDefaultsKey];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"例如：https://example.com";
        textField.text = savedURL;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    __weak typeof(self) weakSelf = self;
    __weak UIAlertController *weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:@"打开"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(__unused UIAlertAction *action) {
        __strong typeof(weakSelf) self = weakSelf;
        NSString *input = weakAlertController.textFields.firstObject.text;
        NSString *urlString = [self normalizedWebURLString:input];
        if (urlString.length == 0) {
            // UIAlertAction 执行时输入框仍在退出，稍后展示错误提示可避免转场冲突。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showInvalidURLAlert];
            });
            return;
        }

        [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:ZWFindCustomURLDefaultsKey];
        [self loadUrlString:urlString];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 规范并校验用户输入的网址，仅允许 WebView 支持的 HTTP/HTTPS 地址。 */
- (nullable NSString *)normalizedWebURLString:(nullable NSString *)input {
    NSString *urlString = [input stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (urlString.length == 0) {
        return nil;
    }
    if ([urlString rangeOfString:@"://"].location == NSNotFound) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }

    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSString *scheme = components.scheme.lowercaseString;
    if ((![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) || components.host.length == 0) {
        return nil;
    }
    return components.URL.absoluteString;
}

- (void)showInvalidURLAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"网址无效"
                                                                              message:@"请输入有效的 HTTP 或 HTTPS 网址。"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 显示自定义的actionsheet  */
- (void)showAlertView {
    NSMutableArray *actionArr = [NSMutableArray array];
    AlertView *alertView      = [[AlertView alloc] init];
    alertView.actionType      = ActionTypeActionSheet;
    @pas_weakify_self for (int i = 0; i < self.nameArray.count; i++) {
        AlertAction *action = [AlertAction action:PASArrayAtIndex(self.nameArray, i) textColor:[UIColor colorFromHexString:@"#333333"] backgroudColor:[UIColor whiteColor] clickCallback:^{
            @pas_strongify_self
                [alertView hidden];
            /** 切换视频网站  */
            [self loadUrlString:PASArrayAtIndex(self.urlArray, i)];
        }];
        [actionArr addObject:action];
    }

    alertView.actions      = TransToArray(actionArr);
    alertView.footerAction = [AlertAction action:@"取消" textColor:[UIColor colorFromHexString:@"#999999"] backgroudColor:[UIColor whiteColor] clickCallback:^{
        [alertView hidden];
    }];
    [alertView show];
}

/** 显示系统的actionsheet  */
- (void)loadAlertSheet {
    @pas_weakify_self
        [UIAlertUtil showAlertTitle:@"请选择"
                            message:@"切换视频网站"
                  cancelButtonTitle:@"取消"
                  otherButtonTitles:self.nameArray
               alertControllerStyle:UIAlertControllerStyleActionSheet
                        actionBlock:^(NSInteger index) {
                            @pas_strongify_self if (index > 0) {
                                VideoModel *model = PASArrayAtIndex(self.dataArray, index - 1);
                                if (ValidString(model.videoUrl)) {
                                    [self loadUrlString:model.videoUrl];
                                }
                            }
                        }
                            superVC:self];
}

/** 加载url  */
- (void)loadUrlString:(NSString *)urlString {
    /** 显示loading  */
//    [LoadingUtil show];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webPage.webView loadRequest:request];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    /** 隐藏loading  */
//    [LoadingUtil hide];
}

#pragma mark - 数据源
- (NSArray *)getDefaultData {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.nameArray.count; i++) {
        NSString *name    = PASArrayAtIndex(self.nameArray, i);
        NSString *url     = PASArrayAtIndex(self.urlArray, i);
        VideoModel *model = [VideoModel createViewModel:name videoUrl:url];
        [arr addObject:model];
    }
    return arr;
}

- (ZWWebView *)webView {
    if (!_webView) {
        _webView                    = [[ZWWebView alloc] initWithFrame:CGRectZero];
        _webView.backgroundColor    = UIColorFromRGB(0xFFFFFF);
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (ZWCommonWebPage *)webPage {
    if (!_webPage) {
        _webPage = [[ZWCommonWebPage alloc] init];
        _webPage.view.frame = self.view.bounds;
    }
    return _webPage;
}

- (NSArray *)nameArray {
    if (!_nameArray) {
        NSArray *nameArray = @[@"VIP影视",
                               @"VIP电影院",
                               @"剧迷",
                               @"80s电影",
                               @"片库",
                               @"全景影院",
                               @"牛牛影院",
                               @"豌豆影院",
                               @"鸭奈飞影视",
                               @"电影导航网",
                               @"万能搜",
                               @"youtubeMusic",
                               @"deepseek",
                               @"AICode"];
        _nameArray         = nameArray;
    }
    return _nameArray;
}

- (NSArray *)urlArray {
    if (!_urlArray) {
        NSArray *urlArray = @[@"https://dhuangmi.com/",
                              @"https://www.xierizhi.cn/vod/tv/Q4Fpb07mRzHnNX.html",
                              @"https://gimy.video/",
                              @"https://www.bj-qdcg.com/",
                              @"https://www.qwshu.com/ms/1--hits---------.html",
                              @"https://www.quanjingyy.com/",
                              @"http://www.yhmjt.com/",
                              @"http://www.283bt.com/",
                              @"https://yanetflix.com/",
                              @"http://www.sody123.com/",
                              @"https://www.ahhhhfs.com/",
                              @"https://music.youtube.com",
                              @"https://chat.deepseek.com",
                              @"http://116.62.212.112:3000/playground"];
        _urlArray         = urlArray;
    }
    return _urlArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:TransToArray([self getDefaultData])];
    }
    return _dataArray;
}

- (QMUIPopupMenuView *)popupAtBarButtonItem {
    if (!_popupAtBarButtonItem) {
        // 在 UIBarButtonItem 上显示
        _popupAtBarButtonItem                               = [[QMUIPopupMenuView alloc] init];
        _popupAtBarButtonItem.automaticallyHidesWhenUserTap = YES; // 点击空白地方消失浮层
        _popupAtBarButtonItem.maximumWidth                  = 180;
        _popupAtBarButtonItem.shouldShowItemSeparator       = YES;
        _popupAtBarButtonItem.tintColor                     = [UIColor cyanColor];

        NSMutableArray *itemArray = [NSMutableArray array];
        @pas_weakify_self
        for (int i = 0; i < self.nameArray.count; i++) {
            QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil
                                                                             title:PASArrayAtIndex(self.nameArray, i)
                                                                           handler:^(QMUIPopupMenuButtonItem *_Nonnull aItem) {
                @pas_strongify_self
                /** 隐藏pop视图  */
                [aItem.menuView hideWithAnimated:YES];
                [self loadUrlString:PASArrayAtIndex(self.urlArray, i)];
            }];
            [itemArray addObject:item];
        }
        QMUIPopupMenuButtonItem *customItem = [QMUIPopupMenuButtonItem itemWithImage:nil
                                                                                title:@"自定义网址…"
                                                                              handler:^(QMUIPopupMenuButtonItem * _Nonnull aItem) {
            [aItem.menuView hideWithAnimated:NO];
            @pas_strongify_self
            // 等菜单完成隐藏后再弹出输入框，避免两个弹层发生转场冲突。
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCustomURLAlert];
            });
        }];
        [itemArray addObject:customItem];
        _popupAtBarButtonItem.items = TransToArray(itemArray);
    }
    return _popupAtBarButtonItem;
}

- (QMUIPopupMenuView *)popupByWindow {
    if (!_popupByWindow) {
        @pas_weakify_self
        _popupByWindow                               = [[QMUIPopupMenuView alloc] init];
        _popupByWindow.automaticallyHidesWhenUserTap = YES; // 点击空白地方消失浮层
        _popupByWindow.tintColor                     = [UIColor colorFromHexString:@"#FFFFFF"];
        _popupByWindow.maskViewBackgroundColor       = UIColorFromRGBA(0x111111, 0.45); // 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
        _popupByWindow.shouldShowItemSeparator       = YES;
        _popupByWindow.itemConfigurationHandler      = ^(QMUIPopupMenuView *aMenuView, QMUIPopupMenuButtonItem *aItem, NSInteger section, NSInteger index) {
            // 利用 itemConfigurationHandler 批量设置所有 item 的样式
            aItem.button.highlightedBackgroundColor = UIColorFromRGBA(0xFFFFFF, 0.2);
        };
        _popupByWindow.items = @[
            [QMUIPopupMenuButtonItem itemWithImage:[UIImage imageNamed:@"file_audio_icon"] title:@"前进网页" handler:^(QMUIPopupMenuButtonItem * _Nonnull aItem) {
                [aItem.menuView hideWithAnimated:YES];
                @pas_strongify_self if (self.webPage.webView.canGoForward) {
                    [self.webPage.webView goForward];
                }
            }],
//            [QMUIPopupMenuButtonItem itemWithImage:[UIImage imageNamed:@"file_audio_icon"] title:@"前进网页" titleColor:UIColor.blackColor handler:^(QMUIPopupMenuButtonItem *_Nonnull aItem) {
//                [aItem.menuView hideWithAnimated:YES];
//                @pas_strongify_self if (self.webPage.webView.canGoForward) {
//                    [self.webPage.webView goForward];
//                }
//            }],
            //            [QMUIPopupMenuButtonItem itemWithImage:[UIImage imageNamed:@"file_audio_icon"] title:@"前进网页" titleColor:UIColor.blackColor handler:^(QMUIPopupMenuButtonItem *aItem) {
            //                [aItem.menuView hideWithAnimated:YES];
            //                @pas_strongify_self
            //                if (self.webPage.webView.canGoForward) {
            //                    [self.webPage.webView goForward];
            //                }
            //            }],
            [QMUIPopupMenuButtonItem itemWithImage:[UIImage imageNamed:@"file_excel_icon"] title:@"后退网页" handler:^(QMUIPopupMenuButtonItem *aItem) {
                [aItem.menuView hideWithAnimated:YES];
                @pas_strongify_self if (self.webPage.webView.canGoBack) {
                    [self.webPage.webView goBack];
                }
            }]
        ];

        _popupByWindow.didHideBlock = ^(BOOL hidesByUserTap) {
            @pas_strongify_self
                /** NO: 用户点击浮层被隐藏   YES: 用户点击空白浮层被隐藏 */
                NSLog(@"hidesByUserTap = %@", @(hidesByUserTap));
        };
        _popupByWindow.sourceView = self.backForwardBtn; // 相对于 button4 布局
    }
    return _popupByWindow;
}

/** 默认不支持旋转  */
- (BOOL)shouldAutorotate
{
    return YES;
}

/** 默认竖屏  */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

/** 默认竖屏  */
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}


@end

@implementation VideoModel

+ (VideoModel *)createViewModel:(NSString *)name videoUrl:(NSString *)videoUrl {
    VideoModel *model = [[VideoModel alloc] init];
    model.name        = name;
    model.videoUrl    = videoUrl;
    return model;
}
@end
