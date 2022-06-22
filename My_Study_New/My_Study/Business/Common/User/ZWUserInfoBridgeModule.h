//
//  ZWUserInfoBridgeModule.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWUserInfoBridgeModule : NSObject

/**
 *  获取登录成功后tokenId
 *
 *  @return tokenId
 */
+ (NSString *)tokenId;

/**
 *  获取登录后成功后clientId
 *
 *  @return clientId
 */
+ (NSString *)clientId;

/**
 *  获取登录成功后sessionId(对应app端中markID)
 *
 *  @return sessionId
 */
+ (NSString *)sessionId;

/**
 *  获取应用名称
 *
 *  @return appName
 */
+ (NSString *)appName;

/**
 *  获取登录后用户姓名
 *
 *  @return userName
 */
+ (NSString *)userName;

/**
 *  获取用户绑定手机号
 *
 *  @return mobile
 */
+ (NSString *)mobile;

/**
 *  获取终端系统版本号信息
 *
 *  @return 系统版本号
 */
+ (NSString *)osVersion;

/**
 *  获取终端安e理财版本号信息
 *
 *  @return 对应理财版本号信息
 */
+ (NSString *)aneVersion;

/**
 *  获取talkingdata 中 deviceID信息
 *
 *  @return deviceID信息
 */
+ (NSString *)deviceID;


@end

NS_ASSUME_NONNULL_END
