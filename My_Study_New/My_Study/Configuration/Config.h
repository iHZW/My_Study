//
//  Config.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//
/** 工程信息配置  */
#import <Foundation/Foundation.h>
#import "EnvironmentType.h"

NS_ASSUME_NONNULL_BEGIN

@interface Config : NSObject
DEFINE_SINGLETON_T_FOR_HEADER(Config)

/** 只读信息  */
/** 域名  */
@property (nonatomic, copy, readonly) NSString *httpServerHost;
/** 微信id  */
@property (nonatomic, copy, readonly) NSString *wxAppID;
/** 阿里支付scheme  */
@property (nonatomic, copy, readonly) NSString *alipayScheme;
/** 环境  */
@property (nonatomic, assign, readonly) EnvironmentType environmentType;


//个推
@property (nonatomic, copy) NSString *gtAppId;
@property (nonatomic, copy) NSString *gtAppKey;
@property (nonatomic, copy) NSString *gtAppSecret;

//高德
@property (nonatomic, copy) NSString *aMapKey;

//IM
@property (nonatomic, assign) NSInteger imAppId;

//闪验
@property (nonatomic, copy) NSString *shanYanAppID;

//打点url
@property (nonatomic, copy) NSString *statisticsURL;
/** 腾讯bugly appid  */
@property (nonatomic, copy) NSString *buglyAppID;

/** scheme  */
@property (nonatomic, copy) NSString *zwScheme;
/** 域名  */
@property (nonatomic, copy) NSString *zwHost;
/** scoket URL  */
@property (nonatomic, copy) NSString *socketURL;

@end

NS_ASSUME_NONNULL_END
