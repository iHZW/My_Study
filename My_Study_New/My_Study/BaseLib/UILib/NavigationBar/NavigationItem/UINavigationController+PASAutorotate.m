//
//  UINavigationController+PASAutorotate.m
//  PASecuritiesApp
//
//  Created by vince on 2018/1/10.
//  Copyright © 2018年 PAS. All rights reserved.
//

#import "UINavigationController+PASAutorotate.h"

@implementation UINavigationController (PASAutorotate)

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

@end
