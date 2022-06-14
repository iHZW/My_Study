//
//  PASBorderTableViewCell.h
//  PASecuritiesApp
//
//  Created by Weirdln on 15/9/27.
//
//

#import <UIKit/UIKit.h>
#import "PASBorderBackgroundView.h"
#import "CMTableViewCell.h"

/**
 *  统一设置cell的border，需要self.contentView为透明色，如果需要设置颜色直接设置self.
 */
@interface PASBorderTableViewCell : CMTableViewCell

/** 边框位置，赋值会刷新view，需要最后设置 */
@property(nonatomic) PASBorderOption borderOption;
/** 上下两边的横向inset，赋值不会刷新view，需要设置borderOption */
@property(nonatomic) UIEdgeInsets borderInset;
/** 左右两边的竖向inset,默认跟横向一致，一般collection cell左右边框或边线是设置 */
@property(nonatomic) UIEdgeInsets vertiBorderInset;
/** 线的宽度，默认0.5 */
@property (nonatomic) CGFloat lineBolder;

@end
