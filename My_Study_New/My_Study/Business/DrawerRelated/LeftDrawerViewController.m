//
//  LeftDrawerViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/20.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LeftDrawerViewController.h"
#import "UIView+Create.h"
#import "UIViewController+CWLateralSlide.h"
#import "RunLoopViewController.h"
#import "LeftDrawerDataLoader.h"
#import "LeftDrawerModel.h"
#import "ZWCommonWebPage.h"

@interface LeftDrawerViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LeftDrawerDataLoader *dataLoader;

@property (nonatomic, strong) ZWCommonWebPage *zwWebPage;

@end

@implementation LeftDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.titleLabel];

    CGFloat height = (kMainNavHeight + kSysStatusBarHeight);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    NSArray *testArray = @[@"0", @"1", @"2"];
    NSUInteger index = [testArray indexOfObject:@"3"];
    if (index == NSNotFound) {
        index = 0;
    }
    NSLog(@"index = %@", @(index));
    
    NSString *str = @"下午 2";
    NSString *filterStr = TransFilterString(str, kNumbers);
    if ([str containsString:@"下午"] || [str containsString:@"PM"]) {
        NSUInteger current = [filterStr integerValue] + 12;
        filterStr = [NSString stringWithFormat:@"%@", @(current)];
    }
    NSLog(@"%@", filterStr);
    
    
    [self loadSubViews];
    
}

- (void)loadSubViews
{
    self.view.backgroundColor = [UIColor redColor];
    
    [self addChildViewController:self.zwWebPage];
    self.zwWebPage.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.zwWebPage.view];
    
    CGFloat webViewWidth = kMainScreenWidth *0.75;
    [self.zwWebPage.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(kMainNavHeight + kSysStatusBarHeight);
        make.width.mas_equalTo(webViewWidth);
    }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    @pas_weakify_self
    [self.dataLoader sendRequestDouBan:^(NSInteger status, id  _Nullable obj) {
        @pas_strongify_self
        NSString *str = (NSString *)obj;
        NSLog(@"str = %@",str);
        [self.zwWebPage.webView loadHTMLString:str baseURL:nil];
    }];
    
    /* 发送请求 */
//    [self.dataLoader sendRequestForInfoNewsHeadBanner:^(NSInteger status, LeftDrawerModel *obj) {
//        
//        if ([obj.status isEqualToString:@"1"]) {
//            /* 成功 */
//            ClientChatDataModel *chatModel = obj.data;
//            NSArray *chatDataInfoList = chatModel.chatDataInfoList;
//            ClientChatReccord *chatRecord = PASArrayAtIndex(chatDataInfoList, 0);
//            NSLog(@"msgtype = %@",chatRecord.msgtype);
//        } else {
//            /* 失败 */
//        }
//        NSLog(@"status = %@, --- obj = %@", @(status), obj);
//        
//    }];
}



- (void)tapActtion
{
    RunLoopViewController *vc = [RunLoopViewController new];
    [self cw_pushViewController:vc];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"push" textColor:UIColorFromRGB(0x333333)];
        _titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActtion)];
        [_titleLabel addGestureRecognizer:tap];
    }
    return _titleLabel;
}


- (LeftDrawerDataLoader *)dataLoader
{
    if (!_dataLoader) {
        _dataLoader = [[LeftDrawerDataLoader alloc] init];
    }
    return _dataLoader;
}

- (ZWCommonWebPage *)zwWebPage
{
    if (!_zwWebPage) {
        _zwWebPage = [[ZWCommonWebPage alloc] init];
    }
    return _zwWebPage;
}

@end
