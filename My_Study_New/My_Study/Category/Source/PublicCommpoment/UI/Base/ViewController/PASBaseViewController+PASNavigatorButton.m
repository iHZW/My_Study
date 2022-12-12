//
//  PASBaseViewController+PASNavigatorButton.m
//  PASecuritiesApp
//
//  Created by vince on 2018/9/21.
//  Copyright © 2018年 PAS. All rights reserved.
//

#import "PASBaseViewController+PASNavigatorButton.h"
//#import "PASThirdInitManager.h"
//#import "PASOnlineBusinessController.h"

@implementation PASBaseViewController (PASNavigatorButton)

/**
 *  设置客服入口
 */
- (void)setNavigatorRightBtnForService {
    UIButton *serviceBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    serviceBtn.frame     = CGRectMake(0, 0, 50, 31);
    [serviceBtn addTarget:self action:@selector(action_gotoService) forControlEvents:(UIControlEventTouchUpInside)];
    [serviceBtn setImage:[UIImage imageNamed:@"top_icon_service"] forState:UIControlStateNormal];
    [serviceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:serviceBtn];
    [self.navigationItem addRightBarButtonItem:rightItem];
}
- (void)BI_gotoSevice:(NSString *)className
{

}

- (void)action_gotoService
{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    [self BI_gotoSevice:className];

//    [PASOnlineBusinessController openOnlineBusiness:className];

}

@end
