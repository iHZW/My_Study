//
//  LocationManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "MapHeader.h"
#import "JXLocation.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^JXLocationManagerBlock) (JXLocation *_Nullable location, NSError *_Nullable error);

@interface LocationManager : CMObject

@property (nonatomic, copy) JXLocationManagerBlock block;

+ (instancetype)shareLocationManager;

- (void)configAMapService:(NSString *)apiKey;

/**
 *  请求定位信息
 *
 *  @param reGeocode    是否带有逆地理信息(获取逆地理信息需要联网)
 *  @param  funcBlock    回调
 *
 */
- (void)requestLocationWithReGeocode:(BOOL)reGeocode completionBlock:(JXLocationManagerBlock)funcBlock;

@end

NS_ASSUME_NONNULL_END
