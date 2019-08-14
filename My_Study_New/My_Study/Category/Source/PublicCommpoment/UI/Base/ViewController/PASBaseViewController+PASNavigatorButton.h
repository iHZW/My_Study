//
//  PASBaseViewController+PASNavigatorButton.h
//  PASecuritiesApp
//
//  Created by vince on 2018/9/21.
//  Copyright © 2018年 PAS. All rights reserved.
//

#import "PASBaseViewController.h"

@interface PASBaseViewController (PASNavigatorButton)

/**
 *  设置客服入口
 */
- (void)setNavigatorRightBtnForService;

- (void)action_gotoService;

- (void)BI_gotoSevice:(NSString *)className;
@end
