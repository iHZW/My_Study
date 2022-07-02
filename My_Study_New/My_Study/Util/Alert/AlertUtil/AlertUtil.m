//
//  AlertUtil.m
//  CRM
//
//  Created by js on 2019/11/8.
//  Copyright © 2019 js. All rights reserved.
//

#import "AlertUtil.h"
#import "UIApplication+Ext.h"

@implementation AlertUtil
+ (void)confirm:(NSString*)title
            msg:(NSString *)msg
    cancelBlock:(void(^)(void))cancelBlock
        okBlock:(void(^)(void))okBlock{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BlockSafeRun(okBlock);
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            BlockSafeRun(cancelBlock);
        }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [[UIApplication displayViewController] presentViewController:alertController animated:YES completion:nil];
}
@end
