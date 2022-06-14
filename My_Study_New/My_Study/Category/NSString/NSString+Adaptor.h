//
//  NSString+Adaptor.h
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 适配不同SDK版本下字符串的绘制
 */
@interface NSString (Adaptor)

/**
 获取指定字体和显示宽度的文本显示高度
 
 @param text 要计算的文本内容
 @param font 字体大小
 @param width 指定显示宽度
 @return 显示高度
 */
+ (CGFloat)getHeightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

/**
 获取指定字体的文本显示size
 
 @param text 要计算的文本内容
 @param font 字体大小
 @return 显示size
 */
+ (CGSize)getTextSize:(id)text andFont:(UIFont *)font;

/**
 根据固定的宽度和文字内容 获取文本显示size

 @param text 显示内容
 @param font 当前字体大小
 @param width 固定宽度
 @param lineSpacing 间距
 @return 文本显示size
 */
+ (CGSize)getSizeWithText:(NSString *)text
                     font:(UIFont *)font
                    width:(CGFloat)width
              lineSpacing:(CGFloat)lineSpacing;

/**
 根据固定的宽度和文字内容 获取适合的字体大小
 
 @param changeString 显示内容
 @param fontSize 当前字体大小
 @param width 固定宽度
 @return 适合的字号
 */
+ (CGFloat)getFontForWidthWithStr:(NSString *)changeString
                         FontSize:(CGFloat)fontSize
                            width:(CGFloat)width;


/**
 * 适配sizeWithFont: IOS7为 sizeWithAttributes:
 * @see sizeWithFont:
 * @see sizeWithAttributes:
 */
- (CGSize)adaptorSizeWithFont:(UIFont *)font;

/**
 * 适配sizeWithFont:constrainedToSize: IOS7为 boundingRectWithSize:options:attributes:context:
 * @see sizeWithFont:constrainedToSize:
 * @see boundingRectWithSize:options:attributes:context:
 */
- (CGSize)adaptorSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 * 适配sizeWithFont:constrainedToSize:lineBreakMode: IOS7为 boundingRectWithSize:options:attributes:context:
 * @see sizeWithFont:constrainedToSize:lineBreakMode:
 * @see boundingRectWithSize:options:attributes:context:
 */
- (CGSize)adaptorSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 * 适配drawAtPoint:withFont: IOS7为 drawAtPoint:withAttributes:
 * @see drawAtPoint:withFont:
 * @see drawAtPoint:withAttributes:
 */
- (void)adaptorDrawAtPoint:(CGPoint)point withFont:(UIFont *)font fontColor:(UIColor *)fontColor;

/**
 * 适配drawInRect:withFont: IOS7为 drawInRect:withAttributes:
 * @see drawInRect:withFont:
 * @see drawInRect:withAttributes:
 */
- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor;

/**
 * 适配drawInRect:withFont:lineBreakMode: IOS7为 drawInRect:withAttributes:
 * @see drawInRect:withFont:lineBreakMode:
 * @see drawInRect:withAttributes:
 */
- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 * 适配drawInRect:withFont:lineBreakMode:alignment: IOS7为 drawInRect:withAttributes:
 * @see drawInRect:withFont:lineBreakMode:alignment:
 * @see drawInRect:withAttributes:
 */
- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

/**
 * 垂直居中绘制
 */
- (CGSize)adaptorDrawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

/**
 * 垂直居中绘制 lineBreakMode取值NSLineBreakByWordWrapping
 * @see adaptorDrawCenterInRect:withFont:fontColor:lineBreakMode:alignment:
 */
- (void)adaptorDrawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor alignment:(NSTextAlignment)alignment;


@end

NS_ASSUME_NONNULL_END
