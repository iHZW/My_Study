//
//  UIFont+Tool.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "UIFont+Tool.h"

@implementation UIFont (Tool)

+ (NSString *)eh_boldFontName {
    return @"PingFangSC-Semibold";
}
+ (NSString *)eh_regularFontName {
    return @"PingFangSC-Regular";
}
+ (NSString *)eh_midiumFontName {
    return @"PingFangSC-Medium";
}
+ (NSString *)eh_lightFontName {
    return @"PingFangSC-Light";
}

+ (NSString *)eh_boldDIFontName {
    return @"DINAlternate-Bold";
}

+ (NSString *)eh_sfRegularFontName {
    return @"SFUIText-Regular";
}

/** [UIFont fontWithName:@"SFUIText-Regular" size: 13] */
+ (UIFont *)eh_sfNormalTitleFont {
    return [UIFont fontWithName:[UIFont eh_sfRegularFontName] size:13];
}

/** [UIFont fontWithName:@"DINAlternate-Bold" size: 20] */
+ (UIFont *)eh_boldDITitleFont {
    return [UIFont fontWithName:[UIFont eh_boldDIFontName] size:20];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 28] */
+ (UIFont *)eh_boldBigTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:28];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 24] */
+ (UIFont *)eh_boldTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:24];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 22] */
+ (UIFont *)eh_boldKKTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:22];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 21] */
+ (UIFont *)eh_boldMDayFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:21];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 20] */
+ (UIFont *)eh_boldMTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:20];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 17] */
+ (UIFont *)eh_boldTitleNameFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:17];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 16] */
+ (UIFont *)eh_boldNameFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:16];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 15] */
+ (UIFont *)eh_boldButtonTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:15];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 14] */
+ (UIFont *)eh_boldXTitleFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:14];
}

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 13] */
+ (UIFont *)eh_boldSmallFont {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:13];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 28] */
+ (UIFont *)eh_midiumBigTitleFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:28];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 18] */
+ (UIFont *)eh_midiumTitleFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:18];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 17] */
+ (UIFont *)eh_midiumMiddleTitleFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:17];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 16] */
+ (UIFont *)eh_midiumSmallTitleFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:16];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 15] */
+ (UIFont *)eh_midiumContentFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:15];
}
/** [UIFont fontWithName:@"PingFangSC-Medium" size: 14] */
+ (UIFont *)eh_midiumSmallFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:14];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 13] */
+ (UIFont *)eh_midiumSmallerFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:13];
}

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 7] */
+ (UIFont *)eh_midiumBestSmallerFont {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:7];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 20] */
+ (UIFont *)eh_regularBigerFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:20];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 18] */
+ (UIFont *)eh_regularBiger0Font {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:18];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 16] */
+ (UIFont *)eh_regularBigFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:16];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 15] */
+ (UIFont *)eh_regularMiddleFont;
{
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:15];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 14] */
+ (UIFont *)eh_regularFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:14];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 13] */
+ (UIFont *)eh_regularSmallFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:13];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 12] */

+ (UIFont *)eh_regularXSmallFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:12];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 11] */
+ (UIFont *)eh_regularMinSmallFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:11];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 10] */
+ (UIFont *)eh_regularSmallerFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:10];
}

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 9.5] */
+ (UIFont *)eh_regularMSmallerFont {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:9.5];
}

/** [UIFont fontWithName:@"Light" size: 14] */
+ (UIFont *)eh_lightSmallFont {
    return [UIFont fontWithName:[UIFont eh_lightFontName] size:14];
}

/** [UIFont fontWithName:@"Light" size: 12] */
+ (UIFont *)eh_lightSmallerFont {
    return [UIFont fontWithName:[UIFont eh_lightFontName] size:12];
}

/** 设置常规字体大小  */
+ (UIFont *)eh_regularFontSize:(CGFloat)size {
    return [UIFont fontWithName:[UIFont eh_regularFontName] size:size];
}
/** 设置平方 中粗 字体大小  */
+ (UIFont *)eh_midiumFontSize:(CGFloat)size {
    return [UIFont fontWithName:[UIFont eh_midiumFontName] size:size];
}
/** 设置 粗 字体大小  */
+ (UIFont *)eh_boldFontSize:(CGFloat)size {
    return [UIFont fontWithName:[UIFont eh_boldFontName] size:size];
}
/** 设置 细 字体大小  */
+ (UIFont *)eh_lightFontSize:(CGFloat)size {
    return [UIFont fontWithName:[UIFont eh_lightFontName] size:size];
}

@end
