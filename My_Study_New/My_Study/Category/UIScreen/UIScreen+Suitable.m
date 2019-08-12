//
//  UIScreen+Suitable.m
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "UIScreen+Suitable.h"
#import "ZWSDK.h"

@implementation UIScreen (Suitable)

/**
 根据屏幕获取新尺寸
 
 @param originalValue 原始尺寸
 @return 最终尺寸
 */
+ (CGFloat)finalScreenValue:(CGFloat)originalValue
{
    if (IS_IPHONE_6P) {
        CGFloat reduceValue = .0;
        CGFloat tempValue = originalValue*1.14;
        CGFloat remainderValue = tempValue - (long)tempValue;
        if (remainderValue > .05 && remainderValue <= .505) {
            reduceValue = .5;
        }
        return ceil(tempValue) - reduceValue;
    }else{
        return originalValue;
    }
}


/**
 输入一个宽度值, 适配得到新的宽度值 (适配6P 5s)
 
 @param originalValue 原始尺寸
 @return 最终尺寸
 */
+ (CGFloat)suitableScreenValue:(CGFloat)originalValue
{
    if (IS_IPHONE_6) {
        return originalValue;
    }else{
        CGFloat scale = originalValue / 375.0;
        return scale * kMainScreenWidth;
    }
    
}


@end
