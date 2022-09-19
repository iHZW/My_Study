//
//  UIViewController+Additions.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UIViewController+Additions.h"
#import "ProgressHUD.h"
#import <objc/runtime.h>

@implementation UIViewController (Additions)

#pragma mark - Progress
- (void)showMessage:(NSString *)message{
    [self hideProgress];
    [ProgressHUD showMessage:message
                        inView:self.view];
}

- (MBProgressHUD *)showProgressInView:(UIView *)parentView{
    MBProgressHUD *hud = [ProgressHUD showHUDAddedTo:parentView title:@""];
    return hud;
}

- (void)showProgress{
    [ProgressHUD showHUDAddedTo:self.view];
}

- (void)showProgress:(NSString *)title{
    [ProgressHUD showHUDAddedTo:self.view
                            title:title];
}
- (void)hideProgress{
    [ProgressHUD hideHUDProgress:self.view];
}

- (void)hideProgressInView:(UIView *)parentView{
    [ProgressHUD hideHUDProgress:parentView];
}

- (void)showProgress:(UIView *)parentView title:(NSString *)title tapHandler:(TapPrgoressHandler)tapHandler{
    self.tapPrgoressHandler = tapHandler;
    MBProgressHUD *hud = [ProgressHUD showHUDAddedTo:parentView ?: self.view title:title];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchProgress:)];
    [hud addGestureRecognizer:tap];
}

- (void)touchProgress:(UIGestureRecognizer *)gesture{
    BlockSafeRun(self.tapPrgoressHandler);
}

- (void)setTapPrgoressHandler:(TapPrgoressHandler)tapPrgoressHandler{
    objc_setAssociatedObject(self, @selector(tapPrgoressHandler), tapPrgoressHandler, OBJC_ASSOCIATION_COPY);
}

- (TapPrgoressHandler)tapPrgoressHandler{
    return objc_getAssociatedObject(self, @selector(tapPrgoressHandler));
}

@end
