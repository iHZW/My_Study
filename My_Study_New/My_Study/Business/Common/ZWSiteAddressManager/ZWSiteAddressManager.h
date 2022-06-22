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

extern NSString * _Nullable PASAppSiteBaseHttpURLKey;


NS_ASSUME_NONNULL_BEGIN

@interface ZWSiteAddressManager : CMObject
DEFINE_SINGLETON_T_FOR_HEADER(ZWSiteAddressManager)

/**
 *  json请求根url
 *
 *  @return NSString 根url
 */
+ (NSString *)getBaseHttpURL;

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
