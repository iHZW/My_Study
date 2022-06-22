//
//  CMSegmentView.m
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/27.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMSegmentView.h"

@interface CMSegmentView () <UIScrollViewDelegate>

/**
 *  segmentView 控件，可以由此设置相关显示属性
 */
@property (nonatomic, strong) CMScrollSegmentControl *segmentControl;

/**
 *  滚动容器
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 *  View缓存记录
 */
@property (nonatomic, strong) NSMutableDictionary *vcDic;

/**
 *  当前segment索引值
 */
@property (nonatomic) NSInteger currentSelIndex;

/**
 *  页面展示纵向坐标位置
 */
@property (nonatomic) CGFloat yPos;

@end


@implementation CMSegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initExtendedData];
        [self creatUI];
    }
    return self;
}

/**
 *  移除所有子view
 */
- (void)removeAllChildremoveAllChildViewss
{
    for (NSNumber *idx in [self.vcDic allKeys])
    {
        UIView *view = self.vcDic[idx];
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
}

/**
 *  通过索引载入指定的view
 *
 *  @param index 索引值
 *
 *  @return 返回对应的view对象
 */
- (UIView *)loadViewWithIndex:(NSInteger)index
{
    UIView *view = self.vcDic[@(index)];
    
    if (self.viewLoadDataBlock)
    {
        if (!view)
        {
            view = self.viewLoadDataBlock(index);
            if (view)
            {
                [self.vcDic setObject:view forKey:@(index)];
                view.frame = CGRectMake(index * CGRectGetWidth(self.containerFrame), 0, CGRectGetWidth(self.containerFrame),  CGRectGetHeight(self.containerFrame));
                [self.scrollView addSubview:view];
            }
        }
        
        if (self.scrollClickStatusBarAction)
        {
            self.scrollClickStatusBarAction(index, view, index == self.segmentControl.selectedIndex);
        }
        //        else
        //        {
        //            [self.scrollView bringSubviewToFront:vc.view];
        //        }
    }
    return view;
}

- (void)creatUI
{
    CGFloat width = CGRectGetWidth(_containerFrame);
    CGFloat height = CGRectGetHeight(_containerFrame);
    _yPos = CGRectGetMinY(_containerFrame);
    
    self.segmentControl = [[CMScrollSegmentControl alloc] initWithFrame:CGRectMake(_segmentInsets.left, _segmentInsets.top + CGRectGetMinY(_segmentRect), width - _segmentInsets.left - _segmentInsets.right, CGRectGetHeight(_segmentRect) - _segmentInsets.top - _segmentInsets.bottom)];
    [self addSubview:_segmentControl];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _yPos, width, height)];
    _scrollView.delegate = self;
    [_scrollView setMultipleTouchEnabled:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setDirectionalLockEnabled:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    [self addSubview:_scrollView];
    
    __weak __typeof__(self) weakSelf = self;
    _segmentControl.actionBlock = ^ (NSInteger index, NSString *title) {
        [weakSelf changeScrollToTopStatus:index];
        [weakSelf.scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(weakSelf.scrollView.frame), 0) animated:NO];
    };
    
    [self callActionBlockFunction];
}

/**
 *  加载View数据
 */
- (void)callActionBlockFunction
{
    if (self.actionBlock)
    {
        UIView *lastView = [self loadViewWithIndex:self.currentSelIndex];
        UIView *view = [self loadViewWithIndex:self.segmentControl.selectedIndex];
        self.currentSelIndex = self.segmentControl.selectedIndex;
        
        if (self.actionBlock)
        {
            self.actionBlock(self.currentSelIndex, view, lastView);
        }
    }
}

/**
 *  更改当前scrollToTop 状态
 *
 *  @param index child viewcontroler 索引
 */
- (void)changeScrollToTopStatus:(NSInteger)index
{
    if (self.scrollClickStatusBarAction && index >= 0 && index < [_vcDic allKeys].count)
    {
        for (NSNumber *idx in [_vcDic allKeys])
        {
            UIView *view = _vcDic[idx];
            BOOL status = [idx integerValue] == index ? YES : NO;
            self.scrollClickStatusBarAction([idx integerValue], view, status);
        }
    }
    [self callActionBlockFunction];
}

/**
 *  设置选中Segment Page项
 *
 *  @param index   segment 索引值
 *  @param forceRequest 是否强制刷新数据
 */
- (void)setCurrentSelectedPage:(NSInteger)index foreceRequest:(BOOL)forceRequest
{
    [_segmentControl changeSelectIndex:index];
    [_scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

/**
 *  扩展的初始化数据(子类继承时,子类初始化数据处理可在此函数中进行数据初始化)
 */
- (void)initExtendedData
{
    _segmentInsets  = UIEdgeInsetsMake(0, 0, 0, 0);
    _segmentRect    = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 36);
    _containerFrame = CGRectMake(0, CGRectGetHeight(_segmentRect), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(_segmentRect));
    self.titles                 = @[];
    self.currentSelIndex        = 0;
    self.backgroundColor   = [UIColor whiteColor];
    self.vcDic                  = [NSMutableDictionary dictionary];
}

/**
 *  重新加载对应view
 */
- (void)reloadData
{
    [self removeAllChildremoveAllChildViewss];
    [_segmentControl setListData:_titles];
    CGFloat width = MAX(CGRectGetWidth(_scrollView.frame) * _titles.count, CGRectGetWidth(_scrollView.frame));
    CGFloat height = CGRectGetHeight(_scrollView.frame);
    [_scrollView setContentSize:CGSizeMake(width, height)];
    [self setCurrentSelectedPage:_currentSelIndex foreceRequest:NO];
}

/**
 *  重新布局视图
 */
- (void)layoutSubviewsIfNeeded
{
    CGFloat width = CGRectGetWidth(_containerFrame);
    CGFloat height = CGRectGetHeight(_containerFrame);
    _yPos = CGRectGetMinY(_containerFrame);
    
    [_segmentControl setFrame:CGRectMake(_segmentInsets.left, _segmentInsets.top + CGRectGetMinY(_segmentRect), width - _segmentInsets.left - _segmentInsets.right, CGRectGetHeight(_segmentRect) - _segmentInsets.top - _segmentInsets.bottom)];
    
    [_segmentControl layoutSubviews];
    
    [_scrollView setFrame:CGRectMake(0, _yPos, width, height)];
    
    for (NSNumber *idx in [_vcDic allKeys])
    {
        UIView *view = _vcDic[idx];
        if ([view isKindOfClass:[UIView class]])
        {
            CGRect tempFrame = view.frame;
            tempFrame.size.height = CGRectGetHeight(_containerFrame);
            tempFrame.size.width = CGRectGetWidth(_containerFrame);
            [view setFrame:tempFrame];
        }
    }
}

- (UIView *)currentSelectedView
{
    UIView *view = [self loadViewWithIndex:self.segmentControl.selectedIndex];
    return view;
}

/**
 *  设置当前选中Segment项
 *
 *  @param segmentIdx 索引值
 */
- (void)setSegmentIndex:(NSInteger)segmentIdx
{
    _currentSelIndex = segmentIdx;
    [self setCurrentSelectedPage:_currentSelIndex foreceRequest:NO];
}

#pragma mark - UIScrollViewDelegate's
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger nextIndex = index + 1;
    NSInteger prevIndex = index - 1;
    
    if (nextIndex < _segmentControl.listData.count)
        [self loadViewWithIndex:nextIndex];
    
    if (prevIndex >= 0)
        [self loadViewWithIndex:prevIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self setCurrentSelectedPage:index foreceRequest:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
