//
//  PASIndicatorTableViewCell.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/6.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASBorderTableViewCell.h"

static NSString *pasIndicatorCellIdentifier = @"pasIndicatorCellIdentifier";

/**
 *  带指示箭头的cell，根据属性的调用情况动态alloc控件，image需要在label之前设置，否则需要手动调整布局
 */
@interface PASIndicatorTableViewCell : PASBorderTableViewCell

@property (nonatomic) CGFloat middleOffset;  /** 中间控件与contentview的offset，不设置默认与leftLabel相距10或者居中 */

@property (nonatomic, strong, readonly) UIImageView *leftIconImageView; /** 一定要在leftLabel之前调用 */
@property (nonatomic, strong, readonly) UIImageView *rightIconImageView; /** 一定要在rightLabel之前调用 */

@property (nonatomic, strong, readonly) UILabel *leftLabel; /** 布局需要根据leftIconImageView是否存在调整 */
@property (nonatomic, strong, readonly) UILabel *middleLabel; /** 布局低优先级居中，可以调整 */
@property (nonatomic, strong, readonly) UILabel *rightLabel; /** 布局需要根据rightIconImageView是否存在调整 */
@property (nonatomic, strong, readonly) UILabel *bottomLabel; /** 根据midedelabel来展示，一般是银行卡的活动 */

@property (nonatomic, strong, readonly) UIButton *button; /** 布局默认靠右,宽度60 */
@property (nonatomic, strong, readonly) UITextField *textField; /** 布局需要依赖leftLabel,据leftLabel是否存在调整 */

@property (nonatomic, strong, readonly) UILabel *statusLabel;   /** 布局默认居中,在middleLabel下方 */
@end
