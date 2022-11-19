//
//  FindViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FindViewController.h"
#import "ZWWebView.h"
#import <QMUIKit/QMUIKit.h>
#import "AlertHead.h"
#import "LoadingUtil.h"


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
/** 名称  */
@property (nonatomic, copy) NSArray *nameArray;
/** 链接  */
@property (nonatomic, copy) NSArray *urlArray;
/** 电影网站数据源  */
@property (nonatomic, strong) NSMutableArray *dataArray;
/** 显示popup 视图  */
@property (nonatomic, strong) QMUIPopupMenuView *popupAtBarButtonItem;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VIP影视";
    [self loadNav];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    UIImage *image           = [[UIImage imageNamed:@"icon_nav_switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *btnItem = [UIBarButtonItem qmui_itemWithImage:image target:self action:@selector(rightAction)];
    [self.navigationItem setRightBarButtonItem:btnItem];
}

- (void)rightAction {
    NSLog(@" right navbar action");
    /** 显示系统的actionsheet  */
    //    [self loadAlertSheet];
    /** 显示自定义的actionsheet  */
    [self showAlertView];
    /** 显示popview  */
    //    [self showPopView];
}

- (void)showPopView {
    if (self.popupAtBarButtonItem.isShowing) {
        [self.popupAtBarButtonItem hideWithAnimated:YES];
    } else {
        // 相对于右上角的按钮布局
        self.popupAtBarButtonItem.sourceBarItem = self.navigationItem.rightBarButtonItem;
        [self.popupAtBarButtonItem showWithAnimated:YES];
    }
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
    [LoadingUtil show];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    /** 隐藏loading  */
    [LoadingUtil hide];
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

- (NSArray *)nameArray {
    if (!_nameArray) {
        NSArray *nameArray = @[@"VIP影视",
                               @"VIP电影院",
                               @"80s电影",
                               @"片库",
                               @"全景影院",
                               @"牛牛影院",
                               @"豌豆影院",
                               @"鸭奈飞影视",
                               @"电影导航网"];
        _nameArray         = nameArray;
    }
    return _nameArray;
}

- (NSArray *)urlArray {
    if (!_urlArray) {
        NSArray *urlArray = @[@"https://dhuangmi.com/",
                              @"https://www.xierizhi.cn/vod/tv/Q4Fpb07mRzHnNX.html",
                              @"https://www.bj-qdcg.com/",
                              @"https://www.qwshu.com/ms/1--hits---------.html",
                              @"https://www.quanjingyy.com/",
                              @"http://www.yhmjt.com/",
                              @"http://www.283bt.com/",
                              @"https://yanetflix.com/",
                              @"http://www.sody123.com/"];
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
        @pas_weakify_self for (int i = 0; i < self.nameArray.count; i++) {
            QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem
                itemWithImage:nil
                        title:PASArrayAtIndex(self.nameArray, i)
                      handler:^(QMUIPopupMenuButtonItem *_Nonnull aItem) {
                          /** 隐藏pop视图  */
                          [aItem.menuView hideWithAnimated:YES];
                          @pas_strongify_self
                              [self loadUrlString:PASArrayAtIndex(self.urlArray, i)];
                      }];
            [itemArray addObject:item];
        }
        _popupAtBarButtonItem.items = TransToArray(itemArray);
    }
    return _popupAtBarButtonItem;
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
