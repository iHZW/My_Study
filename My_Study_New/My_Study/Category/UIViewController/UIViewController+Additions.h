//
//  UIViewController+Additions.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef dispatch_block_t TapPrgoressHandler;

@class MBProgressHUD;
@interface UIViewController (Additions)

@property (nonatomic,copy,nullable) TapPrgoressHandler tapPrgoressHandler;
- (void)showMessage:(NSString *)message;
- (MBProgressHUD *)showProgressInView:(UIView *)parentView;
- (void)showProgress;
- (void)showProgress:(NSString *)title;
- (void)hideProgress;
- (void)hideProgressInView:(UIView *)parentView;
- (void)showProgress:(nullable UIView *)parentView title:(NSString *)title tapHandler:(TapPrgoressHandler)tapHandler;

@end

NS_ASSUME_NONNULL_END
