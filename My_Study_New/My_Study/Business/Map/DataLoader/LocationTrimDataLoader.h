//
//  LocationTrimDataLoader.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CacheDataLoader.h"
#import "MapHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationTrimDataLoader : CacheDataLoader

/** 经纬度  */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/** 当前城市  */
@property (nonatomic,copy) NSString *currentCity;//当前城市

/** 加载完毕 */
@property (nonatomic, assign) BOOL noMore;


- (void)sendRequestLocationData:(ResponseLoaderBlock)block;

- (void)sendRequestLocationDataPageCount:(NSInteger)page blcok:(ResponseLoaderBlock)block;

@end

NS_ASSUME_NONNULL_END
