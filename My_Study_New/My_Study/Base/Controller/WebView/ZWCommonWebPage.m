//
//  ZWCommonWebPage.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCommonWebPage.h"
#import "URLUtil.h"

@interface ZWCommonWebPage ()

@property (nonatomic, strong) ZWWebView *webView;


@end

@implementation ZWCommonWebPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    
    [self loadData];
}

- (void)loadSubViews
{
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(kSysStatusBarHeight + kMainNavHeight);
    }];
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
    if (url){
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}


- (ZWWebView *)webView
{
    if (!_webView) {
        _webView = [[ZWWebView alloc] initWithFrame:CGRectZero];
        _webView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    }
    return _webView;
}

#pragma mark - 获取路由中的参数
- (NSString *)getRouterUrl{
    return __String_Not_Nil([self.routerParams objectForKey:@"url"]);
}

@end
