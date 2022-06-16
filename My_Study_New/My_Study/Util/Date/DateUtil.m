//
//  DateUtil.m
//  StarterApp
//
//  Created by js on 2019/6/11.
//  Copyright © 2019 js. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSString *)prettyDateString{
    return [self prettyDateStringForDate:[NSDate date]];
}

+ (NSString *)prettyDateStringForDate:(NSDate *)date{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = DATE_FORMAT_PRETTY;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)dateDayStringForDate:(NSDate *)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = DATE_FORMAT_DAY;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)dateStringForDate:(NSDate *)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = DATE_FORMAT_NORMAL;
    NSString *time = [fmt stringFromDate:date];
    return time;
}

+ (NSString *)formateToSlashDate:(long long)ms{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
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
@end
