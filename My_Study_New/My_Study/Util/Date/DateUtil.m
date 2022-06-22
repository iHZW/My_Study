//
//  DateUtil.m
//  StarterApp
//
//  Created by js on 2019/6/11.
//  Copyright © 2019 js. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSDateFormatter *)sharedDateFormatter
{
    // 多线程访问同一DateFormatter 对象会导致crash，所以为避免加锁引发性能问题， 为每个线程生成单独的DateFormatter对象
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        defaultFormatter = [[NSDateFormatter alloc] init];
//    });
//    return defaultFormatter;
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = threadDictionary[@"mydateformatter"];
    
    if (!dateFormatter) {
        @synchronized(self) {
            if (!dateFormatter) {
                dateFormatter = [[NSDateFormatter alloc] init];
                threadDictionary[@"mydateformatter"] = dateFormatter;
            }
        }
    }
    return dateFormatter;
}


+ (NSString *)prettyDateString{
    return [self prettyDateStringForDate:[NSDate date]];
}

+ (NSString *)prettyDateStringForDate:(NSDate *)date{
    NSDateFormatter *fmt = KDefaultFormatter;
    fmt.dateFormat = DATE_FORMAT_PRETTY;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)dateDayStringForDate:(NSDate *)date {
    NSDateFormatter *fmt = KDefaultFormatter;
    fmt.dateFormat = DATE_FORMAT_DAY;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)dateStringForDate:(NSDate *)date {
    NSDateFormatter *fmt = KDefaultFormatter;
    fmt.dateFormat = DATE_FORMAT_NORMAL;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)formateToSlashDate:(long long)ms{
    NSDateFormatter *fmt = KDefaultFormatter;
    fmt.dateFormat = DATE_FORMAT_SLASH;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    NSString *dateString = [fmt stringFromDate:date];
    return dateString;
}

+ (NSString *)getTimestampSince1970
{
    NSDate *datenow = [NSDate date];//现在时间
    NSTimeInterval interval = [datenow timeIntervalSince1970] * 1000;//13位的*1000
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",interval];
    return timeSp;
}

/**
 *  根据时间及时间格式获取对应的时间字符串
 @param format 输出的时间格式
 @return string类型日期
 */
+ (NSString *)getCurrentDateWithFormat:(NSString *)format
{
    return [[self class] getDateStringFromDate:[NSDate date] format:format];
}

/**
 *  根据时间及时间格式获取对应的时间字符串
 @param date 时间
 @param format 输出的时间格式
 @return string类型日期
 */
+ (NSString *)getDateStringFromDate:(NSDate *)date format:(NSString *)format
{
    if ([format length]<=0) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    NSDateFormatter *fmt = KDefaultFormatter;
    [fmt setDateFormat:format];
    if (!date) {
        date = [NSDate date];
    }
    NSString *timeStr = [fmt stringFromDate:date];
    return timeStr;
}


@end
