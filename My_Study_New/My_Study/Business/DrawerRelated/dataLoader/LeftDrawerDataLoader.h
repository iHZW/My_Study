//
//  LeftDrawerDataLoader.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeftDrawerDataLoader : CacheDataLoader

/**
 * 资讯-要闻-头部轮播数据
 * @param block 回调
 */
- (void)sendRequestForInfoNewsHeadBanner:(ResponseLoaderBlock)block;



@end

NS_ASSUME_NONNULL_END
