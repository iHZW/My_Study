//
//  PermissionIntercept.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionIntercept.h"
#import "AlertView.h"
#import "UIApplication+Ext.h"

@implementation PermissionIntercept

- (void)request:(id<PermissionProtocol>)permission notAuthorizedMessage:(NSString *)message complete:(void (^)(void))block{
    if ([permission isAuthorized]){
        BlockSafeRun(block);
    } else {
        [self notAuthorized:permission notAuthorizedMessage:message complete:block];
    }
}

//无权限引导弹框
- (void)notAuthorized:(id<PermissionProtocol>)permission notAuthorizedMessage:(NSString *)message complete:(void (^)(void))block{
//    if (Session.userSession.accountId == kkAccountID){
//        [self systemRequest:permission complete:block];
//    } else
    {
        //还没有请求给权限,权限已经拒绝，跳转拒绝弹框
        [self showAlert:@"温馨提示"
                message:message
            cancelTitle:@"取消" cancelClick:^{
            //直接回调，权限状态不该
            BlockSafeRun(block);
        } okTitle:@"去设置" okClick:^{
            [self systemRequest:permission complete:block];
        }];
    }
}

//调用系统方法开始请求权限
- (void)systemRequest:(PermissionObject)permission complete:(void (^)(void))block{
    if ([permission isAuthorized]){
        BlockSafeRun(block);
    } else if ([permission isDenied]){
        //未设置过， 请求系统弹框
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        [permission request:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                BlockSafeRun(block);
            });
            
        }];
    }
}

//弹框，显示文案
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
      cancelClick:(dispatch_block_t)cancelClick
          okTitle:(NSString *)okTitle
          okClick:(dispatch_block_t)okClick{
    AlertView *alertView = [[AlertView alloc] init];
    alertView.autoCloseClicked = YES;
    alertView.disableBgTap = YES;
    alertView.title = title;
    alertView.message = message;
    
//    if (Session.userSession.accountId == kkAccountID){
//        //To Apple
//        alertView.actions = @[
//            [AlertAction defaultConfirmAction:okTitle clickCallback:okClick]
//        ];
//    } else
    {
        alertView.actions = @[
            [AlertAction defaultNormalAction:cancelTitle clickCallback:cancelClick],
            [AlertAction defaultConfirmAction:okTitle clickCallback:okClick]
        ];
    }

    UIViewController *presentedVC = [UIApplication rootViewController].presentedViewController;
    UIView *parentView = presentedVC ? presentedVC.view : [UIApplication rootViewController].view;
    [alertView showInView:parentView];
}

@end
