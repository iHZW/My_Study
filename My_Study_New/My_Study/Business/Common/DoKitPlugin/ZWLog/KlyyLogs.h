//
//  KlyyLogConst.h
//  NbcbBank
//
//  Created by nbcb on 2024/3/20.
//  Copyright © 2024 musheng zhangyan. All rights reserved.
//

#ifndef KlyyLogs_h
#define KlyyLogs_h

typedef NS_OPTIONS(NSInteger, KlyyLogType) {
    KlyyLogTypeLaunch = 0,   // 启动日志
    KlyyLogTypeH5,           // 全日志
    KlyyLogTypeNetworkError, // 网络错误
    KlyyLogTypeGetTuiPush,   // 个推
    KlyyLogTypeDistUpgrade,  // 资源升级
    KlyyLogTypePhoto,        // 图片文件
    KlyyLogTypeLocation,     // 定位
    KlyyLogTypeThirdRequest, // 第三方请求
};

static NSString *KlyyLaunchKEY = @"Launch";
static NSString *KlyyLaunchLogsPath = @"KlyyLaunchLogs";
#define KlyyNetworkErrorLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeLaunch, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyNetworkErrorKEY = @"NetworkError";
static NSString *KlyyNetworkErrorLogsPath = @"KlyyNetworkErrorLogs";
#define KlyyNetworkErrorLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeNetworkError, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyGeTuiPushKEY = @"GetTuiPush";
static NSString *KlyyGeTuiPushLogsPath = @"KlyyGeTuiPushLogs";
#define KlyyGeTuiPushLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeGetTuiPush, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyDistUpgradeKEY = @"DistUpgrade";
static NSString *KlyyDistUpgradeLogsPath = @"KlyyDistUpgradeLogs";
#define KlyyDistUpgradeLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeDistUpgrade, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyPhotoKEY = @"Photo";
static NSString *KlyyPhotoLogsPath = @"KlyyPhotoLogs";
#define KlyyLogTypePhotoLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypePhoto, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyLocationKEY = @"Location";
static NSString *KlyyLocationLogsPath = @"KlyyLocationLogs";
#define KlyyLocationLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeLocation, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static NSString *KlyyThirdRequestKEY = @"ThirdRequest";
static NSString *KlyyThirdRequestLogsPath = @"KlyyThirdRequestLogs";
#define KlyyThirdRequestLog(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, KlyyLogTypeThirdRequest, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#endif /* KlyyLogConst_h */
