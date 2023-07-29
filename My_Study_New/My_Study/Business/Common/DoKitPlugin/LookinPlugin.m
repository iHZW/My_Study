//
//  LookinPlugin.m
//  CRM
//
//  Created by Zhiwei Han on 2022/4/22.
//  Copyright © 2022 CRM. All rights reserved.
//

#if DOKIT

#import "LookinPlugin.h"

#import <UIKit/UIKit.h>
#import "DoraemonKit.h"
#import "DoraemonHomeWindow.h"
#import "UIApplication+Ext.h"
#import "UIAlertUtil.h"

@implementation LookinPlugin

- (void)pluginDidLoad{
    [[DoraemonHomeWindow shareInstance] hide];
    [self loadLookin];
}

- (void)loadLookin
{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"Lookin功能列表" preferredStyle:UIAlertControllerStyleAlert];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"导出为 Lookin 文档" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"进入 2D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"进入 3D 模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
//    }]];
//
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *topViewController = [UIApplication topOfRootViewController];
    if (topViewController.presentingViewController) {
        [topViewController dismissViewControllerAnimated:YES completion:nil];
    }
//    topViewController = [UIApplication displayViewController];
    
    @pas_weakify_self
    [UIAlertUtil showAlertTitle:@"温馨提示"
                        message:@"Lookin功能列表"
              cancelButtonTitle:@"取消"
              otherButtonTitles:@[@"导出为 Lookin 文档", @"进入 2D 模式", @"进入 3D 模式"]
           alertControllerStyle:UIAlertControllerStyleActionSheet
                    actionBlock:^(NSInteger index) {
        @pas_strongify_self
        switch (index) {
            case 1:
            {
                /** 确定  */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
            }
                break;
            case 2:
            {
                /** 确定  */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
            }
                break;
            case 3:
            {
                /** 确定  */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
            }
                break;
                
            default:
                break;
        }
    } superVC:topViewController];
    
    
    
//    UIViewController *topViewController = [UIApplication topOfRootViewController];
//    [topViewController presentViewController:alert animated:YES completion:nil];
}

- (void)pluginDidLoad:(NSDictionary *)itemData{
    NSLog(@"LookinPlugin pluginDidLoad:itemData = %@",itemData);
}

@end

#endif
