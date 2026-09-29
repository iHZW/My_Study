//
//  UINavigationController+RotationConfiguration.m
//  My_Study
//
//  Created by hzw on 2023/7/21.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "UINavigationController+RotationConfiguration.h"

@implementation UINavigationController (RotationConfiguration)

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
