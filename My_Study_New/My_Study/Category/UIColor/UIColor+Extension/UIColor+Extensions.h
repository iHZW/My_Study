//
//  UIColor+Extensions.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>


#define PASRGBColor(r,g,b) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:1.f]

#define PASRGBAColor(r,g,b,a) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:a]

#define UIColorFromRGB(rgbValue) \
[UIColor colorFromHex:rgbValue]

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor colorFromHex:rgbValue alpha:alphaValue]

#define UIColorFromHexString(hexString) [UIColor colorFromHexString:hexString]
#define UIColorFromHexAlphaString(hexString, a) [UIColor colorFromHexString:hexString alpha:a]
#define UIColorFromHexStr(hexString) [UIColor colorFromHexString:hexString]

@interface UIColor (Format)

/**
 *  将16进制字符串转换成颜色
 *
 *  @param hexString 传入的字符串，可以以@"#"开头，也可以是不带，支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 *
 *  @return 转换后的颜色
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/**
 将16进制字数转换成颜色

 @param hexVal 十六机制数 0x6a3fee
 @return 转换后颜色
 */
+ (UIColor *)colorFromHex:(NSInteger)hexVal;

/**
 将16进制字数转换成颜色
 
 @param hexVal 十六机制色值 0x6a3fee
 @param opacity 透明度
 @return 转换后颜色
 */
+ (UIColor *)colorFromHex:(NSInteger)hexVal alpha:(float)opacity;

/**
 *  将16进制字符串转换成颜色
 *
 *  @param hexStr 传入的字符串，可以以@"#"开头，也可以是不带，支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 *  @param alpha  透明度
 *
 *  @return 转换后的颜色
 */
+ (UIColor *)colorFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

/**
 *  随机生成颜色
 */
+ (UIColor *)randomColor;

+ (UIColor *)color255WithRed:(int)red green:(int)green blue:(int)blue;

@end


@interface NSString (ColorFormat)

- (UIColor *)colorFromHexString;

@end
