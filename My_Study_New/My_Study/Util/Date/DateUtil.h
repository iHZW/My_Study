//
//  DateUtil.h
//  StarterApp
//
//  Created by js on 2019/6/11.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const _Nonnull DATE_FORMAT_PRETTY = @"yyyy-MM-dd HH:mm:ss.SSS";
static NSString * const _Nonnull DATE_FORMAT_NORMAL = @"yyyy-MM-dd HH_mm_ss";
static NSString * const _Nonnull DATE_FORMAT_DAY = @"yyyy-MM-dd";
static NSString * const _Nonnull DATE_FORMAT_SLASH = @"yyyy/MM/dd";

NS_ASSUME_NONNULL_BEGIN

@interface DateUtil : NSObject

/**
 * 当前时间转成字符串
 */
+ (NSString *)prettyDateString;

/**
 * 日期转成 yyyy-MM-dd HH:mm:ss.SSS
 */
+ (NSString *)prettyDateStringForDate:(NSDate *)date;

/**
 * 日期转成 yyyy-MM-dd HH:mm:ss
 */
+ (NSString *)dateStringForDate:(NSDate *)date;

/**
 * 日期转成 yyyy-MM-dd
 */
+ (NSString *)dateDayStringForDate:(NSDate *)date;

+ (NSString *)formateToSlashDate:(long long)ms;

/**
 * 获取当前时间戳 13位
 */
+ (NSString *)getTimestampSince1970;
@end

NS_ASSUME_NONNULL_END
