//
//  UIViewController+Child.h
//  CRM
//
//  Created by Zhiwei Han on 2022/4/22.
//  Copyright © 2019 Zhiwei Han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Child)
/**
 * 显示的子VC， 用于 UIApplication displayVC 时候使用
 */
@property (nonatomic, strong,nullable) UIViewController *displayChildViewController;
@end

NS_ASSUME_NONNULL_END
