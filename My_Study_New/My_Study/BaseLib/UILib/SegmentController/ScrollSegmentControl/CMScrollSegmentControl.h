//
//  CMScrollSegmentControl.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  SegmentControl Indicator 显示方式
 */
typedef NS_ENUM(NSInteger, CustomSegmentIndicatorMode){
    /**
     *  Indicator 宽度与文字等宽
     */
    CustomSegmentIndicatorResizesToStringWidth,
    /**
     *  Indicator 宽度与Segment等宽
     */
    CustomSegmentIndicatorFillsSegment,
    /**
     *  Indicator 自定义宽度
     */
    CustomSegmentIndicatorCustomWidth,
};

/**
 *  Indicator 显示未知
 */
typedef NS_ENUM(NSInteger, IndicatorAlignmentType){
    /**
     *  在顶部显示Indicator
     */
    IndicatorAlignmentTop,
    /**
     *  在底部显示Indicator
     */
    IndicatorAlignmentBottom,
};


@interface CMScrollSegmentViewCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *cellBtn;
@property (nonatomic, strong) UILabel *badgeLabel;//右上角角标1.2.3
@property (nonatomic, strong) UIView *sepView;
@property (nonatomic, strong) UIImageView *indicatorImageView; /*自定义下方指示图片，在view最上层  */

@end


typedef void (^CustomSegmentControlBlock)(NSInteger index, NSString *title);

typedef void (^CustomSegmentLoadCellViewBlock)(NSInteger index, CMScrollSegmentViewCell *segmentCellView);

typedef CGFloat (^CustomSegmentControlItemWidthBlock)(NSInteger index);

@interface CMScrollSegmentControl : UIView

/**
 *  显示字体 default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]
 */
@property (nonatomic, strong) UIFont *font;

/**
 *  显示选中字体 default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]
 */
@property (nonatomic, strong) UIFont *selectFont;

/**
 *  默认状态显示字体颜色 default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 *  选中状态显示字体颜色 default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *selectTextColor;

/**
 *  indicator 显示颜色 default is [UIColor blackColor];
 */
@property (nonatomic, strong, setter=setIndicatorColor:) UIColor *indicatorColor;

/**
 *  indicator 显示高度 default is 5
 */
@property (nonatomic, readwrite) CGFloat indicatorHeight;

/**
 *  仅当 CustomSegmentIndicatorCustomWidth 状态下生效
 */
@property (nonatomic, readwrite) CGFloat indicatorWidth;

/**
 *  Indicator 显示模式
 */
@property (nonatomic) CustomSegmentIndicatorMode indicatorMode;

/**
 *  自定义Indicator 显示图片
 */
@property (nonatomic, strong) UIImage *indicatorImage;

/**
 *  自定义Indicator 选中显示图片
 */
@property (nonatomic, strong) UIImage *selectIndicatorImage;

/**
 *  Indicator 显示未知 default 在底部显示
 */
@property (nonatomic) IndicatorAlignmentType alignType;

/**
 *  segment item 显示宽度 default is frame.width / 4, 如果指定itemWidthBlock属性后，会忽略此属性设置
 */
@property (nonatomic) CGFloat segmentItemWidth;

/**
 *  border color
 */
@property (nonatomic, strong, setter=setBorderColor:) UIColor *borderColor;

/**
 *  是否显示纵线分割线
 */
@property (nonatomic) BOOL showSeporator;

/**
 *  纵线分割线color
 */
@property (nonatomic, strong) UIColor *seporatorColor;

/**
 *  Segment Control 显示内容
 */
@property (nonatomic, strong, setter=setListData:) NSArray *listData;

/**
 角标数组
 */
@property (nonatomic, strong, setter=setBadgeDataArray:) NSArray *badgeDataArray;

/**
 角标宽度
 */
@property (nonatomic, assign) CGFloat badgeWidth;

/**
 角标背景颜色
 */
@property (nonatomic, strong) UIColor *badgeBackColor;

/**
 角标颜色
 */
@property (nonatomic, strong) UIColor *badgeTextColor;

/**
 *  Segment Click Block回调
 */
@property (nonatomic, copy) CustomSegmentControlBlock actionBlock;

/**
 *  Segment cell 刷新cell view block，用于自定义segment头部
 */
@property (nonatomic, copy) CustomSegmentLoadCellViewBlock loadCellBlock;

/**
 *  Segment Item 宽度指定
 */
@property (nonatomic, copy) CGFloat (^itemWidthBlock)(NSInteger index);

/**
 *  当前选中索引值
 */
@property (nonatomic, readonly) NSInteger selectedIndex;

/**
 *  segment 控件顶部边缘线调
 */
@property (nonatomic, strong, readonly) UIView *toplineView;

/**
 *  segment 控件底部边缘线调
 */
@property (nonatomic, strong, readonly) UIView *bottomlineView;

/**
 *  支持滚动的区域容器
 */
@property (nonatomic, strong, readonly) UICollectionView *containerView;

/**
 *  重新指定选择的Segment Item
 *
 *  @param index 选择索引
 */
- (void)changeSelectIndex:(NSUInteger)index;

@end
