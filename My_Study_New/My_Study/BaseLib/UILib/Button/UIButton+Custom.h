//
//  UIButton+Custom.h
//  PASecuritiesApp
//
//  Created by vince on 16/2/23.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandleButtonBlock)(id);

typedef enum : NSUInteger {
    
    ButtonTitleRight,          //image 居左
    ButtonTitleLeft,           //image 居右
    
} ButtonTitleAlign;


/*
 针对同时设置了Image和Title的场景时UIButton中的图片和文字的关系
 */
typedef NS_ENUM(NSInteger, ButtonImageTitleStyle ) {
    ButtonImageTitleStyleDefault = 0,       //图片在左，文字在右，整体居中。
    ButtonImageTitleStyleLeft  = 0,         //图片在左，文字在右，整体居中。
    ButtonImageTitleStyleRight     = 2,     //图片在右，文字在左，整体居中。
    ButtonImageTitleStyleTop  = 3,          //图片在上，文字在下，整体居中。
    ButtonImageTitleStyleBottom    = 4,     //图片在下，文字在上，整体居中。
    ButtonImageTitleStyleCenterTop = 5,     //图片居中，文字在上距离按钮顶部。
    ButtonImageTitleStyleCenterBottom = 6,  //图片居中，文字在下距离按钮底部。
    ButtonImageTitleStyleCenterUp = 7,      //图片居中，文字在图片上面。
    ButtonImageTitleStyleCenterDown = 8,    //图片居中，文字在图片下面。
    ButtonImageTitleStyleRightLeft = 9,     //图片在右，文字在左，距离按钮两边边距
    ButtonImageTitleStyleLeftRight = 10,    //图片在左，文字在右，距离按钮两边边距
    ButtonImageTitleStyleRightLeftSpacing = 11,     //图片在右，文字在左，距离默认5
    ButtonImageTitleStyleLeftRightSpacing = 12,    //图片在左，文字在右，距离默认5
    
};

@interface UIButton (Custom)


/**
 *  对有image和title的按钮重新布局
 *
 *  @param titleAlign title在左或者右
 *  @param hspace     title和图片之间间距
 */
- (void)relayoutButtonWithTitleAlign:(ButtonTitleAlign)titleAlign hspace:(CGFloat)hspace;

/**
 *  创建一个带title和image 的button
 *
 *  @param title          必传
 *  @param normalImageStr 必传
 *  @param hightImageStr
 *  @param hspace         图文间隔
 *  @param titleAlign     文字位置
 *  @param block           有按钮参数的block
 *
 *  @return
 */
+ (UIButton *)pas_buttonWithFrame:(NSString *)title
                      normalImage:(NSString *)normalImageStr
                       hightImage:(NSString *)hightImageStr
                           hspace:(CGFloat)hspace
                       titleAlign:(ButtonTitleAlign)titleAlign
                            block:(HandleButtonBlock)block;

/**
 *  创建一个带title和image 的button
 *
 *  @param frame               frame
 *  @param title               title
 *  @param titleColor          titlecolor
 *  @param backgroudImageColor 背景图颜色
 *  @param normalImage         正常image
 *  @param hightImage          高亮image
 *  @param hspace              title和image之间间距
 *  @param titleAlign          title在左或者右，默认为右
 *  @param target              <#target description#>
 *  @param selector            <#selector description#>
 *  @param block               可以对button进行设置
 *
 *  @return <#return value description#>
 */
+ (UIButton *)pas_buttonWithFrame:(CGRect)frame
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
               bgImageNormalColor:(UIColor *)backgroudImageColor
                      normalImage:(UIImage *)normalImage
                       hightImage:(UIImage *)hightImage hspace:(CGFloat)hspace
                       titleAlign:(ButtonTitleAlign)titleAlign
                           target:(id)target
                         selector:(SEL)selector
                            block:(HandleButtonBlock)block;

/**
 *  创建button
 *
 *  @param buttonType          类型
 *  @param frame               frame
 *  @param title               <#title description#>
 *  @param titleColor          <#titleColor description#>
 *  @param backgroudImageColor 按钮背景图片色值
 *  @param target              <#target description#>
 *  @param selector            <#selector description#>
 *
 *  @return <#return value description#>
 */
+ (UIButton *)pas_buttonWithCustom:(UIButtonType)buttonType
                             frame:(CGRect)frame
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                bgImageNormalColor:(UIColor *)backgroudImageColor
                            target:(id)target
                          selector:(SEL)selector;

- (void)setButtonImageTitleStyle:(ButtonImageTitleStyle)style padding:(CGFloat)padding;

+ (UIButton *)insertSuperView:(UIView *)view;

@end
