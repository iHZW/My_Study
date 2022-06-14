//
//  PASBaseTableView.m
//  TestC
//
//  Created by vince on 16/2/15.
//  Copyright © 2016年 vince. All rights reserved.
//

#import "PASBaseTableView.h"

@implementation PASBaseTableView

- (void)setIsSupportoOtherGestureRecognizer:(BOOL)isSupportoOtherGestureRecognizer
{
    _isSupportoOtherGestureRecognizer = isSupportoOtherGestureRecognizer;
    [self gestureRecognizer:nil shouldRecognizeSimultaneouslyWithGestureRecognizer:nil];
}

- (void)loadFreshData
{
    if (self.freshBlock) {
        self.freshBlock();
    }
    if (self.mj_footer) {
        self.mj_footer.hidden = NO;
    }
}

- (void)loadMoreData
{
    if (self.moreBlock) {
        self.moreBlock();
    }
}

- (void)startHeaderRefreshing
{
    [self.mj_header beginRefreshing];
}

- (void)endHeaderRefreshing
{
    [self.mj_header endRefreshing];
}

- (void)endFooterRefreshingWithHidden:(BOOL)isHidden
{
    [self.mj_footer endRefreshing];
    self.mj_footer.hidden = isHidden;
}

- (void)loadMoreView:(MJRefreshComponentRefreshingBlock)moreBlock
{
    self.moreBlock = moreBlock;
    __weak typeof(&*self) wself = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [wself loadMoreData];
    }];
    self.mj_footer = footer;
}

- (void)loadFreshView:(MJRefreshComponentRefreshingBlock)freshBlock
{
    self.freshBlock = freshBlock;
    __weak typeof(&*self) wself = self;
    MJRefreshNormalHeader *tempHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself loadFreshData];
    }];
    self.mj_header = tempHeader;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.isSupportoOtherGestureRecognizer = NO;
    }
    return self;
}


- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
    self.moreBlock = nil;
    self.freshBlock = nil;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return self.isSupportoOtherGestureRecognizer;
}

@end
