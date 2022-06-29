//
//  ZWRefreshHeader.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@class ZWAnimationView;

@interface ZWRefreshHeader : MJRefreshHeader
/** 状态label  */
@property (nonatomic, strong, readonly) UILabel *stateLabel;
/** 刷新动画  */
@property (nonatomic, weak, readonly) ZWAnimationView *animationView;
/** 设置偏移  */
@property (nonatomic, assign) float offsetY;

- (void)setImageIcon:(UIImage *)image circleColor:(UIColor *)circleColor textColor:(UIColor *)textColor;


@end

NS_ASSUME_NONNULL_END
