//
//  CommonStyleFunc.h
//  BankFinancing
//
//  Created by Howard Dong on 13-1-15.
//  Copyright (c) 2013年 __PA__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, CMULabelVerticalAlignment) {
    CMULabelAlignmentTop 		= 0,            // UILabel 垂直置顶
    CMULabelAlignmentCenter		= 1,            // UILabel 垂直居中
    CMULabelAlignmentBottom		= 2,            // UILabel 垂直置底
};

@interface CommonStyleFunc : NSObject
/**
 *  获取当前字帖的显示高度
 *
 *  @param font 字体属性
 *
 *  @return 当前字体所需高度
 */
+ (CGFloat)getFontHeight:(UIFont *)font;

/**
 *  设置指定UILabel对象的最小显示字体大小和正常显示字体大小
 *
 *  @param object     UILabel对象
 *  @param minSize    最小显示字体大小
 *  @param normalSize 正常显示字体大小
 */
+ (void)setMinFontSize:(UILabel *)object minFontSize:(CGFloat)minSize normalSize:(CGFloat)normalSize;

/**
 *  通过指定垂直对齐方式及字体和显示区域属性,将UILabel对象进行垂直对齐显示调整
 *
 *  @param object   UILabel对象
 *  @param ntype    垂直对齐方式，参考CMULabelVerticalAlignment
 *  @param font     当前UILabel对象显示的字体
 *  @param rectSize 当前UILabel对象显示的区域
 */
+ (void)setVerticalAlignment:(UILabel *)object alignType:(CMULabelVerticalAlignment)ntype font:(UIFont *)font rectSize:(CGSize)rectSize;

/**
 *  判断是否是gif图片类型
 *
 *  @param imageData 图片NSData数据
 *
 *  @return gif图片类型结果 (YES:gif图片, NO:非gif图片)
 */
+ (BOOL)isGifImage:(NSData*)imageData;


/**
 *  用于计算单行字符串显示所需尺寸区域
 *
 *  @param content 要计算字符串内容
 *  @param font    当前字符串显示字体
 *
 *  @return 返回字符串尺寸区域(高度和宽度)
 */
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font;

/**
 *  用于计算单行字符串显示所需尺寸区域
 *
 *  @param content       要计算字符串内容
 *  @param font          当前字符串显示字体
 *  @param lineBreakMode 换行模式
 *
 *  @return 返回字符串尺寸区域(高度和宽度)
 */
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  用于计算单行字符串显示所需尺寸区域
 *
 *  @param content       要计算字符串内容
 *  @param font          当前字符串显示字体
 *  @param size          CGSizeMake(labelMaxWidth, font.lineHeight)
 *  @param lineBreakMode 换行模式
 *
 *  @return 返回字符串尺寸区域(高度和宽度)
 */
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  通过指定字符串要显示的宽度和字体，计算出字符串显示的高度(适用于单行或多行文本)
 *
 *  @param str      需要计算的文本内容
 *  @param font     当前显示的字体
 *  @param curFrame 文本显示区域
 *
 *  @return 返回文本显示所需要的高度
 */
+ (CGSize)getDspStringSize:(NSString *)str font:(UIFont *)font curFrame:(CGRect)curFrame;

@end
