//
//  NSFileManager+Ext.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Ext)

/**
 * 没有文件 创建文件，存在什么都不做
 */
- (BOOL)createFileIfNotExist:(NSURL *)filePath contents:(nullable NSData *)data;

/**
 * 生成随机文件名, 上传文件时候的文件名
 */
- (NSString *)generateRandomFileName;

/**
 * 根据时间戳，生成随机图片名 （选择相册图标，存入本地的文件名）
 */
- (NSString *)generateRandomImageName;

/**
* 根据时间戳，生成随机视频名
*/
- (NSString *)generateRandomVideoName;

/**
 * 删除文件夹下的所有文件
 */
- (BOOL)deleteAllFilesInDirectory:(NSString *)directory error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
