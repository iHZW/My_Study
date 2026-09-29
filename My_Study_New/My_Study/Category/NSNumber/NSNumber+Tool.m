//
//  NSNumber+Tool.m
//  NBBankEHomeProject
//
//  Created by wsk on 2022/11/23.
//

#import "NSNumber+Tool.h"

static CGFloat _topToNavBar = 64.0;

NSString* const cg_user_default_key_iem_switch = @"user_default_key_iem_switch";

@implementation NSNumber (Tool)

static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}
#define md_safeAreaInsets sgm_safeAreaInset([[UIApplication sharedApplication] delegate].window)

+ (CGFloat)eh_safeTop {
    return md_safeAreaInsets.top;
}

+ (CGFloat)eh_safeTopToNavBar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _topToNavBar = (md_safeAreaInsets.top == 0) ? 20 : md_safeAreaInsets.top + 44.0;
    });
    return _topToNavBar;
}

+ (CGFloat)eh_safeBottom {
    return md_safeAreaInsets.bottom;
}

+ (CGFloat)eh_safeLeft {
    return md_safeAreaInsets.left;
}

+ (CGFloat)eh_safeRight {
    return md_safeAreaInsets.right;
}

+ (BOOL)eh_iphoneX {
    return [self eh_safeTop] > 20 || [self eh_safeLeft] > 0;
}

+ (CGFloat)eh_tabBarHeight {
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    CGFloat tabBarHeight = tabBarVC.tabBar.frame.size.height;
    return tabBarHeight;
}

/// 屏幕缩放比
+ (CGFloat)eh_screenScale {
    BOOL _switch = [[NSUserDefaults standardUserDefaults] boolForKey:cg_user_default_key_iem_switch];
    _switch= YES;
    if (_switch) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        return screenWidth/375.0;
    }
    else {
        return 1.0;
    }
}

@end
