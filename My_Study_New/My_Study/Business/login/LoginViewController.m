//
//  LoginViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LoginViewController.h"
#import "ZWUserAccountManager.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *btn = [UIButton buttonWithFrame:CGRectMake(100, 150, 200, 200) title:@"登录" font:PASFont(20) titleColor:UIColorFromRGB(0x111111) block:nil];
    
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(logAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)logAction
{
    ZWUserInfoModel *infoModel = [ZWUserInfoModel new];
    infoModel.pid = 100;
    infoModel.userWid = 100;
    [ZWUserAccountManager sharedZWUserAccountManager].currentUserInfo = infoModel;
    BlockSafeRun(self.loginCompleted);
}



@end
