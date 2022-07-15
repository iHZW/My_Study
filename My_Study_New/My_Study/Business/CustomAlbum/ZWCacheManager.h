//
//  ZWCacheManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWCacheManager : PHCachingImageManager

+ (ZWCacheManager *)shared;

@end

NS_ASSUME_NONNULL_END
