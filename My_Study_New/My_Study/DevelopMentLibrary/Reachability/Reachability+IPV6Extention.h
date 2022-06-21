//
//  Reachability+IPV6Extention.h
//  PASecuritiesApp
//
//  Created by Howard on 16/6/6.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "Reachability.h"


@interface Reachability (IPV6Extention)

/**
 *  适配IPV6和IPV4环境下reachabilityForInternetConnection的网络状态检测
 *
 *  @return Reachability实例
 */
+ (instancetype)reachabilityForInternetConnectionExtention;

/**
 *  设备IP地址
 */
+ (NSString *)deviceIPAdress;

@end
