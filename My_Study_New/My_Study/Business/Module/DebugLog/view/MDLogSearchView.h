//
//  MDLogSearchView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/19.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , SearchStatusType) {
    /**< 处于搜索状态 */
    SearchStatusTypeBecome,
    /**< 失去搜索焦点 */
    SearchStatusTypeResign
};
/* 搜索名称回调 */
typedef void (^SearchNameBlock) (NSString *searchName);
/* 搜索状态类型回调 */
typedef void (^SearchStatusBlock) (SearchStatusType type);

@interface MDLogSearchView : CMView

@property (nonatomic, copy) SearchNameBlock searchNameBlock;

@property (nonatomic, copy) SearchStatusBlock searchStatusBlock;

/**
 取消搜索
 */
- (void)cancelSearchStatus;

@end

NS_ASSUME_NONNULL_END
