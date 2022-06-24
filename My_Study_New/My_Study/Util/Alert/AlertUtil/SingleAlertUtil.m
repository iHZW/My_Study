//
//  SingleAlertUtil.m
//  CRM
//
//  Created by js on 2019/12/6.
//  Copyright © 2019 js. All rights reserved.
//

#import "SingleAlertUtil.h"
#import "AlertView.h"
#import "UIAlertAction+Ext.h"
#import "ZWSDK.h"
#import "UIColor+Ext.h"
#import "UIApplication+Ext.h"


@interface SingleAlertUtil()
@property (nonatomic, assign) BOOL isShowed;
@end
@implementation SingleAlertUtil

+ (instancetype)sharedInstance{
    static SingleAlertUtil *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SingleAlertUtil alloc] init];
    });
    return _instance;
}

+ (void)confirm:(nullable NSString*)title
        msg:(nullable NSString *)msg
        okBlock:(void(^)(void))okBlock{
    if (![SingleAlertUtil sharedInstance].isShowed){
        AlertView *alertView = [[AlertView alloc] init];
        alertView.title = title;
        alertView.message = msg;
        alertView.disableBgTap = YES;
        alertView.actions = @[
           [AlertAction defaultConfirmAction:@"我知道了" clickCallback:^{
               [SingleAlertUtil sharedInstance].isShowed = NO;
                BlockSafeRun(okBlock);
               [alertView hidden];
           }]
        ];
        [alertView show];
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
//
//
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [SingleAlertUtil sharedInstance].isShowed = NO;
//            BlockSafeRun(okBlock);
//        }];
//        [alertController addAction:okAction];
//        [[UIApplication displayViewController] presentViewController:alertController animated:YES completion:nil];
        [SingleAlertUtil sharedInstance].isShowed = YES;
    }
}

+ (void)logoutChangeCorp:(nullable NSString*)title
                     msg:(nullable NSString *)msg
              cancelText:(NSString *)cancelText
             confirmText:(NSString *)confirmText
             cancelBlock:(void(^)(void))cancelBlock
            confirmBlock:(void(^)(void))okBlock{
    if (![SingleAlertUtil sharedInstance].isShowed){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [SingleAlertUtil sharedInstance].isShowed = NO;
            BlockSafeRun(cancelBlock);
        }];
        [cancelAction setTextColor:[UIColor colorFromHexCode:@"#FF5037"]];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SingleAlertUtil sharedInstance].isShowed = NO;
            BlockSafeRun(okBlock);
        }];
        [okAction setTextColor:[UIColor colorFromHexCode:@"#4F7AFD"]];
        [alertController addAction:okAction];
        [[UIApplication displayViewController] presentViewController:alertController animated:YES completion:nil];
        [SingleAlertUtil sharedInstance].isShowed = YES;
    }
}
@end
