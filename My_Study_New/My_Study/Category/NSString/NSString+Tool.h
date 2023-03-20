//
//  NSString+Tool.h
//  My_Study
//
//  Created by Zhiwei Han on 2023/3/15.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tool)

#pragma mark - modify

/// 拼接字符串
- (NSString*)eh_append:(NSString*)str;

/// 前边拼接字符串
- (NSString*)eh_front_append:(NSString*)str;

/// 拼接H5 跳转 url
/// - Parameter dic: 参数
- (NSString *)eh_webview_url:(NSDictionary<NSString*, NSString*>*)dic;

#pragma mark - Url

/// Convert to url
- (NSURL*)eh_url;

/// 路由跳转拼接域名
- (NSURL *)eh_base_url;

/// 获取imageurl  不带域名拼接域名,  代 http/https的直接返回对应的 NSURL
- (NSURL*)eh_image_url;

/// Convert to url
- (NSURL*)eh_url_look;

/// 获取eh_image_url_look  不带域名拼接域名,  代 http/https的直接返回对应的 NSURL
- (NSURL*)eh_image_url_look;

#pragma mark - File

- (NSString *)eh_documentPath;

- (NSString *)eh_libraryPath;

- (NSString *)eh_cachesPath;

- (NSString *)eh_tempPath;

- (NSString *)eh_homePath;

- (BOOL)eh_fileExist;

- (unsigned long long)eh_fileSize;

- (void)eh_createFile;

- (BOOL)eh_createDir;

#pragma mark - AppInfo

/// 获取App的版本号
+ (NSString*)eh_appVersion;

/// 获取主版本号
+ (NSString*)eh_mainVersion;

/// 获取build版本
+ (NSString*)eh_appBuildVersion;

/// 手机号码脱敏  "188********"    默认保留前3位
/// - Parameter number:
+ (NSString *)cipherNumber:(NSString *)number;

/// 手机号码脱敏  188****7870  默认保留前3位
/// - Parameters:
///   - number: 手机号码
///   - cipherLen: 加密长度
+ (NSString *)cipherNumber:(NSString *)number cipherLen:(NSUInteger)cipherLen;

/// 从字符串中过滤出数字
- (NSString *)eh_filterOutNumbers;

/// 扩展名
- (NSString *)eh_urlExtension;

/// 判断扩展名数组 是否包含当前扩展名
/// - Parameter extensions: 扩展名数组
- (BOOL)eh_isURLMatchExtensions:(NSArray *)extensions;

/// 给 URL 拼接参数
/// - Parameter dic: 参数
- (NSString*)eh_append_url_parameter:(NSDictionary<NSString*, NSString*>*)dic;

/// 读取缓存数据
- (id)eh_getCacheData;

/// 向当前路径写入数据
/// - Parameters:
///   - data: 需要写入的数据
///   - version: 新数据对应的版本号
///   - userDefaultKey: 查找版本号，依赖的key
- (BOOL)eh_saveCacheData:(id)data version:(NSString*)version userDefaultKey:(NSString*)userDefaultKey;

@end

NS_ASSUME_NONNULL_END
