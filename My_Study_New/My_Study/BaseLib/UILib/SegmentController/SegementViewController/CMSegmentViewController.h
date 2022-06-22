//
//  CMSegmentViewController.h
//  PASecuritiesApp
//
//  Created by Howard on 16/2/15.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMViewController.h"
#import "CMScrollSegmentControl.h"

#define kTopSegmentHeight     PASFactor(36)

/** Segment类型 */
typedef NS_ENUM(NSInteger, SegmentControlType) {
    SegmentControlTypeDefault, /** 自定义类型（默认） */
    SegmentControlTypeSystem, /** 系统自带类型 */
};

typedef UIViewController * (^CMSegmentViewLoadControllerBlock)(NSInteger index);

typedef void (^CMSegementViewControllerActionBlock)(NSInteger index, UIViewController *viewController, UIViewController *lastViewController);

typedef void (^ScrollTopControllerWhenClickStatusBarAction)(NSInteger index, UIViewController *viewController, BOOL scrollWhenClickStatusBar);


@interface CMSegmentViewController : CMViewController

/**
 *  SegmentControl的类型
 */
@property (nonatomic) SegmentControlType segmentType;

/**
 *  segmentView 控件，可以由此设置相关显示属性
 */
@property (nonatomic, readonly) CMScrollSegmentControl *segmentControl;

/**
 *  系统默认的SegmentedControl
 */
@property (nonatomic, strong, readonly) UISegmentedControl *segment;

/**
 *  CMSegmentView 点击后Block回调
 */
@property (nonatomic, copy) CMSegementViewControllerActionBlock actionBlock;

/**
 *  加载ViewController 回调
 */
@property (nonatomic, copy) CMSegmentViewLoadControllerBlock loadDataBlock;

/**
 *  确保当前Segment切换时，点击StatusBar时，scrollview滚动自顶
 */
@property (nonatomic, copy) ScrollTopControllerWhenClickStatusBarAction scrollClickStatusBarAction;

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
 *  scrollView 是否可以滑动，default YES. turn off any dragging temporarily
 */
@property (nonatomic) BOOL scrollEnabled;

/**
 *  当前segment索引值
 */
@property (nonatomic, readonly) NSInteger currentSelIndex;

/**
 *  重新加载对应view controllers
 */
- (void)reloadData;

/**
 遍历整个segment Controller 对象
 
 @param block block回调
 */
- (void)enumerateAllSegementControllers:(void (^)(NSInteger index, UIViewController *viewController))block;

/**
 *  重新布局视图
 */
- (void)layoutSubviewsIfNeeded;

/**
 *  获取当前选中的ViewController页面
 *
 *  @return 返回ViewController对象
 */
- (UIViewController *)currentSelectedViewController;

/**
 *  设置当前选中Segment项
 *
 *  @param segmentIdx 索引值
 */
- (void)setSegmentIndex:(NSInteger)segmentIdx;

/**
 头部灰线
 * 创建头部灰色线
 */
- (void)createGrayLine;

@end
