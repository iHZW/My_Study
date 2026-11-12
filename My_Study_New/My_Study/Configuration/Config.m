//
//  Config.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Config.h"
#import "Environment.h"
#import "ZWEndpointConfiguration.h"

@interface Config ()
/** 域名  */

/** 微信id  */
@property (nonatomic, copy, readwrite) NSString *wxAppID;
/** 阿里支付scheme  */
@property (nonatomic, copy, readwrite) NSString *alipayScheme;
/** 环境  */
@property (nonatomic, assign, readwrite) EnvironmentType environmentType;

@end

@implementation Config
DEFINE_SINGLETON_T_FOR_CLASS(Config)

- (instancetype)init
{
    if (self = [super init]) {
        [self loadDefauleConfig];
    }
    return self;
}

/** 加载默认配置信息  */
- (void)loadDefauleConfig
{
    EnvConfigObject *profile = [Environment.sharedEnvironment loadEvnConfigObject];
    NSMutableDictionary *appConfiguration = [NSMutableDictionary dictionaryWithDictionary:profile.AppConfiguration ?: @{}];
    [appConfiguration addEntriesFromDictionary:NSBundle.mainBundle.infoDictionary[@"AppConfiguration"] ?: @{}];
    self.environmentType = Environment.sharedEnvironment.currentEnvironmentType;

    if ([appConfiguration isKindOfClass:[NSDictionary class]]){
        self.wxAppID = appConfiguration[@"WX_APPID"];
        self.aMapKey = appConfiguration[@"AMAP_KEY"];
        self.alipayScheme = appConfiguration[@"ALIPAY_SCHEME"];
        
        self.gtAppId = appConfiguration[@"GT_APPID"];
        self.gtAppKey = appConfiguration[@"GT_APPKEY"];
        self.gtAppSecret = appConfiguration[@"GT_APPSECRET"];
        
        self.imAppId = [appConfiguration[@"IM_APPID"] integerValue];
        
        self.shanYanAppID = appConfiguration[@"SHANYAN_APPID"];
        self.statisticsURL = appConfiguration[@"ZW_STATISTICS_URL"];
        self.buglyAppID = appConfiguration[@"BUGLY_APPID"];
        
        
        self.zwScheme = appConfiguration[@"ZW_SCHEME"];
        self.zwHost = appConfiguration[@"ZW_HOST"];
        
        self.socketURL = appConfiguration[@"SOCKET_URL"];
    }
}

- (NSString *)httpServerHost {
    NSString *name = [ZWEndpointConfiguration nameForEnvironment:self.environmentType];
    id value = NSBundle.mainBundle.infoDictionary[@"NetworkConfiguration"][@"BaseURLs"][name];
    return [value isKindOfClass:NSString.class] ? value : @"";
}

@end
