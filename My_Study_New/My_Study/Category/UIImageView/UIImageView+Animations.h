//
//  UIImageView+Animations.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Animations)

/**
 图片360°不停旋转
 */
- (void)rotating;

/**
 图片360°不停旋转

 @param duration 转360°所需时间，用于控制旋转速度
 @param direction 方向，1为顺时针，-1为逆时针
 */
- (void)rotating:(CFTimeInterval)duration direction:(NSInteger)direction;

@end

NS_ASSUME_NONNULL_END
