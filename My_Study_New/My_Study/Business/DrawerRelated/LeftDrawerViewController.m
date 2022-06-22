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

@interface LeftDrawerViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LeftDrawerDataLoader *dataLoader;

@end

@implementation LeftDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* 发送请求 */
    [self.dataLoader sendRequestForInfoNewsHeadBanner:^(NSInteger status, LeftDrawerModel *obj) {
        
        if ([obj.status isEqualToString:@"1"]) {
            /* 成功 */
            ClientChatDataModel *chatModel = obj.data;
            NSArray *chatDataInfoList = chatModel.chatDataInfoList;
            ClientChatReccord *chatRecord = PASArrayAtIndex(chatDataInfoList, 0);
            NSLog(@"msgtype = %@",chatRecord.msgtype);
        } else {
            /* 失败 */
        }
        NSLog(@"status = %@, --- obj = %@", @(status), obj);
        
    }];
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

@end
