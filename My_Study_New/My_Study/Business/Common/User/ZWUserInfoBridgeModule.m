//
//  ZWUserInfoBridgeModule.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWUserInfoBridgeModule.h"
#import "ZWUserAccountManager.h"
#import "ZWSiteAddressManager.h"

@implementation ZWUserInfoBridgeModule

/**
 *  获取登录成功后tokenId
 *
 *  @return tokenId
 */
+ (NSString *)tokenId
{
    NSString *tmpStr = ZWCurrentUserInfo.add_loginToken;
    NSString *tokenId = [tmpStr length] > 0 ? tmpStr : @"";
    return tokenId;
}

/**
 *  获取登录后成功后clientId
 *
 *  @return clientId
 */
+ (NSString *)clientId
{
    NSString *tmpStr = ZWCurrentUserInfo.clientID;
    NSString *clientId = [tmpStr length] > 0 ? tmpStr : @"";
    return clientId;
}

/**
 *  获取登录成功后sessionId(对应app端中markID)
 *
 *  @return sessionId
 */
+ (NSString *)sessionId
{
    NSString *tmpStr = @"sessionId";
    NSString *markId = [tmpStr length] > 0 ? tmpStr : @"";
    return markId;
}


/**
 *  获取应用名称
 *
 *  @return appName
 */
+ (NSString *)appName
{
    return @"ZWAPP";
}

/**
 *  获取登录后用户姓名
 *
 *  @return userName
 */
+ (NSString *)userName
{
    NSString *tmpStr = ZWCurrentUserInfo.userName;
    return [tmpStr length] > 0 ? tmpStr : @"";;
}

/**
 *  获取用户绑定手机号
 *
 *  @return mobile
 */
+ (NSString *)mobile
{
//    NSString *tmpStr = [PASConfigration readConfigWithKey:kHsCustomTelphoneKey];
//    if ([tmpStr length] > 9) {
//        tmpStr = [tmpStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
//    }
    NSString *tmpStr = @"";
    return [tmpStr length] > 0 ? tmpStr : @"";
}

/**
 *  获取终端系统版本号信息
 *
 *  @return 系统版本号
 */
+ (NSString *)osVersion
{
    NSString *name      = [[UIDevice currentDevice] systemName];
    NSString *version   = [[UIDevice currentDevice] systemVersion];
    return [NSString stringWithFormat:@"%@ %@", name, version];
}

/**
 *  获取终端安e理财版本号信息
 *
 *  @return 对应理财版本号信息
 */
+ (NSString *)aneVersion
{
    NSString *tmpStr = [ZWSiteAddressManager appVersion];
    return [tmpStr length] > 0 ? tmpStr : @"";
}

/**
 *  获取请求的服务端版本号
 *
 *  @return 服务端版本号
 */
+ (NSString *)serverVersion
{
    return @"2.0";
}

/**
 *  这个是渠道，目前有6种，分为OpenWebApp，PCH5，native，mobileH5，wechat，other六种，分别对应网站访问，网站H5，手机native，手机H5，微信，其他。
 *
 *  @return 渠道
 */
+ (NSString *)channel
{
    return @"native";
}

/**
 *  获取talkingdata 中 deviceID信息
 *
 *  @return deviceID信息
 */
+ (NSString *)deviceID
{
    NSString *retVal = @"deviceID";
    return retVal;
}

@end
