//
//  LoadingUtil.m
//  JCYProduct
//
//  Created by Howard on 15/10/21.
//  Copyright © 2015年 Howard. All rights reserved.
//

#import "LoadingUtil.h"
#import "MBProgressHUD.h"
#import "GCDCommon.h"
#import "SingletonTemplate.h"

NSTimeInterval pasLoadingTimeoutTimeInterval = 15.0;
static const NSInteger hudTag = 1000;

@interface LoadingUtil ()

@property (nonatomic, strong) MBProgressHUD *loadingView;

@end


@implementation LoadingUtil
DEFINE_SINGLETON_T_FOR_CLASS(LoadingUtil)

#pragma mark -- private method

- (void)addLoadingView:(NSString *)tipMessage
            parentView:(UIView *)parentView
               yOffset:(CGFloat)yOffset
         actionEnabled:(BOOL)actionEnabled
                 delay:(NSTimeInterval)delay
{
    if (self.loadingView)
    {
        [self.loadingView hideAnimated:YES];
//        [self.loadingView hide:YES];
        self.loadingView = nil;
    }
    self.loadingView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
//    self.loadingView.offset = CGPointMake(0, yOffset);
    self.loadingView.mode = tipMessage.length ? MBProgressHUDModeText : MBProgressHUDModeForPAS;
    self.loadingView.userInteractionEnabled = actionEnabled;
    self.loadingView.detailsLabel.text = tipMessage;
    self.loadingView.detailsLabel.font = [UIFont systemFontOfSize:16];
    [self.loadingView hideAnimated:NO afterDelay:delay];
}

- (void)addLoadingView:(NSString *)tipMessage parentView:(UIView *)parentView yOffset:(CGFloat)yOffset actionEnabled:(BOOL)actionEnabled
{
    [self addLoadingView:tipMessage parentView:parentView yOffset:yOffset actionEnabled:actionEnabled delay:pasLoadingTimeoutTimeInterval];
}

- (void)removeLoadingView:(BOOL)animated
{
    [self.loadingView hideAnimated:animated];
    self.loadingView = nil;
    
//    [MBProgressHUD hideHUDForView:view animated:YES];
}

/**
 *  获取当前展示的viewController
 *
 *  @return UIViewController
 */
+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    UIViewController *curVC = rootViewController;//[UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *topVC = nil;
    
    while (curVC)
    {
        if ([curVC isKindOfClass:[UINavigationController class]])
        {
            UIViewController *tmpVC = [(UINavigationController *)curVC topViewController];
            topVC = tmpVC.presentedViewController ? tmpVC.presentedViewController : tmpVC;
            curVC = tmpVC.presentedViewController;
            
            if ([curVC isKindOfClass:[UINavigationController class]])
            {
                topVC = curVC.presentedViewController ? curVC.presentedViewController : ([(UINavigationController *)curVC topViewController] ? [(UINavigationController *)curVC topViewController] : curVC);
                curVC = curVC.presentedViewController;
            }
            
        }
        else
        {
            topVC = curVC.presentedViewController ? curVC.presentedViewController : curVC;
            curVC = curVC.presentedViewController;
        }
    }
    
    return topVC;
}

#pragma mark -- Progress HUD


/**
 弹出自定义时长toast,隐藏调用hide

 @param tipMessage 内容为空，则显示加载条
 @param delay 多久消失
 */
+ (void)show:(NSString *)tipMessage delay:(NSTimeInterval)delay
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        // 先移除正在显示的,最多只显示一个
        [[[self class] sharedLoadingUtil] removeLoadingView:NO];
        
        // 再显示出来
        [[[self class] sharedLoadingUtil] addLoadingView:tipMessage parentView:curVC.view yOffset:0 actionEnabled:NO delay:delay];
    });
}

+ (void)show
{
    [self show:nil delay:pasLoadingTimeoutTimeInterval];
}

+ (void)showLoadingOnceEnableAction:(BOOL)bolEnableAction
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        
        [[self class] showLoadingInView:nil parentView:curVC.view yOffset:0 actionEnabled:bolEnableAction];
    });
}

+ (void)showWithouAct
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        
        [[self class] showLoadingInView:nil parentView:curVC.view yOffset:0 actionEnabled:YES];
    });
}

+ (void)hide
{
    performBlockOnMainQueue(NO, ^{
        [[[self class] sharedLoadingUtil] removeLoadingView:YES];
    });
}

+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView
{
    performBlockOnMainQueue(NO, ^{
        [[self class] showLoadingInView:tipMessage parentView:parentView yOffset:0];
    });
}

+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView yOffset:(CGFloat)yOffset
{
    performBlockOnMainQueue(NO, ^{
        [[self class] showLoadingInView:tipMessage parentView:parentView yOffset:yOffset actionEnabled:NO];
    });
}

+ (void)showLoadingInView:(NSString *)tipMessage parentView:(UIView *)parentView yOffset:(CGFloat)yOffset actionEnabled:(BOOL)actionEnabled
{
    performBlockOnMainQueue(NO, ^{
        // 先移除正在显示的,最多只显示一个
        [[[self class] sharedLoadingUtil] removeLoadingView:NO];
        
        // 再显示出来
        [[[self class] sharedLoadingUtil] addLoadingView:tipMessage parentView:parentView yOffset:yOffset actionEnabled:actionEnabled];
    });
}

+ (void)showLoadingInView:(NSString *)tipMessage
               parentView:(UIView *)parentView
                  yOffset:(CGFloat)yOffset
            actionEnabled:(BOOL)actionEnabled
                    delay:(NSTimeInterval)delay
{
    performBlockOnMainQueue(NO, ^{
        // 先移除正在显示的,最多只显示一个
        [[[self class] sharedLoadingUtil] removeLoadingView:NO];
        
        // 再显示出来
        [[[self class] sharedLoadingUtil] addLoadingView:tipMessage parentView:parentView yOffset:yOffset actionEnabled:actionEnabled delay:delay];
    });
}

#pragma mark -- Toast tip
+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName{
    performBlockOnMainQueue(NO, ^{
        [[self class] showToastTip:tipMessage withCustomImageName:imageName afterDelay:2.0];
    });
}

+ (void)showToastTip:(NSString *)tipMessage
{
    performBlockOnMainQueue(NO, ^{
        [[self class] showToastTip:tipMessage withCustomImageName:nil afterDelay:2.0];
    });
}

+ (void)showToastTip:(NSString *)tipMessage  afterDelay:(NSTimeInterval)delay
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        [self showToastTip:tipMessage  withCustomImageName:nil viewController:curVC afterDelay:delay];
    });
}

+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName afterDelay:(NSTimeInterval)delay
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        [self showToastTip:tipMessage  withCustomImageName:imageName viewController:curVC afterDelay:delay];
    });
}

+ (void)showToastTip:(NSString *)tipMessage viewController:(UIViewController *)viewController afterDelay:(NSTimeInterval)delay{
    
    [[self class] showToastTip:tipMessage withCustomImageName:nil viewController:viewController afterDelay:delay];
    
}

+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName viewController:(UIViewController *)viewController afterDelay:(NSTimeInterval)delay
{
    [self showToastTip:tipMessage withCustomImageName:imageName inView:viewController.view afterDelay:delay];
}


+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName inView:(UIView *)inView afterDelay:(NSTimeInterval)delay bgColor:(UIColor *)bgColor
{
    performBlockOnMainQueue(NO, ^{
        if ([tipMessage length] > 0 && inView)
        {
            //        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
            UIView *view = inView;
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
            HUD.userInteractionEnabled = NO;
            HUD.tag = hudTag;
            HUD.offset = CGPointMake(0, -45);//view.center.y-rootVC.view.center.y;
            [view addSubview:HUD];
            if (bgColor) {
                HUD.backgroundColor = bgColor;
            }
            HUD.detailsLabel.text = tipMessage;
            HUD.mode = imageName.length==0?MBProgressHUDModeText:MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            HUD.detailsLabel.font = [UIFont systemFontOfSize:16];
           
            
            performBlockDelay(dispatch_get_main_queue(), delay, ^{
                [HUD removeFromSuperview];
            });
        }
    });
}

+ (void)showToastTip:(NSString *)tipMessage withCustomImageName:(NSString *)imageName inView:(UIView *)inView afterDelay:(NSTimeInterval)delay
{
    [self showToastTip:tipMessage withCustomImageName:imageName inView:inView afterDelay:delay bgColor:nil];
}

/**
 *  隐藏当前viewController 中原toast提示
 *
 *  @param animate 是否显示动画
 */
+ (void)hideToastTip:(BOOL)animate
{
    performBlockOnMainQueue(NO, ^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIViewController *curVC = [[self class] topViewController:rootVC];
        
        __block UIView *toastView = nil;
        
        [curVC.view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[MBProgressHUD class]] && obj.tag == hudTag) {
                toastView = obj;
                *stop = YES;
            }
        }];
        
        if (animate)
        {
            [UIView animateWithDuration:.2 animations:^{
                toastView.alpha = .0;
            } completion:^(BOOL finished) {
                [toastView removeFromSuperview];
            }];
        }
        else
        {
            [toastView removeFromSuperview];
        }
    });
}

@end
