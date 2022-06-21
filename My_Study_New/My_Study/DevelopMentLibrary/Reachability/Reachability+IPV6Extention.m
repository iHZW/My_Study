//
//  Reachability+IPV6Extention.m
//  PASecuritiesApp
//
//  Created by Howard on 16/6/6.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "Reachability+IPV6Extention.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>


@implementation Reachability (IPV6Extention)

/**
 *  适配IPV6和IPV4环境下reachabilityForInternetConnection的网络状态检测
 *
 *  @return Reachability实例
 */
+ (instancetype)reachabilityForInternetConnectionExtention
{
    if ([Reachability isIPv6Address:[Reachability deviceIPAdress]])
    {
        struct sockaddr_in6 address;
        bzero(&address, sizeof(address));
        address.sin6_len    = sizeof(address);
        address.sin6_family = AF_INET6;
        
        return [self reachabilityWithAddress: (const struct sockaddr *) &address];
    }
    else
    {
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len    = sizeof(address);
        address.sin_family = AF_INET;
        
        return [self reachabilityWithAddress: (const struct sockaddr *) &address];
    }
}

/**
 *  IPV6地址格式化处理
 *
 *  @param ipv6Addr ipv6Addr 数据结构
 *
 *  @return 返回IPV6地址
 */
+ (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr
{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if (inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL)
    {
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

/**
 *  IPV4地址格式化处理
 *
 *  @param ipv4Addr ipv4Addr 数据结构
 *
 *  @return 返回IPV4地址
 */
+ (NSString *)formatIPV4Address:(struct in_addr)ipv4Addr
{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if (inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL)
    {
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

/**
 *  设备IP地址
 */
+ (NSString *)deviceIPAdress
{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                if (temp_addr->ifa_addr->sa_family == AF_INET) { // 如果是IPV4地址，直接转化
                    // Get NSString from C String
                    address = [self formatIPV4Address:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                else if (temp_addr->ifa_addr->sa_family == AF_INET6) {  // 如果是IPV6地址
                    address = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"])
                        break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/**
 *  检测IP地址是否是IPV6地址
 *
 *  @param ipAddress IP地址
 *
 *  @return 返回检测结果(IPV6地址:YES IPV4地址:NO)
 */
+ (BOOL)isIPv6Address:(NSString *)ipAddress
{
    struct sockaddr_in6 sa;
    return inet_pton(AF_INET6, [ipAddress UTF8String], &(sa.sin6_addr)) != 0;
    //    const char *utf8 = [ipAddress UTF8String];
    //
    //    // Check valid IPv4.
    //    struct in_addr dst;
    //    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    //
    //    if (success <= 0)
    //    {
    //        // Check valid IPv6.
    //        struct in6_addr dst6;
    //        success = inet_pton(AF_INET6, utf8, &dst6);
    //    }
    //    
    //    return (success == 1);
}

@end
