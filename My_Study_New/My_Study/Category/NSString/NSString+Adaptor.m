//
//  NSString+Adaptor.m
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "NSString+Adaptor.h"
#import "ZWSDK.h"

@implementation NSString (Adaptor)

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

/**
 获取指定字体和显示宽度的文本显示size
 
 @param text 要计算的文本内容
 @param font 字体大小
 @param width 指定显示宽度
 @return 显示size
 */
+ (CGSize)getSizeWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width
{
    return [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
}

/**
 获取指定字体和显示宽度的文本显示高度
 
 @param text 要计算的文本内容
 @param font 字体大小
 @param width 指定显示宽度
 @return 显示高度
 */
+ (CGFloat)getHeightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width
{
    return  [self getSizeWithText:text font:font width:width].height;
}

/**
 获取指定字体的文本显示size
 
 @param text 要计算的文本内容
 @param font 字体大小
 @return 显示size
 */
+ (CGSize)getTextSize:(id)text andFont:(UIFont *)font
{
    if (!text) {
        return CGSizeZero;
    }
    NSString *str = nil;
    //    NSDictionary *attributes = nil;
    if ([text isKindOfClass: [NSString class]]) {
        str = text;
        //        attributes = @{NSFontAttributeName: font};
    }
    //    else if([text isKindOfClass:[NSAttributedString class]])
    //    {
    //        NSAttributedString *attrStr = (NSAttributedString *)text;
    //        str = attrStr.string;
    //        NSRange range;
    //        attributes = [attrStr attributesAtIndex:0 effectiveRange:&range];
    //    }
    //    if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
    //        return [str sizeWithAttributes: attributes];
    //    }
    //    else {
    //        return [str sizeWithFont:font];
    //    }
    return [str adaptorSizeWithFont:font];
}

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
              lineSpacing:(CGFloat)lineSpacing
{
    if (!text) {
        return CGSizeZero;
    }
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setLineSpacing:lineSpacing];
    NSDictionary *attr = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragrapStyle};
    return [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
}

/**
 6.6 根据固定的宽度和文字内容 获取适合的字体大小
 
 @param changeString 显示内容
 @param fontSize 当前字体大小
 @param width 固定宽度
 @return 适合的字号
 */
+ (CGFloat)getFontForWidthWithStr:(NSString *)changeString
                         FontSize:(CGFloat)fontSize
                            width:(CGFloat)width
{
    CGFloat newFontSize = fontSize;
    CGSize changeStringSize = [NSString getTextSize:changeString andFont:PASFacFont(fontSize)];
    
    if (changeStringSize.width > width) {
        for (NSInteger i=fontSize; i>0; i--) {
            CGSize tempSize = [NSString getTextSize:changeString andFont:PASFacFont(i)];
            if (tempSize.width <= width) {
                newFontSize = i;
                break;
            }
        }
    }
    return newFontSize;
}

- (CGSize)adaptorSizeWithFont:(UIFont *)font
{
    if ([self respondsToSelector:@selector(sizeWithAttributes:)])
    {
        return [self sizeWithAttributes: @{NSFontAttributeName : font}];
    }
    else
    {
        return [self sizeWithFont:font];
    }
}

- (CGSize)adaptorSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        return [self boundingRectWithSize:size
                                  options:NSStringDrawingUsesFontLeading
                               attributes:@{NSFontAttributeName : font}
                                  context:nil].size;
    }
    else
    {
        return [self sizeWithFont:font constrainedToSize:size];
    }
}

- (CGSize)adaptorSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *style  = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineBreakMode             = lineBreakMode;
        
        NSDictionary *attributes        = @{NSFontAttributeName : font,NSParagraphStyleAttributeName : style};
#if !__has_feature(objc_arc)
        [style release];
#endif
        
        return [self boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:attributes
                                  context:nil].size;
    }
    else
    {
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
}

- (void)adaptorDrawAtPoint:(CGPoint)point withFont:(UIFont *)font fontColor:(UIColor *)fontColor
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self drawAtPoint:point withAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : fontColor}];
    } else {
        [fontColor setFill];
        [self drawAtPoint:point withFont:font];
    }
}

- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self drawInRect:rect withAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : fontColor}];
    } else {
        [fontColor setFill];
        [self drawInRect:rect withFont:font];
    }
}

- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        NSMutableParagraphStyle *style  = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineBreakMode             = lineBreakMode;
        
        [self drawInRect:rect withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : fontColor,NSParagraphStyleAttributeName : style }];
#if !__has_feature(objc_arc)
        [style release];
#endif
    } else {
        [fontColor setFill];
        [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode];
    }
}

- (void)adaptorDrawInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        NSMutableParagraphStyle *style  = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineBreakMode             = lineBreakMode;
        style.alignment                 = alignment;
        
        [self drawInRect:rect withAttributes:@{NSFontAttributeName : font ?: [UIFont systemFontOfSize:12],
                                               NSForegroundColorAttributeName : fontColor ?: [UIColor grayColor],
                                               NSParagraphStyleAttributeName : style}];
#if !__has_feature(objc_arc)
        [style release];
#endif
    } else {
        [fontColor setFill];
        [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
    }
}

- (CGSize)adaptorDrawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    CGSize size                         = [self adaptorSizeWithFont:font constrainedToSize:rect.size lineBreakMode:lineBreakMode];
    CGRect textRect                     = rect;
    textRect.origin.y                   += (rect.size.height - size.height) * .5;
    textRect.size.height                = size.height;
    
    [self adaptorDrawInRect:textRect withFont:font fontColor:fontColor lineBreakMode:lineBreakMode alignment:alignment];
    
    return size;
}

- (void)adaptorDrawCenterInRect:(CGRect)rect withFont:(UIFont *)font fontColor:(UIColor *)fontColor alignment:(NSTextAlignment)alignment
{
    [self adaptorDrawCenterInRect:rect withFont:font fontColor:fontColor lineBreakMode:NSLineBreakByClipping alignment:alignment];
}


@end
