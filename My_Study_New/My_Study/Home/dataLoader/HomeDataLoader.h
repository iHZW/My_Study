//
//  HomeDataLoader.h
//  My_Study
//
//  Created by hzw on 2022/9/23.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeDataLoader : CacheDataLoader


- (void)sendRequestTest:(ResponseLoaderBlock)block;


@end

NS_ASSUME_NONNULL_END
