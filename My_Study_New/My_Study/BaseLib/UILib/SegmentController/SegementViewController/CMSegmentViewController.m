//
//  CMSegmentViewController.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/15.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMSegmentViewController.h"
#import "UIColor+Extensions.h"
#import "PASUIDefine.h"
#import "masonry.h"


@interface CMSegmentViewController () <UIScrollViewDelegate>

/**
 *  segmentView 控件，可以由此设置相关显示属性
 */
@property (nonatomic, strong) CMScrollSegmentControl *segmentControl;

/**
 *  系统默认的SegmentedControl
 */
@property (nonatomic, strong) UISegmentedControl *segment;

/**
 *  滚动容器
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 *  ViewController缓存记录
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


@implementation CMSegmentViewController

/**
 *  移除所有子viewController
 */
- (void)removeAllChildViewControllers
{
    for (NSNumber *idx in [_vcDic allKeys])
    {
        id obj = _vcDic[idx];
        if ([obj isKindOfClass:[UIViewController class]])
        {
            UIViewController *vc = (UIViewController *)obj;
            [vc willMoveToParentViewController:nil];
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
}

/**
 *  通过索引载入指定的ViewController
 *
 *  @param index 索引值
 *
 *  @return 返回对应的ViewController对象
 */
- (UIViewController *)loadViewControllerWithIndex:(NSInteger)index
{
    UIViewController *vc = _vcDic[@(index)];
    
    if (self.loadDataBlock)
    {
        if (!vc)
        {
            vc = self.loadDataBlock(index);
            if (vc)
            {
                [_vcDic setObject:vc forKey:@(index)];
                vc.view.frame = CGRectMake(index * CGRectGetWidth(_containerFrame), 0, CGRectGetWidth(_containerFrame),  CGRectGetHeight(_containerFrame));
                [self.scrollView addSubview:vc.view];
                [self addChildViewController:vc];
            }
        }
        
        if (self.scrollClickStatusBarAction)
        {
            self.scrollClickStatusBarAction(index, vc, index == _segmentControl.selectedIndex);
        }
//        else
//        {
//            [self.scrollView bringSubviewToFront:vc.view];
//        }
    }
    return vc;
}

- (void)creatUI
{
    CGFloat width       = CGRectGetWidth(_containerFrame);
    CGFloat height      = CGRectGetHeight(_containerFrame);
    _yPos               = CGRectGetMinY(_containerFrame);

    self.segmentControl = [[CMScrollSegmentControl alloc] initWithFrame:CGRectMake(_segmentInsets.left, _segmentInsets.top + CGRectGetMinY(_segmentRect), width - _segmentInsets.left - _segmentInsets.right, CGRectGetHeight(_segmentRect) - _segmentInsets.top - _segmentInsets.bottom)];
    
    [self.view addSubview:_segmentControl];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _yPos, width, height)];
    
    _scrollView.delegate = self;
    [_scrollView setMultipleTouchEnabled:NO];
    [_scrollView setExclusiveTouch:YES];
    [_scrollView setDelaysContentTouches:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setDirectionalLockEnabled:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    [self.view addSubview:_scrollView];
    
    __weak __typeof__(self) weakSelf = self;
    _segmentControl.actionBlock = ^ (NSInteger index, NSString *title) {
        [weakSelf changeScrollToTopStatus:index];
        [weakSelf.scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(weakSelf.scrollView.frame), 0) animated:NO];
    };
    
    [self callActionBlockFunction];
}

- (void)creatSystemSegmentViewUI
{
    self.segment = [[UISegmentedControl alloc] initWithFrame:_segmentRect];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [_segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    _segment.selectedSegmentIndex = self.currentSelIndex;
    _segment.tintColor = UIColorFromRGB(0xf34141);
    [_segment setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [_segment setBackgroundImage:[UIImage imageNamed:@"segment_unselected"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segment setBackgroundImage:[UIImage imageNamed:@"segment_selected"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segment addTarget:self action:@selector(segClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:_containerFrame];
    _scrollView.delegate = self;
    _scrollView.scrollEnabled = NO;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setDirectionalLockEnabled:YES];
    [_scrollView setPagingEnabled:YES];
    [self.view addSubview:_scrollView];
    
    UIViewController *vc = [self loadViewControllerWithIndex:_segment.selectedSegmentIndex];
    _currentSelIndex = 0;
    
    if (self.actionBlock)
    {
        self.actionBlock(_segment.selectedSegmentIndex, vc, nil);
    }
}

/**
 *  加载ViewController数据
 */
- (void)callActionBlockFunction
{
    if (self.actionBlock)
    {
        UIViewController *lastVC = [self loadViewControllerWithIndex:_currentSelIndex];
        UIViewController *vc = nil;
        if (self.segmentType == SegmentControlTypeSystem)
        {
            vc = [self loadViewControllerWithIndex:_segment.selectedSegmentIndex];
            _currentSelIndex = _segment.selectedSegmentIndex;
        }
        else
        {
            vc = [self loadViewControllerWithIndex:_segmentControl.selectedIndex];
            _currentSelIndex = _segmentControl.selectedIndex;
        }
        
        self.actionBlock(_currentSelIndex, vc, lastVC);
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
            UIViewController *vc = _vcDic[idx];
            BOOL status = [idx integerValue] == index ? YES : NO;
            self.scrollClickStatusBarAction([idx integerValue], vc, status);
        }
    }
    
    [self callActionBlockFunction];
}

/**
 *  设置选中Segment Page项
 *
 *  @param index        @param index segment 索引值
 *  @param forceRequest 是否强制刷新数据
 */
- (void)setCurrentSelectedPage:(NSInteger)index foreceRequest:(BOOL)forceRequest
{
    if (self.segmentType == SegmentControlTypeSystem)
    {
        _segment.selectedSegmentIndex = index;
        [self segClick:_segment];
    }
    else
    {
        [_segmentControl changeSelectIndex:index];
    }
    [_scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.segmentType == SegmentControlTypeSystem)
    {
        [self creatSystemSegmentViewUI];
    }
    else
    {
        [self creatUI];
    }
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
    self.vcDic                  = [NSMutableDictionary dictionary];
}

- (void)setSegmentRect:(CGRect)segmentRect
{
    _segmentRect = segmentRect;
}

/**
 *  内存告警调用(子类继承时,子类收到内存告警时可在此函数中进行处理)
 */
- (void)receiveLowMemoryWarning
{
    
}

- (void)dealloc
{
    self.actionBlock                = nil;
    self.scrollClickStatusBarAction = nil;
}

/**
 *  重新加载对应view controllers
 */
- (void)reloadData
{
    [self removeAllChildViewControllers];
    if (self.segmentType == SegmentControlTypeSystem)
    {
        [_segment removeAllSegments];
        [_titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
            [_segment insertSegmentWithTitle:title atIndex:idx animated:NO];
        }];
    }
    else
    {
        [_segmentControl setListData:_titles];
    }
    
    CGFloat width = MAX(CGRectGetWidth(_scrollView.frame) * _titles.count, CGRectGetWidth(_scrollView.frame));
    CGFloat height = CGRectGetHeight(_scrollView.frame);
    [_scrollView setContentSize:CGSizeMake(width, height)];
    [self setCurrentSelectedPage:_currentSelIndex foreceRequest:NO];
}

/**
 遍历整个segment Controller 对象

 @param block block回调
 */
- (void)enumerateAllSegementControllers:(void (^)(NSInteger index, UIViewController *viewController))block
{
    if (block) {
        for (NSNumber *idx in [_vcDic allKeys]) {
            id obj = _vcDic[idx];
            if ([obj isKindOfClass:[UIViewController class]]) {
                UIViewController *vc = (UIViewController *)obj;
                block([idx integerValue], vc);
            }
        }
    }
}

/**
 *  重新布局视图
 */
- (void)layoutSubviewsIfNeeded
{
    CGFloat width  = CGRectGetWidth(_containerFrame);
    CGFloat height = CGRectGetHeight(_containerFrame);
    _yPos          = CGRectGetMinY(_containerFrame);
    
    if (self.segmentType == SegmentControlTypeSystem)
    {
        [_segment setFrame:CGRectMake(_segmentInsets.left, _segmentInsets.top + CGRectGetMinY(_segmentRect), width - _segmentInsets.left - _segmentInsets.right, CGRectGetHeight(_segmentRect) - _segmentInsets.top - _segmentInsets.bottom)];
        [_segment layoutSubviews];
    }
    else
    {
        [_segmentControl setFrame:CGRectMake(_segmentInsets.left, _segmentInsets.top + CGRectGetMinY(_segmentRect), width - _segmentInsets.left - _segmentInsets.right, CGRectGetHeight(_segmentRect) - _segmentInsets.top - _segmentInsets.bottom)];
        [_segmentControl layoutSubviews];
    }
    [_scrollView setFrame:CGRectMake(0, _yPos, width, height)];
    
    for (NSNumber *idx in [_vcDic allKeys])
    {
        id obj = _vcDic[idx];
        if ([obj isKindOfClass:[UIViewController class]])
        {
            UIViewController *vc = (UIViewController *)obj;
            CGRect tempFrame = vc.view.frame;
            tempFrame.size.height = CGRectGetHeight(_containerFrame);
            tempFrame.size.width = CGRectGetWidth(_containerFrame);
            [vc.view setFrame:tempFrame];
        }
    }
}

/**
 *  获取当前选中的ViewController页面
 *
 *  @return 返回ViewController对象
 */
- (UIViewController *)currentSelectedViewController
{
    if (self.segmentType == SegmentControlTypeSystem)
        return [self loadViewControllerWithIndex:_segment.selectedSegmentIndex];
    else
        return [self loadViewControllerWithIndex:_segmentControl.selectedIndex];
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

/**
 *  头部灰线
 */
- (void)createGrayLine
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:line];
    line.backgroundColor = BACKGROUD_COLOR;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentControl.mas_bottom).offset(-1.0);
        make.height.mas_equalTo(1.0);
        make.left.right.equalTo(self.view);
    }];
}

#pragma mark - setter
- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    _scrollView.scrollEnabled = _scrollEnabled;
}

#pragma mark ------- Event Action
- (void)segClick:(UISegmentedControl *)seg
{
    [self changeScrollToTopStatus:seg.selectedSegmentIndex];
    [self.scrollView setContentOffset:CGPointMake(seg.selectedSegmentIndex * CGRectGetWidth(self.scrollView.frame), 0) animated:NO];
}

#pragma mark - UIScrollViewDelegate's
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSInteger index     = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger nextIndex = index + 1;
    NSInteger prevIndex = index - 1;
    
    if (nextIndex < _segmentControl.listData.count)
        [self loadViewControllerWithIndex:nextIndex];
    
    if (prevIndex >= 0)
        [self loadViewControllerWithIndex:prevIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self setCurrentSelectedPage:index foreceRequest:NO];
}



@end
