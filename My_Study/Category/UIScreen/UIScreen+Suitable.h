//
//  UIScreen+Suitable.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Suitable)


/**
 根据屏幕获取新尺寸

 @param originalValue 原始尺寸
 @return 最终尺寸
 */
+ (CGFloat)finalScreenValue:(CGFloat)originalValue;


/**
 输入一个宽度值, 适配得到新的宽度值 (适配6P 5s)

 @param originalValue 原始尺寸
 @return 最终尺寸
 */
+ (CGFloat)suitableScreenValue:(CGFloat)originalValue;

@end

NS_ASSUME_NONNULL_END
