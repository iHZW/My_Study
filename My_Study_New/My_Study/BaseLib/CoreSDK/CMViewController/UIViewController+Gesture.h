//
//  UIViewController+Gesture.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/24.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (Gesture)

@property(nonatomic, assign) BOOL disableScreenEdgeGesture;

/**
 导航页面切换动画状态
 */
@property (nonatomic, assign) BOOL navAnimatingStatus;

+ (void)popGestureClose:(UIViewController *)VC;

+ (void)popGestureOpen:(UIViewController *)VC;

@end
