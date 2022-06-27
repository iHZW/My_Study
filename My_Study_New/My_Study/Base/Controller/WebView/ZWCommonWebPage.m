//
//  ZWCommonWebPage.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/26.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCommonWebPage.h"


@interface ZWCommonWebPage ()

@property (nonatomic, strong) ZWWebView *webView;


@end

@implementation ZWCommonWebPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
}

- (void)loadSubViews
{
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(kSysStatusBarHeight + kMainNavHeight);
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (ZWWebView *)webView
{
    if (!_webView) {
        _webView = [[ZWWebView alloc] initWithFrame:CGRectZero];
    }
    return _webView;
}

@end
