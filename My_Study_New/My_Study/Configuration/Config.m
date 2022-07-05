//
//  Config.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Config.h"
#import "Environment.h"

@interface Config ()
/** 域名  */
@property (nonatomic, copy, readwrite) NSString *httpServerHost;
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
    NSDictionary *appConfiguration = nil;
    /** 环境设置  */
    #if kUseDynamicConfig && QA == 1
        EnvConfigObject *obj = [Environment.sharedEnvironment loadEvnConfigObject];
        appConfiguration = obj.AppConfiguration;
        self.environmentType = obj.envType;
    #else
        NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
        appConfiguration = infoDic[@"AppConfiguration"];
        self.environmentType = EnvironmentTypeOnline;
    #endif
    
    if ([appConfiguration isKindOfClass:[NSDictionary class]]){
        self.httpServerHost = appConfiguration[@"HTTP_SERVER_HOST"];
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

@end
