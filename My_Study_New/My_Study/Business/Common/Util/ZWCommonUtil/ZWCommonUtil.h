//
//  ZWCommonUtil.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWCommonUtil : NSObject

#pragma mark - 存本地网络缓存数据
+ (void)checkAndWriteLocalCMSDataToCache;

/**
 *  读取本地文件数据进网络缓存
 *
 *  @param localFileName 本地文件名
 *  @param cacheFileName 缓存文件名
 */
+ (void)saveCmsDataToCache:(nullable NSString *)localFileName
                 cacheName:(nullable NSString *)cacheFileName;

/**
 *  清除所有的存储本地的数据
 */
+ (void)clearAllUserDefaultsData;




@end

NS_ASSUME_NONNULL_END
