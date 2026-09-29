//
//  SystemInfoFunc.h
//  iPhoneNewVersion
//
//  Created by Howard on 13-6-14.
//  Copyright (c) 2013年 PAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCellularData.h>

#define kMemTotal   @"memTotal"
#define kMemUsed    @"MemUsed"
#define kMemFreed   @"MemFreed"
#define kMemUsage   @"MemUsage"

#define kSendByWIFI @"sendByWIFI"
#define kRecvByWIFI @"recvByWIFI"
#define kSendByWWAN @"sendByWWAN"
#define kRecvByWWAN @"recvByWWAN"

typedef enum _NETWORKTYPE
{
    NETWORK_NONE        = 0,        // 无网
	NETWORK_NOWIFI		= 1,		// 非WIFI
	NETWORK_WIFI		= 2,		// WIFI
    
}NETWORKTYPE;


@interface SystemInfoFunc : NSObject
/**
 *  获取设备名称
 *
 *  @return 返回设备名称(如iPhone1,1 iPhone1,2 iPod1,1 i386 等)
 */
+ (NSString *)deviceName;

/**
 *  获取系统名称
 *
 *  @return 返回系统名称(e.g. @"iOS")
 */
+ (NSString *)systemName;

/**
 *  获取系统版本号
 *
 *  @return 返回系统版本号(e.g. @"4.0)
 */
+ (NSString *)systemVersion;

/**
 *  获取带有build标记的系统版本号
 *
 *  @return 回build标记的系统版本号(e.g. @"version 6.13 (build2367)")
 */
+ (NSString *)systemVersionWithBuildingNo;

/**
 *  获取设备标记名称
 *
 *  @return 返回设备标记名称(e.g. "My iPhone")
 */
+ (NSString *)deviceDescription;

/**
 *  获取电池状态相关信息
 *
 *  @return 返回电池状态相关信息
 */
+ (UIDeviceBatteryState)batteryState;

/**
 *  获取电池电量
 *
 *  @return 返回电池电量
 */
+ (CGFloat)batteryLevel;

/**
 *  获取设备类型
 *
 *  @return 返回设备类型
 */
+ (NSString *)model;

/**
 *  获取设备类型
 *
 *  @return 返回设备类型
 */
+ (NSString *)localizedModel;

/**
 *  获取设备MAC地址信息
 *
 *  @return 返回设备MAC地址信息
 */
+ (NSString *)macAddress;

/**
 *  获取设备物理内存大小
 *
 *  @return 返回设备物理内存大小
 */
+ (double)physicalMemory;

/**
 *  获取当前app进程动态标识
 *
 *  @return 返回当前app进程动态标识
 */
+ (NSString *)globallyUniqueStringForProcess;

/**
 *  获取主机名
 *
 *  @return 返回主机名
 */
+ (NSString *)hostName;

/**
 *  获取当前app进程名称
 *
 *  @return 返回当前app进程名称
 */
+ (NSString *)processName;

/**
 *  获取bundle标识
 *
 *  @return 返回bundle标识
 */
+ (NSString *)bundleName;

/**
 *  获取app显示名称
 *
 *  @return 返回app显示名称
 */
+ (NSString *)appName;

/**
 *  获取开发版本号(带BuildNo)
 *
 *  @return 返回设备类型
 */
+ (NSString *)developmentVersionNumber;

/**
 *  获取发布版本号码
 *
 *  @return 返回发布版本号码
 */
+ (NSString *)marketingVersionNumber;

/**
 *  获取CPU使用率
 *
 *  @return 返回CPU使用率
 */
+ (CGFloat)cpuStatus;

/**
 *  获取内存使用状态信息
 *
 *  @return 返回内存使用状态信息:NSDictionary=>{NSNumber(NSUInteger):kMemTotal, NSNumber(NSUInteger):kMemUsed, NSNumber(NSUInteger):kMemFreed, NSNumber(CGFloat):kMemUsage}
 */
+ (NSDictionary *)memoryStatus;

/**
 *  本地IP地址
 */
+ (NSString *)localIPAddress;

/**
 *  获取网络流量使用状态信息
 *
 *  @return 返回网络流量使用状态信息:NSDictionary=>{NSString:kSendByWIFI, NSString:kRecvByWIFI, NSString:kSendByWWAN, NSString:kRecvByWWAN}
 */
+ (NSDictionary *)networkUsageStatus;

/**************************************************************************
 FunctionName:  checkProxyEnable
 FunctionDesc:  网络链接是否使用代理
 Parameters:    NONE
 ReturnVal:     BOOL (YES:使用代理设置 NO:未使用代理设置)
 **************************************************************************/
+ (BOOL)checkProxyEnable;

/**************************************************************************
 FunctionName:  checkNetworkType
 FunctionDesc:  获取当前连网类型（WIFI 或 移动网络）
 Parameters:
 ReturnVal:     NETWORKTYPE
 **************************************************************************/
+ (NETWORKTYPE)checkNetworkType;

/**************************************************************************
 FunctionName:  checkNetworkStatus
 FunctionDesc:  检测本地网络链接状态
 Parameters:
 Param1Name:    netWorkType:int *
 Param1Desc:    返回当前网络类型 NETWORKTYPE
 Param2Name:    hostUrl:NSString
 Param2Desc:    要测试的网络连接地址
 ReturnVal:     BOOL (YES:本地网络链接正常 NO:本地网络链接异常)
 **************************************************************************/
+ (BOOL)checkNetworkStatus:(int *)netWorkType hostUrl:(NSString *)hostUrl;

/**************************************************************************
 FunctionName:  carrierInfo
 FunctionDesc:  获得SIM卡网络运营商
 Parameters:    NONE
 ReturnVal:     CTCarrier*
 (Carrier name: [中华电信]
 Mobile Country Code: [466]
 Mobile Network Code:[92]
 ISO Country Code:[tw]
 Allows VOIP? [YES])
 **************************************************************************/
+ (CTCarrier *)carrierInfo;

/**
 *  获取运营商信息
 */
+ (NSString *)getCarryName;

/**
 从状态栏获取当前网络状态信息(主线程调用)
 
 @return (-1:代表未知状态, 0:无网, 1:2G, 2:3G, 3:4G, 4:LTE, 5:WIFI)
 */
+ (NSInteger)netWorkState;

/**
 网络类型描述信息
 01    GPRS             //介于2G和3G之间，也叫2.5G ,过度技术
 02    Edge             //EDGE为GPRS到第三代移动通信的过渡，EDGE俗称2.75G
 03    WCDMA
 04    HSDPA            //亦称为3.5G(3?G)
 05    HSUPA            //3G到4G的过度技术
 06    CDMA1x           //3G
 07    CDMAEVDORev0     //3G标准
 08    CDMAEVDORevA
 09    CDMAEVDORevB
 10    HRPD             //电信使用的一种3G到4G的演进技术， 3.75G
 11    LTE              //接近4G
 */
+ (NSString *)networkTypeDescription;

/**
 WIFI是否开启(注意主线程调用)
 
 @return YES:开启 NO:未开启
 */
+ (BOOL)enableWiFi;

/**
 是否为飞行模式
 
 @return YES:飞行模式开起，否则NO
 */
+ (BOOL)flightMode;

/**
 获取网络权限状态
 */
+ (CTCellularDataRestrictedState)networkRightStatus;

/**
 信号强度等级(返回数据格式:2-3, wifi和移动网络信号用-分隔，前面wifi，后面移动网络)
 */
+ (NSString *)signalStrengthBar;

@end
