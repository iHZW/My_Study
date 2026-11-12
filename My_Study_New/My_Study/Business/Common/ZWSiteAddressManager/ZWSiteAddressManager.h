//
//  ZWSiteAddressManager.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//
/* 网络地址管理类 */

#import "CMObject.h"
#import "SingletonTemplate.h"

#define ZWSiteManager       [ZWSiteAddressManager sharedZWSiteAddressManager]

FOUNDATION_EXPORT NSString *const PASAppSiteBaseHttpURLKey;


NS_ASSUME_NONNULL_BEGIN

@interface ZWSiteAddressManager : CMObject
DEFINE_SINGLETON_T_FOR_HEADER(ZWSiteAddressManager)

/**
 *  json请求根url
 *
 *  @return NSString 根url
 */
+ (NSString *)getBaseHttpURL;
/// 相对路径统一从当前环境解析；配置缺失时返回明确错误，不回退到 Mock。
+ (nullable NSURL *)URLForPath:(NSString *)path baseURL:(NSString *)baseURL error:(NSError * _Nullable * _Nullable)error;
+ (nullable NSURL *)URLForPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error;

/**
 *  版本号
 */
+ (NSString *)appVersion;

/**
 *  渠道
 */
+ (NSString *)appChannel;


@end

NS_ASSUME_NONNULL_END
