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

@interface LeftDrawerViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

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


@end
