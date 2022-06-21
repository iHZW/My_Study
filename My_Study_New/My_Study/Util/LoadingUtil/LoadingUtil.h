//
//  LoadingUtil.h
//  JCYProduct
//
//  Created by Howard on 15/10/21.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval pasLoadingTimeoutTimeInterval;

@interface LoadingUtil : NSObject
//DEFINE_SINGLETON_T_FOR_HEADER(LoadingUtil)

#pragma mark -- Progress HUD

+ (void)show;
+ (void)showLoadingOnceEnableAction:(BOOL)bolEnableAction;

+ (void)showWithouAct;

+ (void)hide;

+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView;

+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView yOffset:(CGFloat)yOffset;

/**
 *  <#Description#>
 *  @param actionEnabled 是否响应点击
 */
+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView yOffset:(CGFloat)yOffset actionEnabled:(BOOL)actionEnabled;

#pragma mark -- Toast tip
/**
 *  显示Toast信息  顶部有图片
 *
 *  @param tipMessage toast内容
 *  @param imageName  图片名称
 */
+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName;
/**
 *  显示Toast信息
 *
 *  @param tipMessage toast 内容
 */
+ (void)showToastTip:(NSString *)tipMessage;

/**
 *  显示Toast信息
 *
 *  @param tipMessage toast 内容
 *  @param delay      延迟多少秒后消失
 */
+ (void)showToastTip:(NSString *)tipMessage afterDelay:(NSTimeInterval)delay;

/**
 *  显示Toast信息
 *
 *  @param tipMessage     toast 内容
 *  @param viewController viewcontroller
 *  @param delay          延迟多少秒后消失
 */
+ (void)showToastTip:(NSString *)tipMessage viewController:(UIViewController *)viewController afterDelay:(NSTimeInterval)delay;

/**
 *  隐藏当前viewController 中原toast提示
 *
 *  @param animate 是否显示动画
 */
+ (void)hideToastTip:(BOOL)animate;

/**
 *  显示Toast信息
 *
 *  @param tipMessage     toast 内容
 *  @param inView  view
 *  @param delay          延迟多少秒后消失
 */
+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName inView:(UIView *)inView afterDelay:(NSTimeInterval)delay;

/**
 弹出自定义时长toast
 
 @param tipMessage 内容为空，则显示加载条
 @param delay 多久消失
 */
+ (void)show:(NSString *)tipMessage delay:(NSTimeInterval)delay;

+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName inView:(UIView *)inView afterDelay:(NSTimeInterval)delay bgColor:(UIColor *)bgColor;
@end
