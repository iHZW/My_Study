//
//  ProgressHUD.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "MBProgressHUD.h"


NS_ASSUME_NONNULL_BEGIN

@interface ProgressHUD : CMObject

+ (void)showMessage:(NSString *)message inView:(UIView *)view;

+ (void)showHUDAddedTo:(UIView *)view;

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view
                            title:(NSString *)title;

+ (void)hideHUDForView:(UIView *)view;

+ (void)hideHUDProgress:(UIView *)view;

+ (void)showHUDForShowWindow;

+ (void)hideHUDForShowWindow;

@end

NS_ASSUME_NONNULL_END
