//
//  ZWNavigationController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWNavigationController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZWBaseViewController.h"


@interface ZWNavigationController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation ZWNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    self.delegate = self;
    UIColor *bgColor = UIColorFromRGB(0xE9E9E9);
    self.navigationBar.barTintColor = bgColor;
    self.navigationBar.backgroundColor = bgColor;
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x111111),NSFontAttributeName:PASFont(18)}];
    self.navigationBar.tintColor = UIColorFromRGB(0x111111);

    
    //ios 15系统
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appperance = [[UINavigationBarAppearance alloc]init];
        //添加背景色
        appperance.backgroundColor = bgColor;
        appperance.shadowImage = [[UIImage alloc]init];
        appperance.shadowColor = nil;
        //设置字体颜色大小
        [appperance setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x111111),NSFontAttributeName:PASFont(18)}];
 
        self.navigationBar.standardAppearance = appperance;
        self.navigationBar.scrollEdgeAppearance = appperance;
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.hideTabbar = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[ZWBaseViewController class]]){
        BOOL hidNavBar = viewController.hideNavigationBar;
        [self setNavigationBarHidden:hidNavBar animated:YES];
        viewController.fd_prefersNavigationBarHidden = hidNavBar;
        navigationController.navigationBar.shadowImage = viewController.navBarShadowImage;
        
        BOOL hideTabbar = viewController.hideTabbar;
        navigationController.tabBarController.tabBar.hidden = hideTabbar;
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate{
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [self.viewControllers.lastObject preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden{
    return [self.viewControllers.lastObject prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}


//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
//    return [self.topViewController supportedInterfaceOrientations];
//}
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController{
//    return [self.topViewController preferredInterfaceOrientationForPresentation];
//}


@end
