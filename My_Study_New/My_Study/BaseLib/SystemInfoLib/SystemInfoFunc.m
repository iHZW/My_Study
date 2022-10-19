//
//  SystemInfoFunc.m
//  iPhoneNewVersion
//
//  Created by Howard on 13-6-14.
//  Copyright (c) 2013年 PAS. All rights reserved.
//

#import "SystemInfoFunc.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#include <ifaddrs.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"
#import "Reachability+IPV6Extention.h"
#import <UIKit/UIKit.h>


@implementation SystemInfoFunc

/**
 *  获取设备名称
 *
 *  @return 返回设备名称(如iPhone1,1 iPhone1,2 iPod1,1 i386 等)
 */
+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString * platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return platform;
}

/**
 *  获取系统名称
 *
 *  @return 返回系统名称(e.g. @"iOS")
 */
+ (NSString *)systemName
{
    return [UIDevice currentDevice].systemName;
}

/**
 *  获取系统版本号
 *
 *  @return 返回系统版本号(e.g. @"4.0)
 */
+ (NSString *)systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

/**
 *  获取带有build标记的系统版本号
 *
 *  @return 回build标记的系统版本号(e.g. @"version 6.13 (build2367)")
 */
+ (NSString *)systemVersionWithBuildingNo
{
    return [NSProcessInfo processInfo].operatingSystemVersionString;
}

/**
 *  获取设备标记名称
 *
 *  @return 返回设备标记名称(e.g. "My iPhone")
 */
+ (NSString *)deviceDescription
{
    return [UIDevice currentDevice].name;
}

/**
 *  获取电池状态相关信息
 *
 *  @return 返回电池状态相关信息
 */
+ (UIDeviceBatteryState)batteryState
{
    return [UIDevice currentDevice].batteryState;
}

/**
 *  获取电池电量
 *
 *  @return 返回电池电量
 */
+ (CGFloat)batteryLevel
{
    return [UIDevice currentDevice].batteryLevel;
}

/**
 *  获取设备类型
 *
 *  @return 返回设备类型
 */
+ (NSString *)model
{
    return [UIDevice currentDevice].model;
}

/**
 *  获取设备类型
 *
 *  @return 返回设备类型
 */
+ (NSString *)localizedModel
{
    return [UIDevice currentDevice].localizedModel;
}

/**
 *  获取设备MAC地址信息
 *
 *  @return 返回设备MAC地址信息
 */
+ (NSString *)macAddress
{
    int                    mib[6];
	size_t					len;
	char					*buf;
	unsigned char			*ptr;
	struct if_msghdr		*ifm;
	struct sockaddr_dl		*sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	
	NSString *macAddStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
    
	return macAddStr;
}

/**
 *  获取设备物理内存大小
 *
 *  @return 返回设备物理内存大小
 */
+ (double)physicalMemory
{
    return [NSProcessInfo processInfo].physicalMemory;
}

/**
 *  获取当前app进程动态标识
 *
 *  @return 返回当前app进程动态标识
 */
+ (NSString *)globallyUniqueStringForProcess
{
    return [NSProcessInfo processInfo].globallyUniqueString;
}

/**
 *  获取主机名
 *
 *  @return 返回主机名
 */
+ (NSString *)hostName
{
    return [NSProcessInfo processInfo].hostName;
}

/**
 *  获取当前app进程名称
 *
 *  @return 返回当前app进程名称
 */
+ (NSString *)processName
{
    return [NSProcessInfo processInfo].processName;
}

/**
 *  获取bundle标识
 *
 *  @return 返回bundle标识
 */
+ (NSString *)bundleName
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleName"];
}

/**
 *  获取app显示名称
 *
 *  @return 返回app显示名称
 */
+ (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"];
}

/**
 *  获取开发版本号(带BuildNo)
 *
 *  @return 返回设备类型
 */
+ (NSString *)developmentVersionNumber
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}

/**
 *  获取发布版本号码
 *
 *  @return 返回发布版本号码
 */
+ (NSString *)marketingVersionNumber
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

/**
 *  获取CPU使用率
 *
 *  @return 返回CPU使用率
 */
+ (CGFloat)cpuStatus
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
//    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
//    uint32_t stat_thread = 0; // Mach threads
    
//    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
//    if (thread_count > 0)
//        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    CGFloat tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    return tot_cpu;
}

/**
 *  获取内存使用状态信息
 *
 *  @return 返回内存使用状态信息:NSDictionary=>{NSNumber(NSUInteger):kMemTotal, NSNumber(NSUInteger):kMemUsed, NSNumber(NSUInteger):kMemFreed, NSNumber(CGFloat):kMemUsage}
 */
+ (NSDictionary *)memoryStatus
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        NSLog(@"Failed to fetch vm statistics");
        return nil;
    }
    
    /* Stats in bytes */
    NSNumber *mem_used  = @((vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize);
    NSNumber *mem_free  = @(vm_stat.free_count * pagesize);
    NSNumber *mem_total = @([mem_used unsignedIntegerValue] + [mem_free unsignedIntegerValue]);
    NSNumber *usage     = @(mem_used.floatValue / mem_total.floatValue);
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:mem_total, kMemTotal, mem_free, kMemFreed, mem_used, kMemUsed, usage, kMemUsage, nil];
    
    return dictionary;
}

/**
 *  本地IP地址
 */
+ (NSString *)localIPAddress
{
    return [Reachability deviceIPAdress];
}

/**
 *  获取网络流量使用状态信息
 *
 *  @return 返回网络流量使用状态信息:NSDictionary=>{NSString:kSendByWIFI, NSString:kRecvByWIFI, NSString:kSendByWWAN, NSString:kRecvByWWAN}
 */
+ (NSDictionary *)networkUsageStatus
{
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    unsigned long WiFiSent        = 0;
    unsigned long WiFiReceived    = 0;
    unsigned long WWANSent        = 0;
    unsigned long WWANReceived    = 0;
    BOOL success = getifaddrs(&addrs) == 0;
    
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            if (AF_LINK != cursor->ifa_addr->sa_family) {
                cursor = cursor->ifa_next;
                continue;
            }
            
            if (!(cursor->ifa_flags & IFF_UP) && !(cursor->ifa_flags & IFF_RUNNING)) {
                cursor = cursor->ifa_next;
                continue;
            }
            
            if (cursor->ifa_data == 0) {
                cursor = cursor->ifa_next;
                continue;
            }
            
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                if (strncmp(cursor->ifa_name, "lo", 2)) {   // WIFI
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent += networkStatisc->ifi_obytes;
                    WiFiReceived += networkStatisc->ifi_ibytes;
                } if (!strcmp(cursor->ifa_name,"pdp_ip0")) { // WWAN
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent += networkStatisc->ifi_obytes;
                    WWANReceived += networkStatisc->ifi_ibytes;
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return success ? [NSDictionary dictionaryWithObjectsAndKeys:@((WiFiSent/1024)), kSendByWIFI, @((WiFiReceived/1024)), kRecvByWIFI, @((WWANSent/1024)), kSendByWWAN, @((WWANReceived/1024)), kRecvByWWAN, nil] : nil;
}

/* 获取网络流量大小 */
+ (long long)getGprsWifiFlowIOBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }
    
    uint64_t iBytes = 0;
    uint64_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        
        if (strncmp(ifa->ifa_name, "lo", 2)) {  // Wifi
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
        
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {    // 3G或者GPRS
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    
    freeifaddrs(ifa_list);
    uint64_t bytes = iBytes + oBytes;
    return bytes;
}

#pragma mark - 获取Wifi信息
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

#pragma mark - 获取WIFI名字
+ (NSString *)getWifiSSID
{
    return (NSString *)[self fetchSSIDInfo][@"SSID"];
}
#pragma mark - 获取WIFI的MAC地址
+ (NSString *)getWifiBSSID
{
    return (NSString *)[self fetchSSIDInfo][@"BSSID"];
}

#pragma mark - 网络链接是否使用代理
+ (BOOL)checkProxyEnable
{
    BOOL bRet = NO;
    CFDictionaryRef proxyDic = CFNetworkCopySystemProxySettings();
    
    if (proxyDic)
    {
        CFBooleanRef proxyEnable = (CFBooleanRef)CFDictionaryGetValue(proxyDic, kCFNetworkProxiesHTTPEnable);
        bRet = proxyEnable && CFBooleanGetValue(proxyEnable) ? YES : NO;
        
        CFRelease(proxyDic);
        proxyDic = NULL;
    }
    
    return bRet;
}

#pragma mark - 获取当前连网类型（WIFI 或 移动网络）
+ (NETWORKTYPE)checkNetworkType
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    bool didRetrieveFlags	= SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags\n");
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL bRet = (isReachable && !needsConnection) ? YES : NO;
    
    BOOL isNoneWIFI		= flags & kSCNetworkReachabilityFlagsTransientConnection;	// Mac OS use kSCNetworkFlagsTransientConnection
    NETWORKTYPE netType = bRet ? (isNoneWIFI ? NETWORK_NOWIFI : NETWORK_WIFI) : NETWORK_NONE;
    
    return netType;
}

#pragma mark - 获取当前连网类型（WIFI 或 移动网络）
+ (BOOL)checkNetworkStatus:(int *)netWorkType hostUrl:(NSString *)hostUrl
{
    Reachability *curReach = [Reachability reachabilityWithHostName:hostUrl];
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    *netWorkType = status == ReachableViaWiFi ? NETWORK_WIFI : NETWORK_NOWIFI;
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //    BOOL connectionRequired = [curReach connectionRequired];
    //    if (netStatus == NotReachable) connectionRequired = NO;
    return netStatus != NotReachable;
}

#pragma mark - 获得SIM卡网络运营商信息
+ (CTTelephonyNetworkInfo *)telephonyNetworkInfo
{
    static CTTelephonyNetworkInfo *info = nil;
    if (!info) {
        info = [[CTTelephonyNetworkInfo alloc] init];
    }
//
    return info;
}

+ (CTCarrier *)carrierInfo
{
    CTTelephonyNetworkInfo *info = [SystemInfoFunc telephonyNetworkInfo];
    return info.subscriberCellularProvider;
}

+ (NSString *)getCarryName
{
    //当前手机所属运营商名称
    NSString *mobile = nil;
    
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    CTCarrier *carrier = [self carrierInfo];
    if (!carrier.isoCountryCode) {
        mobile = @"";
    }else{
        mobile = [NSString stringWithFormat:@"%@%@",carrier.mobileCountryCode,carrier.mobileNetworkCode];
    }
    return mobile;
}

+ (NSInteger)networkTypeWithOriginText:(NSString *)oText
{
    NSInteger netType = -1;
    
    if ([oText containsString:@"4G"]) {
        netType = 3;
    } else if ([oText containsString:@"LTE"]) {
        netType = 4;
    } else if ([oText containsString:@"3G"]) {
        netType = 2;
    } else if ([oText containsString:@"2G"]) {
        netType = 1;
    } else if ([oText containsString:@"NONE"]) {
        netType = 0;
    }
    
    return netType;
}

/**
 从状态栏获取当前网络状态信息(主线程调用)

 @return (-1:代表未知状态, 0:无网, 1:2G, 2:3G, 3:4G, 4:LTE, 5:WIFI)
 */
+ (NSInteger)netWorkState
{
    if (@available(iOS 13.0, *)) {
        UIApplication *application = [UIApplication sharedApplication];
        NSLog(@"%@", application);
        return -1;
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        UIView *statusBar          = [application valueForKeyPath:@"statusBar"];
        NSArray *children          = nil;
        NSInteger netType          = -1;
//        NSString *test;
        
        if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) { // iPhoneX 机型
            UIView *foregroundView = [[statusBar valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"];
            children = foregroundView.subviews.count >= 3 ? [[foregroundView subviews][2] subviews] : nil;
            
            for (id subview in children) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    netType = 5;
                    break;
                } else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                    NSString *oText = [subview valueForKeyPath:@"originalText"];
                    netType = [self networkTypeWithOriginText:oText];
                    break;
                }
            }
        } else {    // 非iPhoneX 机型
            children = [[statusBar valueForKeyPath:@"foregroundView"] subviews];
            NSArray *enumerateList  = children ? [NSArray arrayWithArray:children] : nil;
            for (id child in enumerateList) {
                if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                    // 获取到状态栏
                    netType = [[child valueForKeyPath:@"dataNetworkType"] integerValue];
                    
                    break;
                }
            }
        }
        
        return netType;
    }
}

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
+ (NSString *)networkTypeDescription
{
    CTTelephonyNetworkInfo *info = [SystemInfoFunc telephonyNetworkInfo];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    
    if (currentStatus) {
        currentStatus = [currentStatus stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
    }
    
    return currentStatus;
}

/**
 WIFI是否开启(注意主线程调用)
 
 @return YES:开启 NO:未开启
 */
+ (BOOL)enableWiFi
{
#if 0
    NSCountedSet * cset = [[NSCountedSet alloc] init];
    struct ifaddrs *interfaces;
    
    if (!getifaddrs(&interfaces)) {
        for (struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
        
        freeifaddrs(interfaces);
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
#else
    BOOL wifiEnable        = NO;
    UIApplication *app     = [UIApplication sharedApplication];
    UIView *statusBar      = [app valueForKeyPath:@"statusBar"];
    BOOL isModernStatusBar = [statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")];
    
    if (isModernStatusBar) { // 在 iPhone X 上 statusBar 属于 UIStatusBar_Modern ，需要特殊处理
        id currentData = [statusBar valueForKeyPath:@"statusBar.currentData"];
        wifiEnable     = [[currentData valueForKeyPath:@"_wifiEntry.isEnabled"] boolValue];
    } else {
        NSInteger type    = 0;
        NSArray *children = [[statusBar valueForKeyPath:@"foregroundView"] subviews];
        for (id child in children) {
            if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                type = [[child valueForKeyPath:@"dataNetworkType"] integerValue];
                break;
            }
        }
        
        wifiEnable = type == 5 ? YES : NO;
    }
    
    return wifiEnable;
#endif
}

/**
 是否为飞行模式

 @return YES:飞行模式开起，否则NO
 */
+ (BOOL)flightMode
{
    CTTelephonyNetworkInfo *info = [[self class] telephonyNetworkInfo];
    BOOL retVal = info.currentRadioAccessTechnology ? NO : YES;
    return retVal;
}

/**
 获取网络权限状态
 */
+ (CTCellularDataRestrictedState)networkRightStatus
{
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    
    return state;
}

/**
 信号强度等级(返回数据格式:2-3, wifi和移动网络信号用-分隔，前面wifi，后面移动网络)
 */
+ (NSString *)signalStrengthBar
{
    if (@available(iOS 13.0, *)) {
         UIApplication *application = [UIApplication sharedApplication];
        NSLog(@"%@", application);
        return @"-";
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        UIView *statusBar          = [application valueForKeyPath:@"statusBar"];
        NSArray *children          = nil;
//        NSInteger netType          = -1;
//
//        NSString *dataNetworkItemView = nil;
//        NSString *signalStrengthBars = @"";
        
        NSInteger signalWifi = 0;
        NSInteger signalWAN = 0;
        
        if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) { // iPhoneX 机型
            UIView *foregroundView = [[statusBar valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"];
            children = foregroundView.subviews.count >= 3 ? [[foregroundView subviews][2] subviews] : nil;
            
            for (id subview in children) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) { // WIFI
                    signalWifi = [[subview valueForKey:@"_numberOfActiveBars"] integerValue];
                } else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarCellularSignalView")]) {  // WAN
                    signalWAN = [[subview valueForKey:@"_numberOfActiveBars"] integerValue];
                }
            }
        } else {    // 非iPhoneX 机型
            children = [[statusBar valueForKeyPath:@"foregroundView"] subviews];
            
            for (id subview in children) {
                if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) { // WIFI
                    signalWifi = [[subview valueForKey:@"_wifiStrengthBars"] integerValue];
                } else if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")]) {   // WAN
                    signalWAN = [[subview valueForKey:@"_signalStrengthBars"] integerValue];
                }
            }
        }
        
        return [NSString stringWithFormat:@"%@-%@", @(signalWifi), @(signalWAN)];
    }
}

@end
