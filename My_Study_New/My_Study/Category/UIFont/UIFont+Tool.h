//
//  UIFont+Tool.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/1/17.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Tool)

+ (NSString *)eh_boldFontName;
+ (NSString *)eh_boldDIFontName;
+ (NSString *)eh_midiumFontName;
+ (NSString *)eh_regularFontName;
+ (NSString *)eh_lightFontName;
+ (NSString *)eh_sfRegularFontName;

/** [UIFont fontWithName:@"SFUIText-Regular" size: 13] */
+ (UIFont *)eh_sfNormalTitleFont;

/** [UIFont fontWithName:@"DINAlternate-Bold" size: 20] */
+ (UIFont *)eh_boldDITitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 28] */
+ (UIFont *)eh_boldBigTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 24] */
+ (UIFont *)eh_boldTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 22] */
+ (UIFont *)eh_boldKKTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 21] */
+ (UIFont *)eh_boldMDayFont;
/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 20] */
+ (UIFont *)eh_boldMTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 17] */
+ (UIFont *)eh_boldTitleNameFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 16] */
+ (UIFont *)eh_boldNameFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 15] */
+ (UIFont *)eh_boldButtonTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 14] */
+ (UIFont *)eh_boldXTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Semibold" size: 13] */
+ (UIFont *)eh_boldSmallFont;
/** [UIFont fontWithName:@"PingFangSC-Medium" size: 28] */
+ (UIFont *)eh_midiumBigTitleFont;
/** [UIFont fontWithName:@"PingFangSC-Medium" size: 18] */
+ (UIFont *)eh_midiumTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 17] */
+ (UIFont *)eh_midiumMiddleTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 16] */
+ (UIFont *)eh_midiumSmallTitleFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 15] */
+ (UIFont *)eh_midiumContentFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 14] */
+ (UIFont *)eh_midiumSmallFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 13] */
+ (UIFont *)eh_midiumSmallerFont;

/** [UIFont fontWithName:@"PingFangSC-Medium" size: 7] */
+ (UIFont *)eh_midiumBestSmallerFont;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 20] */
+ (UIFont *)eh_regularBigerFont;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 18] */
+ (UIFont *)eh_regularBiger0Font;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 16] */
+ (UIFont *)eh_regularBigFont;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 15] */
+ (UIFont *)eh_regularMiddleFont;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 14] */
+ (UIFont *)eh_regularFont;

/** [UIFont fontWithName:@"PingFangSC-Regular" size: 13] */
+ (UIFont *)eh_regularSmallFont;
/** [UIFont fontWithName:@"PingFangSC-Regular" size: 12] */
+ (UIFont *)eh_regularXSmallFont;
/** [UIFont fontWithName:@"PingFangSC-Regular" size: 11] */
+ (UIFont *)eh_regularMinSmallFont;
/** [UIFont fontWithName:@"PingFangSC-Regular" size: 10] */
+ (UIFont *)eh_regularSmallerFont;
/** [UIFont fontWithName:@"PingFangSC-Regular" size: 9.5] */
+ (UIFont *)eh_regularMSmallerFont;

/** [UIFont fontWithName:@"Light" size: 14] */
+ (UIFont *)eh_lightSmallFont;

/** [UIFont fontWithName:@"Light" size: 12] */
+ (UIFont *)eh_lightSmallerFont;

/** 设置常规字体大小  */
+ (UIFont *)eh_regularFontSize:(CGFloat)size;
/** 设置平方 中粗 字体大小  */
+ (UIFont *)eh_midiumFontSize:(CGFloat)size;
/** 设置 粗 字体大小  */
+ (UIFont *)eh_boldFontSize:(CGFloat)size;
/** 设置 细 字体大小  */
+ (UIFont *)eh_lightFontSize:(CGFloat)size;
@end

NS_ASSUME_NONNULL_END
