//
//  ZWCameraPreViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCameraPreViewController.h"
#import "PHAssetModel.h"
#import "ZWImageView.h"
#import "ZWImageUtil.h"

@interface ZWCameraPreViewController ()

@property (nonatomic ,strong) ZWImageView * imageView;

@end

@implementation ZWCameraPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)initviews{
    _imageView = [[ZWImageView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    _imageView.backgroundColor = [UIColor blackColor];
    [_imageView updateModel:self.data];
    [self.view addSubview:_imageView];
    
    
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(20, kMainScreenHeight - SafeAreaBottomAreaHeight - 100, 60, 60);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
     
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(kMainScreenWidth - 20 - 60, kMainScreenHeight - SafeAreaBottomAreaHeight - 100, 60, 60);
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
}

- (void)cancelAction{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)confirmAction{
    __weak ZWCameraPreViewController * weakSelf = self;
    [ZWImageUtil configPathWithModel:@[self.data] complete:^(NSArray<PHAssetModel *> * _Nonnull arr) {
        BlockSafeRun(self.completeHander,arr);
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}



@end
