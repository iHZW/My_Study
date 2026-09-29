//
//  UITabBarController+RotationConfiguration.m
//  My_Study
//
//  Created by hzw on 2023/7/21.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "UITabBarController+RotationConfiguration.h"

@implementation UITabBarController (RotationConfiguration)

- (UIViewController *)sj_topViewController {
    if (self.selectedIndex == NSNotFound)
        return self.viewControllers.firstObject;
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return [[self sj_topViewController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self sj_topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
}

@end
