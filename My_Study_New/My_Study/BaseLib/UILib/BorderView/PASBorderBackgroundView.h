//
//  PASBorderBackgroundView.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/30.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CMView.h"

static const UIEdgeInsets kDefaultBorderInset = {0, 15, 0, 0};

// border类型，head代表left或者top，trail代表right或者bottom
typedef NS_OPTIONS(NSInteger, PASBorderOption) {
    PASBorderOptionNone               = 0,
    PASBorderOptionTop                = 1 << 0,
    PASBorderOptionBottom             = 1 << 1,
    PASBorderOptionLeft               = 1 << 2,
    PASBorderOptionRight              = 1 << 3,
    PASBorderOptionTopNoInset         = 1 << 4,
    PASBorderOptionBottomNoInset      = 1 << 5,
    PASBorderOptionLeftNoInset        = 1 << 6,
    PASBorderOptionRightNoInset       = 1 << 7,
    PASBorderOptionHeadSeparateSpace  = 1 << 8,// 和top或者left实现间隔条
    PASBorderOptionTrailSeparateSpace = 1 << 9,// 和bottom或者right实现间隔条
    PASBorderOptionAllNoInset         = PASBorderOptionTopNoInset | PASBorderOptionBottomNoInset | PASBorderOptionLeftNoInset | PASBorderOptionRightNoInset,
};

@interface PASBorderBackgroundView : UIView

 /** 边框位置 */
@property(nonatomic) PASBorderOption borderOption;
 /** 上下两边的横向inset */
@property(nonatomic) UIEdgeInsets borderInset;
 /** 左右两边的竖向inset,默认跟横向一致，一般collection cell左右边框或边线是设置 */
@property(nonatomic) UIEdgeInsets vertiBorderInset;
 /** 线的宽度，默认0.5 */
@property (nonatomic) CGFloat lineBolder;

- (void)setShortColor:(UIColor *)shortColor;

- (void)setLongColor:(UIColor *)longColor;

- (void)setSeparateColor:(UIColor *)separateColor;

@end
