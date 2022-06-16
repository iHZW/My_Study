//
//  ZWBaseTableView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWBaseTableView : UITableView<UIGestureRecognizerDelegate>

@property (nonatomic, copy) MJRefreshComponentRefreshingBlock _Nullable freshBlock;

@property (nonatomic, copy) MJRefreshComponentRefreshingBlock _Nullable moreBlock;
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

/* 开始刷新动画 */
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

NS_ASSUME_NONNULL_END
