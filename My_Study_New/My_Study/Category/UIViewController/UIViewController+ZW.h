//
//  UIViewController+ZW.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,NavbarStyle) {
    NavbarStyleNone = 0, //没有阴影
    NavbarStyleLine = 1 //分割线
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZW)

@property (nonatomic, assign) BOOL hideNavigationBar;
/* 页面切换的时候是否开启使用系统push 动画 */
@property (nonatomic, assign) BOOL disableAnimatePush;

@property (nonatomic, strong,nullable) UIImage *navBarShadowImage;

@property (nonatomic, assign) BOOL hideTabbar;
/** 最底层的页面 */
@property (nonatomic, assign) BOOL isRootPage;

+ (NSDictionary *)ss_constantParams;

/**
 显示隐藏 tabbar
 */
- (void)showOrHideTabbar:(BOOL)hideTabbar;

@end

NS_ASSUME_NONNULL_END
