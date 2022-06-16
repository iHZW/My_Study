//
//  DataFormatterFunc+Market.h
//  FormaterLib
//
//  Created by Howard on 2019/3/15.
//

#import "DataFormatterFunc.h"
#import "NSString+NumberFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataFormatterFunc (Market)

+ (NSString *)FormatDStr:(float)v len:(int)len dig:(int)dig;
+ (char *)itoa:(int)n c:(char *)c;
+ (NSString *)formatDate:(int)date flag:(NSString *)flag;
+ (NSString *)formatDate:(NSString *)dateTime srcFormat:(NSString *)srcFormat destFormat:(NSString *)destFormat;

+ (NSTimeInterval)getCurTick;
+ (NSString *)getDate:(NSString*)curDateStr;

// NSDate* ==> numDate(20110930)
+ (int)getNumDate:(NSDate *)date;

// numDate(20110930) ==> NSDate*
+ (NSDate *)getDateFromNumDate:(int)numDate;

+ (NSString *)getCurrentDateTimeWithFormatter:(NSString *)formatterStr;

// NSDateComponents类型的weekday ==> 中国式星期几
+ (int)getCNWeekDay:(int)dateComponentsWeekDay;

+ (NSDate *)IncDate:(NSDate *)date withDay:(int)day;

// numDate: 20110930
// 返回周一的数字日期
+ (int)getBeginningOfWeekNumDate:(int)numDate;

// numDate(20110930) ==> 20110901
+ (int)getBeginningOfMonthNumDate:(int)numDate;

// numDate: 20110930
// pweekday: 返回星期几，已转化为中国习惯。
// pweek: 一年中第几周
+ (BOOL)getWeekday:(int)numDate pweekday:(int *)pweekday pweek:(int *)pweek;

// 根据生日计算星座
+ (NSString *)getAstroWithMonth:(int)m day:(int)d;

// numDate: 20110930
// pweekday: 返回星期几，已转化为中国习惯。
// pweek: 一年中第几周
+ (BOOL)getMonthday:(int)numDate pday:(int *)pday pmonth:(int *)pmonth;

//获取2个日期间的时间间隔，返回多少秒
+ (NSTimeInterval)getDateFrom:(NSString *)fromDate toDate:(NSString *)toDate;

//根据秒数返回日期的字符串
+ (NSString *)getDataStrWith:(NSTimeInterval)timeNum;
// 返回 hh:ss
+ (NSString *)getDataStrWithMS:(NSTimeInterval)timeNum;

// 根据格式化字符串来显示日期 如：yyyy-MM-dd HH:mm:ss.SSS
+ (NSString *)getCurrentDateTimeStr:(NSString *)formatStr;
+ (int)getWeekDay:(int)year month:(int)month day:(int)day;
+ (unsigned int)lunarCalendarNum:(int)year month:(int)month day:(int)day;
+ (NSString *)lunarCalendarString:(int)year month:(int)month day:(int)day;
+ (NSString *)lunarCalendarString:(unsigned int)lunarCalendarDay;
+ (NSArray *)lunarCalendarMonthAndDay:(unsigned int)lunarCalendarDay;

// 如果dateStr为2012-02-23，则格式应为yyyy-MM-dd
// 如果dateStr为20120223，则格式应为yyyyMMdd
+ (BOOL)isTodayOfStrDate:(NSString *)dateStr formatStr:(NSString *)formatStr;

// 二进制转换十进制处理
+ (_int64)toDecimalSystemWithBinarySystem:(NSString *)binary;

// 根据数据映射Y轴坐标
+ (float)mappingAsixYValue:(float)max min:(float)min v:(float)v top:(float)top bottom:(float)bottom;
// 根据数据映射X轴坐标
+ (float)mappingAsixXValue:(float)max min:(float)min v:(float)v left:(float)left right:(float)right;
//根据Y的坐标，映射Y对应的值
+ (float)mappingValueByAsixY:(float)max min:(float)min y:(float)y top:(float)top bottom:(float)bottom;

//根据输入输出如1，000，000或者1，000，000.00格式的金额字符串
//money 金额
//point 是否需要小数点和后两位
+ (NSString *)getMoneyFormatStringWith:(float)money isNeedPoint:(BOOL)point;

+ (NSArray *)seperateStringByLen:(NSString *)content len:(int)len;

//千位分割符
+ (NSString *)separatedDigitStringWithStr:(NSString *)digitString;

+ (NSString *)getNewStrWithSepStr:(NSString *)sepStr recvStr:(NSString *)recvStr;

// NSDate相关
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSTimeInterval)getTimeIntervalFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSTimeInterval)getTimeIntervalFromString:(NSString *)fromDate toString:(NSString *)toDate;

+ (NSNumber *)numberFromString:(NSString *)stringVal;
// 取当前时间 格式YYYY-MM-DD HHmmss
+ (NSString *)getCurTimeStr;

// 获取当前时间，没有日期，精确到，时，分，秒，毫秒
+ (NSString *)getCurTimeNanoSecondStr;

//获取固定时间间隔的分钟时间字符串
//interval -时间间隔，假如传入5，获取到的时间字符串为：201505071050  201505071055
+ (NSString *)getTimeStrInMinutes:(NSInteger)interval;

/**格式化时间数据*/
+ (NSString *)getNewFormatTimeEx:(NSString *)time;

+ (NSString *)getServerTimeMinuteModNVal:(int)nVal;

+ (NSString *)stringBMPFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
