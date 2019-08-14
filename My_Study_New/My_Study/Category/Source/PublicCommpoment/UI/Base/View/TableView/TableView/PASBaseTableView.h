//
//  PASBaseTableView.h
//  TestC
//
//  Created by vince on 16/2/15.
//  Copyright © 2016年 vince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface PASBaseTableView : UITableView<UIGestureRecognizerDelegate>

@property (nonatomic, copy) MJRefreshComponentRefreshingBlock freshBlock;
@property (nonatomic, copy) MJRefreshComponentRefreshingBlock moreBlock;

/**< 设置是否支持多手势 */
@property (nonatomic, assign) BOOL isSupportoOtherGestureRecognizer;


/**
 *  加载刷新视图
 *
 * freshBlock 下拉时调用
 */
- (void)loadFreshView:(MJRefreshComponentRefreshingBlock)freshBlock;

/**
 *  加载更多视图
 *
 *  moreBlock 上拉时回调
 */
- (void)loadMoreView:(MJRefreshComponentRefreshingBlock)moreBlock;

- (void)startHeaderRefreshing;

/**
 *  结束刷新动画
 */
- (void)endHeaderRefreshing;

/**
 *  结束加载更多动画
 *
 *  @param isHidden 是否隐藏加载更多
 */
- (void)endFooterRefreshingWithHidden:(BOOL)isHidden;
@end
