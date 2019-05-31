//
//  IQViewModel.m
//  My_Study
//
//  Created by HZW on 2019/5/27.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "IQViewModel.h"

@interface IQViewModel ()

@property (nonatomic, copy, readwrite) NSString *userName;

@property (nonatomic, copy, readwrite) NSString *userPwd;

@end

@implementation IQViewModel


+ (IQViewModel *)demoViewWithName:(NSString *)userName
                          withPwd:(NSString *)userPwd
{
    IQViewModel *viewModel = [[IQViewModel alloc] init];
    viewModel.userName = userName;
    viewModel.userPwd = userPwd;
    return viewModel;
}

- (void)updateViewModelWithName:(NSString *)userName
                        withPwd:(NSString *)userPwd
{
    _userName = userName;
    _userPwd = userPwd;
}


@end
