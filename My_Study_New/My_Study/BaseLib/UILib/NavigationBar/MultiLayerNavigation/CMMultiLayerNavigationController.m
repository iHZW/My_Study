//
//  CMMultiLayerNavigationController.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMMultiLayerNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIViewController+Gesture.h"
#import "ZWSDK.h"
//#import "CMLogManagement.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@interface CMMultiLayerNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *statusBarView;

@end

@implementation CMMultiLayerNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kSysStatusBarHeight)];
    [self.view addSubview:self.statusBarView];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self.statusBarView setHidden:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self.visibleViewController || [self.viewControllers containsObject:viewController]) {
        return;
    }
    
//    if ([viewController respondsToSelector:@selector(navAnimatingStatus)]) {
//        // 页面正处于切换动画时，禁止push页面处理，避免出现Can't add self as subview引发crash
//        if (viewController.navAnimatingStatus) {
//            CMLogWarning(LogBusinessBasicLib, @"controller(%@)'s function(%@) push when animating.", viewController, NSStringFromSelector(_cmd));
//            return;
//        }
//
//        viewController.navAnimatingStatus = YES;
//    }

    [super pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if ([self.topViewController respondsToSelector:@selector(navAnimatingStatus)]) {
        self.topViewController.navAnimatingStatus = NO;
    }
    
    return [super popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(navAnimatingStatus)]) {
        viewController.navAnimatingStatus = NO;
    }
    
    return [super popToViewController:viewController animated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *rootVC = (UIViewController *)self.viewControllers.firstObject;
    
    if ([rootVC respondsToSelector:@selector(navAnimatingStatus)]) {
        rootVC.navAnimatingStatus = NO;
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    if (self.viewControllers.count > 0) {
//        return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
//    }
//
//    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
//    (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
//    (toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
//    (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
//}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.viewControllers.count > 0) {
        return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.viewControllers.count > 0 && !self.presentedViewController) {
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self.viewControllers count] > 0) {
        return [[self.viewControllers lastObject] preferredStatusBarStyle];
    }
    return UIStatusBarStyleLightContent;
}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if ([self.viewControllers count] > 0) {
//        [[self.viewControllers lastObject] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    }
//}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if ([self.viewControllers count] > 0) {
//        [[self.viewControllers lastObject] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    }
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class] && !self.topViewController.disableScreenEdgeGesture;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && !viewController.disableScreenEdgeGesture) {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
        navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (navigationController.viewControllers.count == 1) {
        if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
            navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    
    // 记录每次Navigation页面切换时，保存上次ViewController
    static UIViewController *lastController = nil;
    
    if (lastController &&
        [lastController respondsToSelector:@selector(navAnimatingStatus)] &&
        [lastController respondsToSelector:@selector(viewDidDisappear:)]) {
        lastController.navAnimatingStatus = NO;
    }
    
    if (viewController &&
        [viewController respondsToSelector:@selector(navAnimatingStatus)] &&
        [viewController respondsToSelector:@selector(viewDidAppear:)]) {
        viewController.navAnimatingStatus = NO;
    }
    
    lastController = viewController;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

@end

#pragma clang diagnostic pop
