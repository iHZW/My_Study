//
//  UIViewController+ZW.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UIViewController+ZW.h"
#import <objc/runtime.h>


@implementation UIViewController (ZW)

+ (NSDictionary *)ss_constantParams{
    return nil;
}

- (BOOL)hideNavigationBar{
    return [objc_getAssociatedObject(self, @selector(hideNavigationBar)) boolValue];
}

- (void)setHideNavigationBar:(BOOL)hideNavigationBar{
    objc_setAssociatedObject(self, @selector(hideNavigationBar), @(hideNavigationBar), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)disableAnimatePush{
    return [objc_getAssociatedObject(self, @selector(disableAnimatePush)) boolValue];
}

- (void)setDisableAnimatePush:(BOOL)disableAnimatePush{
    objc_setAssociatedObject(self, @selector(disableAnimatePush), @(disableAnimatePush), OBJC_ASSOCIATION_RETAIN);
}


- (UIImage *)navBarShadowImage{
    return objc_getAssociatedObject(self, @selector(navBarShadowImage));
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage{
    objc_setAssociatedObject(self, @selector(navBarShadowImage), navBarShadowImage, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)hideTabbar{
    return [objc_getAssociatedObject(self, @selector(hideTabbar)) boolValue];
}

- (void)setHideTabbar:(BOOL)hideTabbar{
    objc_setAssociatedObject(self, @selector(hideTabbar), @(hideTabbar), OBJC_ASSOCIATION_RETAIN);
}


- (BOOL)isRootPage{
    return [objc_getAssociatedObject(self, @selector(isRootPage)) boolValue];
}

- (void)setIsRootPage:(BOOL)isRootPage{
    objc_setAssociatedObject(self, @selector(isRootPage), @(isRootPage), OBJC_ASSOCIATION_RETAIN);
}


- (void)showOrHideTabbar:(BOOL)hideTabbar{
    if ((self.hideTabbar && hideTabbar) || (!self.hideTabbar && !hideTabbar)){
        return;
    }
//    self.tabIndicatorView.hidden = hideTabbar;
    self.hideTabbar = hideTabbar;
    self.tabBarController.tabBar.hidden = hideTabbar;
    [self tabbarViewDidUpdated];
}

- (void)tabbarViewDidUpdated{
    //tabbar 显示隐藏发生了改变; 子类覆盖方法
}

@end
