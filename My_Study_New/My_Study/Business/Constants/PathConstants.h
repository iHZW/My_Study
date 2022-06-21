//
//  PathConstants.h
//  StarterApp
//  指定 APP 的目录， 不带创建功能
//  Created by js on 2019/7/15.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PathConstants : NSObject
/**
 * APP 根路径 「documents/app」
 */
+ (NSString *)appDirectory;
/**
 * 数据目录 （业务数据不可删除） 「documents/app/data」
 */
+ (NSString *)appDataDirectory;
/**
 * 原生存储相片的目录 「documents/app/data/image」
 */
+ (NSString *)appImageDirectory;
/**
 * 录音文件存储的目录 「documents/app/data/voice」
 */
+ (NSString *)appVoiceDirectory;
/**
 * web 下载文件的目录 「documents/app/webfile」
 */
+ (NSString *)webFileDirectory;
/**
 * hybrid 目录 「documents/app/hybridserver」
 */
+ (NSString *)gcdWebServerRootDirectory;
/**
 * 本地临时目录，访问本地文件 「temp/hybrid」
 */
+ (NSString *)fileWebServerRootDirectory;
/**
* ShareClient 下载图片的缓存目录 「temp/share/image」
*/
+ (NSString *)shareImageRootDirectory;
#pragma mark - Caches 目录可以删除

/**
 * 缓存目录 (可以删除) [Library/Caches/app]
 */
+ (NSString *)appCacheDirectory;

/**
 * Library/Caches
 */
+ (NSString *)userCacheDirectory;

/**
 * SDWebImage 缓存图片的目录; 不做修改使用 SD 默认的缓存目录 「Library/Caches/com.hackemist.SDImageCache/default」
 */
+ (NSString *)sdWebImageCacheDirectory;

@end

NS_ASSUME_NONNULL_END
