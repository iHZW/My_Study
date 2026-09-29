//
//  UIViewController+RotationConfiguration.m
//  My_Study
//
//  Created by hzw on 2023/7/21.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "UIViewController+RotationConfiguration.h"

@implementation UIViewController (RotationConfiguration)

#pragma mark - 控制旋转方向
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
