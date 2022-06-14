//
//  UIButton+Custom.m
//  PASecuritiesApp
//
//  Created by vince on 16/2/23.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIButton+Custom.h"
#import "UIImage+ResourcePath.h"

@implementation UIButton (Custom)

- (void)relayoutButtonWithTitleAlign:(ButtonTitleAlign)titleAlign hspace:(CGFloat)hspace
{
    CGRect imageFrame = self.imageView.frame;
    CGRect titleFrame = self.titleLabel.frame;
    CGFloat halfHspace = hspace/2.0;
    
    if (ButtonTitleLeft == titleAlign) {
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(imageFrame.size.width+halfHspace), 0,(imageFrame.size.width+halfHspace))];
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, (titleFrame.size.width+halfHspace), 0,-(titleFrame.size.width+halfHspace))];
    }
    else if (hspace > 0) {
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, -halfHspace, 0, halfHspace)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, halfHspace, 0,-halfHspace)];
    }
}

+ (UIButton *)pas_buttonWithFrame:(NSString *)title
                      normalImage:(NSString *)normalImageStr
                       hightImage:(NSString *)hightImageStr
                           hspace:(CGFloat)hspace
                       titleAlign:(ButtonTitleAlign)titleAlign
                            block:(HandleButtonBlock)block
{
    UIButton *button = [UIButton pas_buttonWithCustom:UIButtonTypeCustom frame:CGRectZero title:title titleColor:nil bgImageNormalColor:nil target:nil selector:nil];
    button.backgroundColor = [UIColor whiteColor];
    if (normalImageStr) {
        [button setImage:[UIImage imageNamed:normalImageStr] forState:UIControlStateNormal];
    }
    
    if (hightImageStr) {
        [button setImage:[UIImage imageNamed:hightImageStr] forState:UIControlStateHighlighted];
    }
    
    if (block) {
        block(button);
    }
    
    [button relayoutButtonWithTitleAlign:titleAlign hspace:hspace];
    
    return button;
}

+ (UIButton *)pas_buttonWithFrame:(CGRect)frame
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
               bgImageNormalColor:(UIColor *)backgroudImageColor
                      normalImage:(UIImage *)normalImage
                       hightImage:(UIImage *)hightImage hspace:(CGFloat)hspace
                       titleAlign:(ButtonTitleAlign)titleAlign
                           target:(id)target
                         selector:(SEL)selector
                            block:(HandleButtonBlock)block
{
    UIButton *button = [UIButton pas_buttonWithCustom:UIButtonTypeCustom frame:frame title:title titleColor:titleColor bgImageNormalColor:backgroudImageColor target:target selector:selector];
    button.backgroundColor = [UIColor whiteColor];
    if (normalImage) {
        [button setImage:normalImage forState:UIControlStateNormal];
    }
    
    if (hightImage) {
        [button setImage:hightImage forState:UIControlStateHighlighted];
    }
    
    if (block) {
        block(button);
    }
    
    [button relayoutButtonWithTitleAlign:titleAlign hspace:hspace];
    
    return button;
}

+ (UIButton *)pas_buttonWithCustom:(UIButtonType)buttonType
                             frame:(CGRect)frame
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                bgImageNormalColor:(UIColor *)backgroudImageColor
                            target:(id)target
                          selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:buttonType];
    button.frame = frame;
    
    if ([title length]) {
        [button setTitle:title forState:UIControlStateNormal];
    }

    if (titleColor) {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    if (backgroudImageColor) {
        [button setBackgroundImage:[UIImage createImageWithColor:backgroudImageColor] forState:UIControlStateNormal];
    }
    
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setButtonImageTitleStyle:(ButtonImageTitleStyle)style padding:(CGFloat)padding
{
    if (self.imageView.image != nil && self.titleLabel.text != nil) {
        //先还原
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
        
        CGRect imageRect = self.imageView.frame;
        CGRect titleRect = self.titleLabel.frame;
        
        CGFloat totalHeight = imageRect.size.height + padding + titleRect.size.height;
        CGFloat selfHeight = self.frame.size.height;
        CGFloat selfWidth = self.frame.size.width;
        /**< 默认图片和title间距为5 */
        CGFloat betweenSpace = 5;
        switch (style) {
            case ButtonImageTitleStyleLeft:
                if (padding != 0) {
                    self.titleEdgeInsets = UIEdgeInsetsMake(0, padding/2, 0, -padding/2);
                    self.imageEdgeInsets = UIEdgeInsetsMake(0, -padding/2, 0, padding/2);
                }
                break;
            case ButtonImageTitleStyleRight:    //图片在右，文字在左
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageRect.size.width + padding/2), 0, (imageRect.size.width + padding/2));
                self.imageEdgeInsets = UIEdgeInsetsMake(0, (titleRect.size.width+ padding/2), 0, -(titleRect.size.width+ padding/2));
            }
                break;
            case ButtonImageTitleStyleTop:
            {
                //图片在上，文字在下
                self.titleEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 + imageRect.size.height + padding - titleRect.origin.y),
                                                        (selfWidth/2 - titleRect.origin.x - titleRect.size.width /2) - (selfWidth - titleRect.size.width) / 2,
                                                        -((selfHeight - totalHeight)/2 + imageRect.size.height + padding - titleRect.origin.y),
                                                        -(selfWidth/2 - titleRect.origin.x - titleRect.size.width /2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 - imageRect.origin.y),
                                                        (selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        -((selfHeight - totalHeight)/2 - imageRect.origin.y),
                                                        -(selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2));
                
            }
                break;
            case ButtonImageTitleStyleBottom:
            {
                //图片在下，文字在上。
                self.titleEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 - titleRect.origin.y),
                                                        (selfWidth/2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                        -((selfHeight - totalHeight)/2 - titleRect.origin.y),
                                                        -(selfWidth/2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(((selfHeight - totalHeight)/2 + titleRect.size.height + padding - imageRect.origin.y),
                                                        (selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        -((selfHeight - totalHeight)/2 + titleRect.size.height + padding - imageRect.origin.y),
                                                        -(selfWidth /2 - imageRect.origin.x - imageRect.size.width / 2));
            }
                break;
            case ButtonImageTitleStyleCenterTop:
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(-(titleRect.origin.y - padding),
                                                        (selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                        (titleRect.origin.y - padding),
                                                        -(selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                        (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        0,
                                                        -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2));
            }
                break;
            case ButtonImageTitleStyleCenterBottom:
            {
                self.titleEdgeInsets = UIEdgeInsetsMake((selfHeight - padding - titleRect.origin.y - titleRect.size.height),
                                                        (selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                        -(selfHeight - padding - titleRect.origin.y - titleRect.size.height),
                                                        -(selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                        (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        0,
                                                        -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2));
            }
                break;
            case ButtonImageTitleStyleCenterUp:
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(-(titleRect.origin.y + titleRect.size.height - imageRect.origin.y + padding),
                                                        (selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                        (titleRect.origin.y + titleRect.size.height - imageRect.origin.y + padding),
                                                        -(selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                        (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        0,
                                                        -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2));
            }
                break;
            case ButtonImageTitleStyleCenterDown:
            {
                self.titleEdgeInsets = UIEdgeInsetsMake((imageRect.origin.y + imageRect.size.height - titleRect.origin.y + padding),
                                                        (selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                                        -(imageRect.origin.y + imageRect.size.height - titleRect.origin.y + padding),
                                                        -(selfWidth / 2 -  titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2);
                
                self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                        (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                                        0,
                                                        -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2));
            }
                break;
            case ButtonImageTitleStyleRightLeft:    //图片在右，文字在左，距离按钮两边边距
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(0, -(titleRect.origin.x - padding), 0, (titleRect.origin.x - padding));
                self.imageEdgeInsets = UIEdgeInsetsMake(0, (selfWidth - padding - imageRect.origin.x - imageRect.size.width), 0, -(selfWidth - padding - imageRect.origin.x - imageRect.size.width));
            }
                break;
                
            case ButtonImageTitleStyleRightLeftSpacing:    //图片在右，文字在左，距离默认10
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(0, (selfWidth - padding - imageRect.size.width - titleRect.origin.x - titleRect.size.width - betweenSpace), 0, -(selfWidth - padding - imageRect.size.width - titleRect.origin.x - titleRect.size.width - betweenSpace));
                self.imageEdgeInsets = UIEdgeInsetsMake(0, (selfWidth - padding - imageRect.origin.x - imageRect.size.width), 0, -(selfWidth - padding - imageRect.origin.x - imageRect.size.width));
            }
                break;
                
            case ButtonImageTitleStyleLeftRight:    //图片在左，文字在右，距离按钮两边边距
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(0, (selfWidth - padding - titleRect.origin.x - titleRect.size.width), 0, -(selfWidth - padding - titleRect.origin.x - titleRect.size.width));
                self.imageEdgeInsets = UIEdgeInsetsMake(0, -(imageRect.origin.x - padding), 0, (imageRect.origin.x - padding));
            }
                break;
                
            case ButtonImageTitleStyleLeftRightSpacing:    //图片在左，文字在右，距离默认10
            {
                self.titleEdgeInsets = UIEdgeInsetsMake(0, (selfWidth - padding - titleRect.origin.x - titleRect.size.width), 0, -(selfWidth - padding - titleRect.origin.x - titleRect.size.width));
                self.imageEdgeInsets = UIEdgeInsetsMake(0, (imageRect.origin.x - betweenSpace - padding), 0, -(imageRect.origin.x - betweenSpace - padding));
            }
                break;
                
                
            default:
                break;
        }
    } else {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

+ (UIButton *)insertSuperView:(UIView *)view
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = view.bounds;
    btn.backgroundColor = [UIColor clearColor];
    [view insertSubview:btn atIndex:0];
    
    return btn;
}

@end
