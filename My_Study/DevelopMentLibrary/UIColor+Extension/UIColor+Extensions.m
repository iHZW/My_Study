//
//  UIColor+Extensions.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/14.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Format)

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

/**
 将16进制字数转换成颜色
 
 @param hexVal 十六机制色值 0x6a3fee
 @return 转换后颜色
 */
+ (UIColor *)colorFromHex:(NSInteger)hexVal
{
    return [UIColor colorFromHex:hexVal alpha:1.0];
}

/**
 将16进制字数转换成颜色

 @param hexVal 十六机制色值 0x6a3fee
 @param opacity 透明度
 @return 转换后颜色
 */
+ (UIColor *)colorFromHex:(NSInteger)hexVal alpha:(float)opacity
{
    CGFloat red = ((CGFloat)((hexVal & 0xFF0000) >> 16))/255.0;
    CGFloat green = ((CGFloat)((hexVal & 0xFF00) >> 8))/255.0;
    CGFloat blue = ((CGFloat)(hexVal & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    return [self colorFromHexString:hexString alpha:1.0];
}

+ (UIColor *)colorFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    // Create color object, specifying alpha as well
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                                     green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                                      blue:((CGFloat) (hexint & 0xFF))/255
                                     alpha:alpha];
    return color;
}

+ (UIColor *)randomColor
{
    CGFloat red   = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
    CGFloat blue  = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)arc4random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)color255WithRed:(int)red green:(int)green blue:(int)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end


@implementation NSString (ColorFormat)

- (UIColor *)colorFromHexString
{
    return [UIColor colorFromHexString:self];
}

@end
