//
//  UIButton+Navigation.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/7/27.
//
//

#import "UIButton+Navigation.h"
#import "CommonStyleFunc.h"
#import "ZWSDK.h"


@implementation UIButton (Navigation)

+ (UIButton *)customLeftIconRightTextButton:(UIButtonType)btnType frame:(CGRect)frame offsetSize:(CGSize)offsetSize title:(NSString *)title image:(UIImage *)image align:(NSTextAlignment)align
{
    UIButton *btn = [[self class] customLeftIconRightTextButton:btnType frame:frame offsetSize:offsetSize font:[UIFont systemFontOfSize:15] title:title image:image align:align];
    
    return btn;
}

+ (UIButton *)customLeftIconRightTextButton:(UIButtonType)btnType frame:(CGRect)frame offsetSize:(CGSize)offsetSize font:(UIFont *)font title:(NSString *)title image:(UIImage *)image align:(NSTextAlignment)align
{
    CGFloat xOffset     = offsetSize.width;
    CGFloat yOffset     = offsetSize.height;
    CGFloat midOffset   = 5;
    BOOL showIcon       = image ? YES : NO;
    
    UIButton *btn = [UIButton buttonWithType:btnType];
    [btn.titleLabel setFont:font];
    [btn setFrame:frame];
    if ([title length] > 0) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    
    if (showIcon)[btn setImage:image forState:UIControlStateNormal];
    
    UIControlContentHorizontalAlignment alignment = UIControlContentHorizontalAlignmentCenter;
    if (align == NSTextAlignmentLeft) {     // 居左显示
        alignment = UIControlContentHorizontalAlignmentLeft;
        midOffset = showIcon ? midOffset : 0;
    } else if (align == NSTextAlignmentRight) { // 居右显示
        alignment = UIControlContentHorizontalAlignmentRight;
        midOffset = [title length] > 0 ? midOffset : 0;
    } else {    // 居中显示
        CGSize strSize = [CommonStyleFunc sizeWithFont:title font:btn.titleLabel.font];
        midOffset = [title length] > 0 ? midOffset : 0;
        CGFloat imgWidth = showIcon ? btn.currentImage.size.width : 0;
        CGFloat totalLen = strSize.width + midOffset + imgWidth;
        CGFloat edgeLen = (frame.size.width - totalLen) / 2;
        if (edgeLen < xOffset)
            edgeLen = xOffset;
        xOffset = edgeLen;
    }
    
    [btn setContentHorizontalAlignment:alignment];
    
    if (showIcon)
    {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(yOffset, xOffset, yOffset, xOffset+midOffset)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(yOffset, xOffset+midOffset, yOffset, xOffset)];
    }
    else
    {
        [btn setImageEdgeInsets:UIEdgeInsetsZero];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, midOffset)];
    }
    
    return btn;
}

- (void)refreshRightIconLeftTextButton:(UIEdgeInsets)edgeInset midOffset:(CGFloat)midOffset align:(NSTextAlignment)align
{
    CGFloat xOffset     = edgeInset.left;
    CGFloat xOffset1    = edgeInset.right;
    BOOL showIcon       = self.currentImage ? YES : NO;
    
    CGFloat imgWidth = showIcon ? self.currentImage.size.width : 0;
    CGSize strSize = [CommonStyleFunc sizeWithFont:self.titleLabel.text font:self.titleLabel.font];
    midOffset = showIcon ? midOffset : 0;
    
    UIControlContentHorizontalAlignment alignment = UIControlContentHorizontalAlignmentCenter;
    if (align == NSTextAlignmentLeft) {     // 居左显示
        alignment = UIControlContentHorizontalAlignmentLeft;
        
        CGFloat totalLen = strSize.width + midOffset + imgWidth;
        CGFloat edgeLen = (self.frame.size.width - totalLen);
        if (edgeLen < xOffset + xOffset1)
            edgeLen = xOffset + xOffset1;
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(edgeInset.top, xOffset-imgWidth, edgeInset.bottom, imgWidth+xOffset+midOffset)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(edgeInset.top, self.frame.size.width-edgeLen-imgWidth+midOffset, edgeInset.bottom, edgeLen-xOffset1+midOffset)];
        
    } else if (align == NSTextAlignmentRight) { // 居右显示
        alignment = UIControlContentHorizontalAlignmentRight;
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(edgeInset.top, self.frame.size.width-imgWidth-xOffset1, edgeInset.bottom, xOffset1)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(edgeInset.top, xOffset1-imgWidth, edgeInset.bottom, imgWidth+xOffset1+midOffset)];
    } else {    // 居中显示
        alignment = UIControlContentHorizontalAlignmentCenter;
        midOffset = [self.titleLabel.text length] > 0 ? midOffset : 0;
        CGFloat totalLen = strSize.width + midOffset + imgWidth;
        
        CGFloat edgeLen = (self.frame.size.width - totalLen) / 2;
        if (edgeLen < xOffset)
            edgeLen = xOffset;
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(edgeInset.top, self.frame.size.width-edgeLen-imgWidth, edgeInset.bottom, edgeLen)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(edgeInset.top, midOffset-imgWidth, edgeInset.bottom, imgWidth+midOffset)];
    }
    
    [self setContentHorizontalAlignment:alignment];
}

+ (UIButton *)customNormalButton:(UIButtonType)btnType frame:(CGRect)frame offsetSize:(CGSize)offsetSize title:(NSString *)title image:(UIImage *)image align:(NSTextAlignment)align
{
    UIButton *btn       = [[self class] customLeftIconRightTextButton:btnType frame:frame offsetSize:offsetSize title:title image:image align:align];
    [btn.titleLabel setFont:PASFont(16)];
    [btn.titleLabel setMinimumScaleFactor:.5];
    [btn.titleLabel setNumberOfLines:1];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    return btn;
}

+ (UIButton *)customLeftButton:(UIButtonType)btnType frame:(CGRect)frame title:(NSString *)title image:(UIImage *)image
{
    CGSize offsetSize = CGSizeMake(9, 0);
    return [[self class] customNormalButton:btnType frame:frame offsetSize:offsetSize title:title image:image align:NSTextAlignmentLeft];
}

+ (UIButton *)customRightButton:(UIButtonType)btnType frame:(CGRect)frame title:(NSString *)title image:(UIImage *)image
{
    CGSize offsetSize = CGSizeMake(9, 0);
    return [[self class] customNormalButton:btnType frame:frame offsetSize:offsetSize title:title image:image align:NSTextAlignmentRight];
}

@end
