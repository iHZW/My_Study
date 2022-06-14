//
//  PASTableViewHeaderView.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/8/9.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASTableViewHeaderView : UIView

@property (nonatomic) CGFloat middleOffset;  /** 中间控件与contentview的offset，不设置默认居中 */

@property (nonatomic, strong, readonly) UILabel *leftLabel; /** left 15 左对齐 */
@property (nonatomic, strong, readonly) UILabel *middleLabel; /** 布局低优先级居中，可以调整 */
@property (nonatomic, strong, readonly) UILabel *rightLabel; /** right 15 右对齐 */

@property (nonatomic, strong, readonly) UILabel *rightLabel2; /**   有些需要四个label    */


/**
 *  如果有四个label的时候，重新约束全部的label
 */
- (void)updateAllSubViews;

@end
