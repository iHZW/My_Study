//
//  ZWSiteAddressManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWSiteAddressManager.h"


NSString const *PASAppSiteBaseHttpURLKey = @"BaseHttpURL";

@implementation ZWSiteAddressManager

DEFINE_SINGLETON_T_FOR_CLASS(ZWSiteAddressManager)


/**
 *  json请求根url
 *
 *  @return NSString 根url
 */
+ (NSString *)getBaseHttpURL
{
    /* 设置根url */
    return @"http://127.0.0.1:4523/m1/1102411-0-5ea01a58";
}

/**
 *  获取app版本号，默认在原始版本号基础上添加.0  格式如下6.3.0.0
 */
static NSString *appVersion = nil;
+ (NSString *)appVersion
{
    if (!appVersion)
    {
        NSString *originVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *fixedTailVersion = @"0";
        appVersion = [NSString stringWithFormat:@"%@.%@",originVersion, fixedTailVersion];
        appVersion = appVersion ?: originVersion; // 如果出现错误就直接取原始的
    }
    return appVersion;
}

/**
 *  渠道
 */
+ (NSString *)appChannel
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppChannelKey"];
}



@end
