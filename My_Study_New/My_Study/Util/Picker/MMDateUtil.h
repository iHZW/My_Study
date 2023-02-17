//
//  MMDateUtil.h
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const _Nonnull DATE_FORMAT_PRETTY = @"yyyy-MM-dd HH:mm:ss.SSS";
static NSString *const _Nonnull DATE_FORMAT_NORMAL = @"yyyy-MM-dd HH_mm_ss";
static NSString *const _Nonnull DATE_FORMAT_DAY    = @"yyyy-MM-dd";
static NSString *const _Nonnull DATE_FORMAT_SLASH  = @"yyyy/MM/dd";

@interface MMDateUtil : NSObject

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

/**
 *  根据时间及时间格式获取对应的时间字符串
 @param format 输出的时间格式
 @return string类型日期
 */
+ (NSString *)getCurrentDateWithFormat:(NSString *)format;

/**
 *  根据时间及时间格式获取对应的时间字符串
 @param date 时间
 @param format 输出的时间格式
 @return string类型日期
 */
+ (NSString *)getDateStringFromDate:(NSDate *)date format:(NSString *)format;

@end

NS_ASSUME_NONNULL_END