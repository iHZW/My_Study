//
//  ZWCommonUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/22.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCommonUtil.h"
#import "CommonFileFunc.h"
#import "ZWDataCache.h"
#import "ZWCacheDefine.h"

@implementation ZWCommonUtil

#pragma mark - UserDefault

+ (nullable NSString *)getStringWithKey:(nonnull NSString *)key
{
    if (key &&[key isKindOfClass:[NSString class]]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    } else {
        return @"";
    }
}

+ (void)setObject:(nullable NSObject *)obj forKey:(nonnull NSString *)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (obj) {
        [userDefault setObject:obj forKey:key];
    } else {
        [userDefault removeObjectForKey:key];
    }
    [userDefault synchronize];
}

+ (nullable NSObject *)getObjectWithKey:(nonnull NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (nullable NSData *)getDataWithKey:(nonnull NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] dataForKey:key];
}

+ (nullable NSArray*)getArrayWithKey:(nonnull NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:key];
}

+ (nullable NSDictionary*)getDicWithKey:(nonnull NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}

+ (void)removeForKey:(nonnull NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}



/**
 *  读取本地文件数据进网络缓存
 *
 *  @param localFileName 本地文件名
 *  @param cacheFileName 缓存文件名
 */
+ (void)saveCmsDataToCache:(nullable NSString *)localFileName
                 cacheName:(nullable NSString *)cacheFileName
{
    NSString *cacheFilePath = [CommonFileFunc getNetWorkingDataCaches:cacheFileName];
    if (![CommonFileFunc fileExistsAtPath:cacheFilePath]) {
        NSString *localFilePath = [[NSBundle mainBundle] pathForResource:localFileName ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:localFilePath];
        if ([fileData length]) {
            [[ZWDataCache sharedZWDataCache] saveData:fileData toCacheWithPath:cacheFilePath];
        }
    }
}

/**
 *  清除所有的存储本地的数据
 */
+ (void)clearAllUserDefaultsData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    for (id  key in dic) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

#pragma mark - 存本地网络缓存数据
+ (void)checkAndWriteLocalCMSDataToCache
{
    /** 设置本地缓存数据 */
    [ZWCommonUtil saveCmsDataToCache:@"CacheClientChatDetailConfig" cacheName:kCacheString_clientChatDetailConfig];
}


@end
