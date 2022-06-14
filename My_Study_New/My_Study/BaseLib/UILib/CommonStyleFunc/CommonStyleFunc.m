//
//  CommonStyleFunc.m
//  BankFinancing
//
//  Created by Howard Dong on 13-1-15.
//  Copyright (c) 2015年 __PA__. All rights reserved.
//

#import "CommonStyleFunc.h"

@implementation CommonStyleFunc

/**
 *  获取当前字帖的显示高度
 *
 *  @param font 字体属性
 *
 *  @return 当前字体所需高度
 */
+ (CGFloat)getFontHeight:(UIFont *)font
{
	return font.xHeight + font.capHeight;
}

/**
 *  设置指定UILabel对象的最小显示字体大小和正常显示字体大小
 *
 *  @param object     UILabel对象
 *  @param minSize    最小显示字体大小
 *  @param normalSize 正常显示字体大小
 */
+ (void)setMinFontSize:(UILabel *)object minFontSize:(CGFloat)minSize normalSize:(CGFloat)normalSize
{
//    [object setMinimumFontSize:minSize];
    [object setMinimumScaleFactor:minSize/normalSize];
}

/**
 *  通过指定垂直对齐方式及字体和显示区域属性,将UILabel对象进行垂直对齐显示调整
 *
 *  @param object   UILabel对象
 *  @param ntype    垂直对齐方式，参考CMULabelVerticalAlignment
 *  @param font     当前UILabel对象显示的字体
 *  @param rectSize 当前UILabel对象显示的区域
 */
+ (void)setVerticalAlignment:(UILabel *)object alignType:(CMULabelVerticalAlignment)ntype font:(UIFont *)font rectSize:(CGSize)rectSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode            = object.lineBreakMode;
    NSDictionary *dic                       = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle};
    CGSize stringSize                       = [object.text sizeWithAttributes:dic];
    
//	CGSize maximumSize	= rectSize;
//	CGSize stringSize	= [object.text sizeWithFont:font
//                                constrainedToSize:maximumSize 
//                                    lineBreakMode:object.lineBreakMode];
	
	CGRect strFrame = CGRectMake(0, 0, rectSize.width, rectSize.height);
	
	[object setFrame:strFrame];
	
//	CGSize fontSZ		= [object.text sizeWithFont:font];
    CGSize fontSZ       = [object.text sizeWithAttributes:dic];
	double finalHeight	= fontSZ.height * object.numberOfLines;
	int newLinesToPad	= (finalHeight  - stringSize.height) / fontSZ.height;
	
	switch (ntype)
	{
		case CMULabelAlignmentTop:
			for(int i=1; i< newLinesToPad; i++)
			{
                @autoreleasepool {
                    object.text = [object.text stringByAppendingString:@"\n"];
                }
			}
			break;
		case CMULabelAlignmentBottom:
			for(int i=1; i< newLinesToPad; i++)
			{
                @autoreleasepool {
                    object.text = [NSString stringWithFormat:@"\n%@",object.text];
                }
			}
			break;
		case CMULabelAlignmentCenter:
			for(int i=1; i< newLinesToPad; i++)
			{
                @autoreleasepool {
                    object.text = [NSString stringWithFormat:@"\n%@\n",object.text];
                }
			}
			break;
		default:
			break;
	}
}

/**
 *  判断是否是gif图片类型
 *
 *  @param imageData 图片NSData数据
 *
 *  @return gif图片类型结果 (YES:gif图片, NO:非gif图片)
 */
+ (BOOL)isGifImage:(NSData*)imageData
{
	const char* buf = (const char*)[imageData bytes];
	if (buf[0] == 0x47 && buf[1] == 0x49 && buf[2] == 0x46 && buf[3] == 0x38) {
		return YES;
	}
	return NO;
}

/**
 *  用于计算单行字符串显示所需尺寸区域
 *
 *  @param content 要计算字符串内容
 *  @param font    当前字符串显示字体
 *
 *  @return 返回字符串尺寸区域(高度和宽度)
 */
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font
{
    CGSize currentSize;
    NSString *tmpContent = [content length] > 0 ? content : @"h";
//    if ([content respondsToSelector:@selector(sizeWithAttributes:)]) {
        currentSize = [tmpContent sizeWithAttributes:@{NSFontAttributeName:font}];
//    } else{
//        // 如果指定字符串长度小于0, 调用 sizeWithFont 方法时，高度会返回0
//        NSString *tmpVal = [content length] > 0 ? content : @"defaultVal";
//        currentSize = [tmpVal sizeWithFont:font];
//    }
    return currentSize;
}

/**
 *  用于计算单行字符串显示所需尺寸区域
 *
 *  @param content       要计算字符串内容
 *  @param font          当前字符串显示字体
 *  @param lineBreakMode 换行模式
 *
 *  @return 返回字符串尺寸区域(高度和宽度)
 */
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize currentSize;
    NSString *tmpContent = [content length] > 0 ? content : @"h";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode            = lineBreakMode;
    NSDictionary *dic                       = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle};
    currentSize                             = [tmpContent sizeWithAttributes:dic];
    return currentSize;
}

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
+ (CGSize)sizeWithFont:(NSString *)content font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSString *tmpContent = [content length] > 0 ? content : @"h";
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [tmpContent boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
    
    //Contains both width & height ... Needed: The height
    return textRect.size;
}

/**
 *  通过指定字符串要显示的宽度和字体，计算出字符串显示的高度(适用于单行或多行文本)
 *
 *  @param str      需要计算的文本内容
 *  @param font     当前显示的字体
 *  @param curFrame 文本显示区域
 *
 *  @return 返回文本显示所需要的高度
 */
+ (CGSize)getDspStringSize:(NSString *)str font:(UIFont *)font curFrame:(CGRect)curFrame
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode            = NSLineBreakByWordWrapping;
    NSDictionary *dic                       = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle};
    CGSize sz                               = [str sizeWithAttributes:dic];
    CGSize linesSz                          = [str boundingRectWithSize:CGSizeMake(curFrame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
//    CGSize sz = [str sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 40)];
//    CGSize linesSz = [str sizeWithFont:font constrainedToSize:CGSizeMake(curFrame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGPoint lastPoint;
    
    if(sz.width <= linesSz.width) //断定是否折行
    {
        //        lastPoint = CGPointMake(curFrame.origin.x + sz.width, curFrame.origin.y);
    }
    else
    {
        lastPoint = CGPointMake(curFrame.origin.x + (int)sz.width % (int)linesSz.width, linesSz.height - sz.height);
        
        if (linesSz.height+lastPoint.y > curFrame.size.height && (curFrame.size.height -linesSz.height) > 0)
            linesSz.height += curFrame.size.height-linesSz.height;
    }
    
    return linesSz;
}

@end
