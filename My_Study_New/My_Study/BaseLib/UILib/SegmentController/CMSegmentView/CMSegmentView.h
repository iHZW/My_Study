//
//  CMSegmentView.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/27.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMView.h"
#import "CMScrollSegmentControl.h"

typedef UIView * (^CMSegmentViewLoadViewBlock)(NSInteger index);
typedef void (^CMSegementViewActionBlock)(NSInteger index, UIView *view, UIView *lastView);

typedef void (^ScrollTopWhenClickStatusBarAction)(NSInteger index, UIView *view, BOOL scrollWhenClickStatusBar);

@interface CMSegmentView : CMView

/**
 *  segmentView 控件，可以由此设置相关显示属性
 */
@property (nonatomic, readonly) CMScrollSegmentControl *segmentControl;

/**
 *  CMSegmentView 点击后Block回调
 */
@property (nonatomic, copy) CMSegementViewActionBlock actionBlock;

/**
 *  加载View 回调
 */
@property (nonatomic, copy) CMSegmentViewLoadViewBlock viewLoadDataBlock;

/**
 *  确保当前Segment切换时，点击StatusBar时，scrollview滚动自顶
 */
@property (nonatomic, copy) ScrollTopWhenClickStatusBarAction scrollClickStatusBarAction;

/**
 *  Segment显示Title数组信息
 */
@property (nonatomic, strong) NSArray *titles;

/**
 *  segment 区域 Insets 偏移量 (默认 UIEdgeInsetsMake(0, 0, 0, 0))
 */
@property (nonatomic, assign) UIEdgeInsets segmentInsets;

/**
 *  segment 显示区域 (默认 CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 36))
 */
@property (nonatomic) CGRect segmentRect;

/**
 *  整体容器显示区域(此区域包括segmentRect 默认 CGRectMake(0, CGRectGetHeight(_segmentRect), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(_segmentRect))
 */
@property (nonatomic) CGRect containerFrame;


/**
 *  重新加载对应view
 */
- (void)reloadData;


/**
 *  重新布局视图
 */
- (void)layoutSubviewsIfNeeded;

/**
 *  获取当前选中的View页面
 *
 *  @return 返回View对象
 */
- (UIView *)currentSelectedView;

/**
 *  设置当前选中Segment项
 *
 *  @param segmentIdx 索引值
 */
- (void)setSegmentIndex:(NSInteger)segmentIdx;

@end
