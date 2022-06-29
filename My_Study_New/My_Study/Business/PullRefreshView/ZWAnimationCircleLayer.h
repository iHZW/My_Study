//
//  ZWAnimationCircleLayer.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define kDefineStrokeColor          UIColorFromRGB(0xC2C2C2)

NS_ASSUME_NONNULL_BEGIN

@interface ZWAnimationCircleLayer : CAShapeLayer

- (instancetype)initWithframe:(CGRect)frame;

- (void)setCircleStrokeColor:(UIColor *)color;

- (void)startCircleAnimation:(float)toValue;

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
