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

@interface MDLogDetailViewController ()

@property (nonatomic, strong) NSDictionary *info;

@property (nonatomic, strong) WKWebView *webView;

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
        
    UIBarButtonItem *copyBarButton = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(copyRequestMethod:)];
    self.navigationItem.rightBarButtonItem = copyBarButton;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 88)];
//    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
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

    self.title = [NSString stringWithFormat:@"%@ - %ld",logModel.flag,self.identity];
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {font-size:50px;}\n"
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
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
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


- (void)copyRequestMethod:(id)sender{
    LogModel *logModel = [LogDAO queryLogDetails:self.identity];

    NSString *copyString = logModel.msg;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (copyString) {
        [pasteboard setString:copyString];
        [Toast show:@"复制成功"];
    }
}
@end
