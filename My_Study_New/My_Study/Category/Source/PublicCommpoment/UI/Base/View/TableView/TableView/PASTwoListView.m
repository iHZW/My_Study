//
//  PASTwoListView.m
//  TestC
//
//  Created by vince on 16/2/15.
//  Copyright © 2016年 vince. All rights reserved.
//

#import "PASTwoListView.h"
#import "PASBaseTableView.h"
#import "PASLineCell.h"
#import "PASListRightCell.h"
#import "CustomListFreshHeader.h"

const NSInteger leftWidth = 100;
const NSInteger topTitleHeight = 40;
const NSInteger rowHeight = 50;

#define KTopTitleTag 3000

@interface PASTwoListView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *leftTableView;/**< 最左侧标题，跟着右表滚动 */
@property (nonatomic, strong) UITableView *rightTableView;/**< 负责内容上下滚动 */

@property (nonatomic, strong) UIScrollView *rightScrollView;/**< 负责右边内容左右滚动 */
@property (nonatomic, strong) UIScrollView *rightTitleScrollView;/**< 负责右边内容左右滚动 */

@property (nonatomic, strong) UILabel *leftTopLabel;/**< 左上角标题 */

@property (nonatomic, copy) NSArray *topTitleArray;

/**
 *  和title一一对应,类型NSNumber，如果设置，则topTitleWidth不起作用
 */
@property (nonatomic, copy) NSArray *topTitleWidthArray;
@property (nonatomic, assign) NSInteger topTitleWidth;
@property (nonatomic, strong) UIColor *contentBgColor;
@property (nonatomic, copy) NSString *leftTopTitleStr;
@property (nonatomic, strong) NSDictionary *topTitleImageDict;

//table data
@property (nonatomic, strong) NSMutableArray *leftTableDataArray;
@property (nonatomic, strong) NSMutableArray *rightTableDataArray;

//private
@property (nonatomic, strong) UIColor *topTitleNormalColor;
@property (nonatomic, strong) UIColor *topTitleEnableColor;
@property (nonatomic, strong) UIFont *topTitleFont;
@property (nonatomic, strong) UIFont *rightContentTextFont;

@end

@implementation PASTwoListView

static NSString *leftCellIdentify = @"leftCellIdentify";
static NSString *rightCellIdentify = @"rightCellIdentify";



#pragma mark- action
- (void)action_clickTitle:(UIButton *)btn
{
    [self chooseTopTitleToSelected:btn.tag-KTopTitleTag];
    
    if (self.clickTitleBlock) {
        self.clickTitleBlock(btn.tag-KTopTitleTag,_isDown);
    }
}

#pragma mark- data

- (void)clearAllData
{
    self.leftTableDataArray = [NSMutableArray arrayWithCapacity:20];
    self.rightTableDataArray = [NSMutableArray arrayWithCapacity:20];
}

- (void)appendLeftTableData:(NSArray *)leftArr rightTableData:(NSArray *)rightArr
{
    if ([leftArr count]<=0 ||[rightArr count]<=0) {
        return;
    }
    if (!self.leftTableDataArray) {
        self.leftTableDataArray = [NSMutableArray arrayWithCapacity:20];
        self.rightTableDataArray = [NSMutableArray arrayWithCapacity:20];
    }
    [self.leftTableDataArray addObjectsFromArray:leftArr];
    [self.rightTableDataArray addObjectsFromArray:rightArr];
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}
- (void)setLeftTopTitle:(NSString *)leftTopTitle
         rightTopTitles:(NSArray *)rightTopTitles
    rightTopTitleWidths:(NSArray *)rightTopTitleWidths
          topTitleWidth:(NSInteger)topTitleWidth
          topTitleImage:(NSDictionary *)topTitleImageDict
{
    _selectedIndex = -1;
    self.contentBgColor = [UIColor blackColor];
    self.topTitleWidth = 80;
    self.topTitleNormalColor = [UIColor blueColor];
    self.topTitleEnableColor = [UIColor grayColor];
    self.topTitleFont = [UIFont systemFontOfSize:14];
    self.rightContentTextFont = [UIFont systemFontOfSize:16];
    
    self.leftTopTitleStr = leftTopTitle;
    self.topTitleArray = rightTopTitles;
    self.topTitleWidthArray = rightTopTitleWidths;
    self.topTitleImageDict = topTitleImageDict;
    if (topTitleWidth>0) {
        self.topTitleWidth = topTitleWidth;
    }
    [self loadAllView];
}


#pragma mark- 刷新动画回调
- (void)loadMoreData
{
    [self.leftTableView.mj_footer beginRefreshing];
    if ([NSThread isMainThread]) {
        if (self.moreBlock) {
            self.moreBlock();
        }
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.moreBlock) {
                self.moreBlock();
            }
        });
    }
}

- (void)loadFreshData
{
    
    if ([NSThread isMainThread]) {
        if (self.freshBlock) {
            self.freshBlock();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.freshBlock) {
                self.freshBlock();
            }
        });
    }
}

#pragma mark- UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.listDelegate respondsToSelector:@selector(twolist:numberOfRowsInSection:isLeftTable:)]) {
        
        return [self.listDelegate twolist:tableView numberOfRowsInSection:section isLeftTable:(tableView == _leftTableView)];
    }
    
    if (tableView == _leftTableView) {
        return self.leftTableDataArray.count;
    }
    return self.rightTableDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.listDelegate respondsToSelector:@selector(twolist:cellForRowAtIndexPath:isLeftTable:)]) {
        
        return [self.listDelegate twolist:tableView cellForRowAtIndexPath:indexPath isLeftTable:(tableView == _leftTableView)];
    }
    
    UITableViewCell *cell = nil;
    if (tableView == _leftTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:leftCellIdentify forIndexPath:indexPath];
        PASLeftCell *leftCell = (PASLeftCell *)cell;
        [leftCell setLeftWidth:leftWidth];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:rightCellIdentify forIndexPath:indexPath];
        PASListRightCell *rightCell = (PASListRightCell *)cell;
        rightCell.itemWidth = self.topTitleWidth;
        rightCell.itemHight = rowHeight;
        rightCell.leftWidth = leftWidth;
        rightCell.itemWidthArray = self.topTitleWidthArray;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark- UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.listDelegate respondsToSelector:@selector(twolist:willDisplayCell:forRowAtIndexPath:isLeftTable:)]) {
        
        [self.listDelegate twolist:tableView willDisplayCell:cell forRowAtIndexPath:indexPath isLeftTable:(tableView == self.leftTableView)];
        return;
    }
    
    if (tableView == self.leftTableView) {
        [(PASLeftCell *)cell loadContentWithData:self.leftTableDataArray[indexPath.row]];
    } else {
        [(PASListRightCell *)cell loadViewWithData:self.rightTableDataArray[indexPath.row]];
    }
        
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.listDelegate respondsToSelector:@selector(twolist:heightForRowAtIndexPath:)]) {
        
        return [self.listDelegate twolist:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return rowHeight;
}

#pragma mark- UIScrollViewDelegate methods
//联动处理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _rightTableView) {
        
        _leftTableView.contentOffset = scrollView.contentOffset;
        
    }

}
#pragma mark- view

- (void)endHeaderRefreshing
{
    [self.leftTableView.mj_header endRefreshing];
    [self.rightTableView.mj_header endRefreshing];
}

- (void)endFooterRefreshingWithHidden:(BOOL)isHidden
{
    [self.leftTableView.mj_footer endRefreshing];
    self.leftTableView.mj_footer.hidden = isHidden;
    
    [self.rightTableView.mj_footer endRefreshing];
    self.rightTableView.mj_footer.hidden = isHidden;
}

- (void)endRefreshingWithNoMoreData:(NSString *)desc
{
    if ([desc length]) {
        [((MJRefreshAutoNormalFooter *)(self.leftTableView.mj_footer)) setTitle:desc forState:MJRefreshStateNoMoreData];
    }
    
    [self.leftTableView.mj_footer endRefreshingWithNoMoreData];
    self.leftTableView.mj_footer.hidden = NO;
    [self.rightTableView.mj_footer endRefreshingWithNoMoreData];
    self.rightTableView.mj_footer.hidden = YES;
}

- (void)loadMoreView:(MJRefreshComponentRefreshingBlock)moreBlock
{
    self.moreBlock = moreBlock;
    __weak typeof(&*self) wself = self;
    MJRefreshBackFooter *footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [wself loadMoreData];
    }];
    
    MJRefreshAutoNormalFooter *leftFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:nil];
    leftFooter.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    self.rightTableView.mj_footer = footer;
    self.leftTableView.mj_footer = leftFooter;
    
}

//leftHeader 只用来展示
- (void)loadFreshView:(MJRefreshComponentRefreshingBlock)freshBlock
{
    self.freshBlock = freshBlock;
    __weak typeof(&*self) wself = self;
    MJRefreshHeader *tempHeader = [MJRefreshHeader headerWithRefreshingBlock:^{
        [wself loadFreshData];
    }];

    
    CustomListFreshHeader *leftHeader = [CustomListFreshHeader headerWithRefreshingBlock:nil];
    leftHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    leftHeader.dependScrollview = self.rightTableView;
    
    self.rightTableView.mj_header = tempHeader;
    self.leftTableView.mj_header = leftHeader;
}

/**
 *  获取右侧视图内容宽度
 *
 *  @return <#return value description#>
 */
- (CGFloat)getRightTotalWidth
{
    CGFloat result = 0;
    if ([self.topTitleWidthArray count]) {
        for (NSNumber *num in self.topTitleWidthArray) {
            result += [num floatValue];
        }
    }
    else
    {
        result = [self.topTitleArray count]*self.topTitleWidth+leftWidth;
    }
    return result+10;
}

/**
 *  加载所有view
 */
- (void)loadAllView
{
    
    [self addSubview:self.rightScrollView];
//    [self addSubview:self.rightTitleScrollView];
    [self addSubview:self.leftTableView];
    [self addSubview:self.leftTopLabel];
    

    [self.rightScrollView addSubview:self.rightTableView];
    [self.rightScrollView addSubview:self.rightTitleScrollView];
    
    [self.leftTableView registerClass:[PASLeftCell class] forCellReuseIdentifier:leftCellIdentify];
    [self.rightTableView registerClass:[PASListRightCell class] forCellReuseIdentifier:rightCellIdentify];
}


- (void)chooseTopTitleToSelected:(NSInteger)index
{
    for (int i = 0 ; i < self.topTitleArray.count; i++) {
        UIButton *btn = [self.rightTitleScrollView viewWithTag:KTopTitleTag + i];
        if (index == i) {
            if (_selectedIndex == index) {
                _isDown = !_isDown;
            } else
            {
                _isDown = YES;
            }
            [btn setImage:[UIImage imageNamed:self.topTitleImageDict[(_isDown?@"down":@"up")]] forState:UIControlStateNormal];
        } else {
            [btn setImage:nil forState:UIControlStateNormal];
        }
    }
    
    _selectedIndex = index;
}

/**
 *  加载右表顶部tilte
 */
- (void)loadTopTitleView
{
    for (int i = 0; i < self.topTitleArray.count; i++) {
        
        float itemWidth = self.topTitleWidth;
        
        if (i < [self.topTitleWidthArray count]) {
            itemWidth = [self.topTitleWidthArray[i] floatValue];
        }
        
        NSDictionary *dict = [self.topTitleArray objectAtIndex:i];
        
        BOOL isCanClick = YES;
        if ([[dict objectForKey:@"enable"] isEqualToString:@"0"]) {
            isCanClick = NO;
        }
        
        CGRect tempFrame = CGRectMake(leftWidth +i*itemWidth, 0, itemWidth, topTitleHeight);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tempFrame;
        btn.titleLabel.font = self.topTitleFont;
        [btn setTitle:dict[@"title"] forState:UIControlStateNormal];
        [btn setTitleColor:isCanClick?self.topTitleNormalColor:self.topTitleEnableColor forState:UIControlStateNormal];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        btn.userInteractionEnabled = isCanClick;
        btn.tag = KTopTitleTag + i;
        [btn addTarget:self action:@selector(action_clickTitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightTitleScrollView addSubview:btn];
    }
}

- (UITableView *)leftTableView
{
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topTitleHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-topTitleHeight) style:UITableViewStylePlain];
        _leftTableView.backgroundColor = [UIColor clearColor];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.userInteractionEnabled = NO;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _leftTableView;
}


- (UITableView *)rightTableView
{
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topTitleHeight, [self getRightTotalWidth], CGRectGetHeight(self.frame)-topTitleHeight) style:UITableViewStylePlain];
        _rightTableView.backgroundColor = self.contentBgColor;
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightScrollView.bounces = NO;
        _rightTableView.directionalLockEnabled = YES;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _rightTableView;
}


- (UIScrollView *)rightScrollView
{
    if (!_rightScrollView) {
        _rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _rightScrollView.scrollsToTop = NO;
        _rightScrollView.backgroundColor = [UIColor clearColor];
        _rightScrollView.directionalLockEnabled = YES;
        _rightScrollView.alwaysBounceVertical = NO;
        _rightScrollView.alwaysBounceHorizontal = YES;
        _rightScrollView.bouncesZoom = NO;
        _rightScrollView.delegate = self;
        _rightScrollView.contentSize = CGSizeMake([self getRightTotalWidth], CGRectGetHeight(_rightScrollView.bounds));
    }
    return _rightScrollView;
}

- (UIScrollView *)rightTitleScrollView
{
    if (!_rightTitleScrollView) {
        _rightTitleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,[self getRightTotalWidth], topTitleHeight)];
        _rightTitleScrollView.delegate = self;
        _rightTitleScrollView.bounces = NO;
        _rightTitleScrollView.scrollsToTop = NO;
        _rightTitleScrollView.backgroundColor = [UIColor clearColor];
        _rightTitleScrollView.showsHorizontalScrollIndicator = NO;
        _rightTitleScrollView.directionalLockEnabled = YES;
        [self loadTopTitleView];
    }
    return _rightTitleScrollView;
}

- (UILabel *)leftTopLabel
{
    if (!_leftTopLabel) {
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, topTitleHeight)];
        tempView.backgroundColor = self.contentBgColor;
        [self addSubview:tempView];
        
        _leftTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, leftWidth-10, topTitleHeight)];;
        _leftTopLabel.backgroundColor = [UIColor clearColor];
        _leftTopLabel.font = [UIFont systemFontOfSize:16];
        _leftTopLabel.contentMode = UIViewContentModeCenter;
        _leftTopLabel.textColor = [UIColor whiteColor];
        _leftTopLabel.text = self.leftTopTitleStr;
    }
    return _leftTopLabel;
}
- (void)dealloc
{
    self.moreBlock = nil;
    self.freshBlock = nil;
    self.leftTableView.delegate = nil;
    self.leftTableView.dataSource = nil;
    self.rightTableView.delegate = nil;
    self.rightTableView.dataSource = nil;
    self.listDelegate = nil;
}

@end
