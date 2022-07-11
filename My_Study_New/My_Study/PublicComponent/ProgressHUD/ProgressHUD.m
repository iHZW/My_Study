//
//  ProgressHUD.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ProgressHUD.h"
#import "MBProgressHUD.h"
#import "ProgressCustomView.h"
#import "ProgressCustomLoadingView.h"

@implementation ProgressHUD

+ (void)showMessage:(NSString *)message
             inView:(UIView *)view{
    if ([message isKindOfClass:[NSString class]] == NO || message.length <= 0) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view?:[self displayWindow] animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor colorWithRed:0xC1/255.0 green:0xC1/255.0 blue:0xC1/255.0 alpha:0.9];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabel.text = message;
    hud.detailsLabel.textColor = [UIColor blackColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:15.0f];
    hud.margin = 15;
    hud.offset = CGPointMake(0, -33);
    
    [hud hideAnimated:YES
           afterDelay:2];
    
}

+ (void)showHUDAddedTo:(UIView *)view{
    [self showHUDAddedTo:view
                   title:@""];
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view
                            title:(NSString *)title{
    UIView *showView = view?:[self displayWindow];
    MBProgressHUD *hud = [MBProgressHUD HUDForView:showView]?:[MBProgressHUD showHUDAddedTo:showView animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [ProgressCustomLoadingView progressCustomView];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = UIColor.clearColor;//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    hud.margin = 15;
    hud.offset = CGPointMake(0, -25);
    hud.detailsLabel.text = title;
    hud.detailsLabel.textColor = [UIColor lightGrayColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:12.0f];
    
    return hud;
}

+ (void)hideHUDProgress:(UIView *)view{
    [MBProgressHUD hideHUDForView:view?:[self displayWindow]
                             animated:YES];
}

+ (void)hideHUDForView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view?:[self displayWindow]
                   animated:YES];
}


+ (void)showHUDForShowWindow{
    [self showHUDAddedTo:[self displayWindow]
                   title:@""];
}
+ (void)hideHUDForShowWindow{
    [self hideHUDForView:[self displayWindow]];
}

+ (UIWindow *)displayWindow{
    return [UIApplication sharedApplication].keyWindow;
}

@end
