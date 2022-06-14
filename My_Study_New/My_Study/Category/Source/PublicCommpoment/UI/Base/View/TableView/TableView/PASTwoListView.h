//
//  PASTwoListView.h
//  TestC
//
//  Created by vince on 16/2/15.
//  Copyright © 2016年 vince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

/**
 *  点击顶部按钮回调
 *
 *  @param NSInteger 索引，从0开始，从左至右
 *  @param BOOL      升降，YES降序
 */
typedef void(^ListClickTitleBlock)(NSInteger,BOOL);

@protocol TwoListDelegate;

@class PASBaseTableView;

@interface PASTwoListView : UIView
{
    UITableView *_leftTableView;
    UITableView *_rightTableView;
    
    UIScrollView *_rightScrollView;
    UIScrollView *_rightTitleScrollView;
    
    UILabel *_leftTopLabel;
    
    NSInteger _selectedIndex;
    BOOL _isDown;
}

@property (nonatomic, weak) id<TwoListDelegate> listDelegate;
//刷新回调
@property (nonatomic, strong) MJRefreshComponentRefreshingBlock freshBlock;
@property (nonatomic, strong) MJRefreshComponentRefreshingBlock moreBlock;

@property (nonatomic, strong) ListClickTitleBlock clickTitleBlock;

/**
 *  初始化两表大小及顶部标题
 *
 *  @param leftTopTitle        左上角标题
 *  @param rightTopTitles      右边标题，元素类型字典，默认1可点如：@{@"tilte":@"量比",@“enable”:@"0"}
 *  @param rightTopTitleWidths 右边标题宽度，不设则用toptitlewidth，类型NSNumber
 *  @param topTitleWidth       默认右边标题宽度
 *  @param topTitleImageDict   上下箭头 @{@"up":@"imageName",@"down":@"imageName"}
 */
- (void)setLeftTopTitle:(NSString *)leftTopTitle
         rightTopTitles:(NSArray *)rightTopTitles
    rightTopTitleWidths:(NSArray *)rightTopTitleWidths
          topTitleWidth:(NSInteger)topTitleWidth
          topTitleImage:(NSDictionary *)topTitleImageDict;

/**
 *  添加数据
 *
 *  @param leftArr  左表数据，元素类型字典,例@[@{@"title":@"航运",@"code",@"600020"}]
 *  @param rightArr 右表数据，元素类型PASListRightItem数组，如@[@[PASListRightItem,PASListRightItem]]
 */
- (void)appendLeftTableData:(NSArray *)leftArr rightTableData:(NSArray *)rightArr;

/**
 *  刷新时清除数据
 */
- (void)clearAllData;

//刷新动画
- (void)endFooterRefreshingWithHidden:(BOOL)isHidden;
- (void)endHeaderRefreshing;
- (void)endRefreshingWithNoMoreData:(NSString *)desc;

/**
 *  加载更多视图
 *
 *  moreBlock 上拉时回调
 */
- (void)loadMoreView:(MJRefreshComponentRefreshingBlock)moreBlock;

/**
 *  结束加载更多动画
 *
 *  @param isHidden 是否隐藏加载更多
 */
- (void)loadFreshView:(MJRefreshComponentRefreshingBlock)freshBlock;

/**
 *  选中某个title
 *
 *  @param index title索引
 */
- (void)chooseTopTitleToSelected:(NSInteger)index;
@end


@protocol TwoListDelegate <NSObject>

@optional
- (NSInteger)twolist:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section isLeftTable:(BOOL)isLeft;
- (UITableViewCell *)twolist:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isLeftTable:(BOOL)isLeft;
- (CGFloat)twolist:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)twolist:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath isLeftTable:(BOOL)isLeft;
- (void)twolist:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end