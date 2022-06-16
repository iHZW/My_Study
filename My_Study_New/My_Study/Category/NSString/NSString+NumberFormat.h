//
//  NSString+Number.h
//  DzhProjectiPhone
//
//  Created by Duanwwu on 14-9-30.
//  Copyright (c) 2014年 gw. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef __INT64
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32
typedef unsigned long _uint64;
typedef long long _int64;
#else
typedef unsigned long long _uint64;
typedef long long _int64;
#endif
#endif

@interface NSString (NumberFormat)

+ (_int64)convertVal:(int)Val;

/**
 修复字符串精度问题

 @param string 修复前的字符串
 @return 修复后的
 */
+ (NSString *)format_reviseString:(NSString *)string;

/**
 * 生成格式化后的字符串，value为0则返回"--"
 * @param value 浮点值
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringNoZeroWithFloatValue:(float)value precision:(int)precision;

/**
 * 格式化浮点数成字符串，长度为len，小数位数为precision，value为0则返回"--"
 * 如果value为整数，则直接转为字符串返回，否则先使用%.(precision)f对value进行格式化，生成的字符串长度如果大于len，则对小数部分进行截取。
 * @param value 浮点数
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringNoZeroWithFloatValue:(float)value length:(int)len precision:(int)precision;

/**
 * 生成格式化后的字符串，value为0不返回"--"
 * @param value 浮点值
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringWithFloatValue:(float)value precision:(int)precision;

/**
 * 格式化浮点数成字符串，长度为len，小数位数为precision，value为0不返回"--"
 * 如果value为整数，则直接转为字符串返回，否则先使用%.(precision)f对value进行格式化，生成的字符串长度如果大于len，则对小数部分进行截取。
 * @param value 浮点数
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringWithFloatValue:(float)value length:(int)len precision:(int)precision;

/**
 * 格式化浮点数成整形字符串，需四舍五入，长度为len，value为0返回"--"
 * @param value 浮点数
 * @param len 总长度
 * @returns 字符串
 */
+ (NSString *)format_stringForIntWithFloatValue:(float)value length:(int)len;

/**
 * 格式化成交量数据
 * 小于等于0，返回"--"
 * 其它不做处理
 * @param volume 成交量
 * @returns 字符串
 */
+ (NSString *)format_stringNoUnitWithVolume:(_int64)volume;

/**
 * 格式化成交量数据，precision为2
 * @see format_stringWithVolume:precision
 */
+ (NSString *)format_stringWithVolume:(_int64)volume;

/**
 * 格式化成交量数据
 * 小于等于0，返回"--"
 * 大于0，小于1万，直接返回
 * 大于1万，小于1亿，格式化为以万做单位
 * 大于1亿，格式化为以亿做单位
 * @param volume 成交量
 * @Param precision 突破万后面显示的小数点个数，如100000，precision为2时显示10.00万
 * @returns 字符串
 */
+ (NSString *)format_stringWithVolume:(_int64)volume precision:(int)precision;

/*
* 格式化大额数据
* 小于等于0，返回"--"
* 大于0，小于1万，返回符合小数位数的值 如100.00
* 大于1万，小于1亿，格式化为以万做单位
* 大于1亿，格式化为以亿做单位
* @param volume 数值
* @Param precision 突破万后面显示的小数点个数，如100000，precision为2时显示10.00万
* @returns 字符串
*/
+ (NSString *)format_stringWithDecimalVolume:(_int64)volume precision:(int)precision;

/**
 * 格式化指数的交量数据
 * 小于等于0，返回"--"
 * 大于0，小于1万，单位为亿
 * 大于1万，单位为万亿
 * @param volume 成交量
 * @returns 字符串
 */
+ (NSString *)format_stringWithIndexVolume:(_int64)volume;

/**
 * 格式化价格数据成字符串
 * @param price 价格
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringWithPrice:(_int64)price length:(int)len precision:(int)precision;

/**
 * 格式化金额数据，如成交额、总市值、流通值
 * 小于等于0，返回"--"
 * 大于0，小于1万，单位为万
 * 大于1万，单位为亿
 * @param amount 金额
 * @returns 字符串
 */
+ (NSString *)format_stringWithAmount:(_int64)amount;

/**
 * 通过价格和昨收获取格式化后的涨跌字符串，涨幅>0 加正号，小于0有负号
 * @param price 现价
 * @param lastClose 昨收
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringForPriceChangeSignWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision;

/**
 * 通过价格和昨收获取格式化后的涨跌字符串，涨幅>0 不加正号，小于0有负号
 * @param price 现价
 * @param lastClose 昨收
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringForPriceChangeWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision;

/**
 * 通过价格和昨收获取格式化后的涨幅字符串，涨幅>0 不加正号，但涨幅<0会有负号
 * @param price 现价
 * @param lastClose 昨收
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringForPriceChangePercentWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision;

/**
 * 通过价格和昨收获取格式化后的涨幅字符串，如果涨幅>0 会加上正号
 * @param price 现价
 * @param lastClose 昨收
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringForPriceChangePercentSignWithPrice:(float)price lastClose:(float)lastClose length:(int)len precision:(int)precision;

/**
 * 获取格式化的换手字符串
 * @param volume 成交量
 * @param circulation 流通量
 * @returns 字符串
 */
+ (NSString *)format_stringForExchangeWithVolume:(_int64)volume circulation:(_int64)circulation;

/**
 * 获取格式化的振幅字符串
 * @param high 最高价
 * @param low 最低价
 * @param lastClose 昨收价
 * @returns 字符串
 */
+ (NSString *)format_stringForAmplitudeWithHigh:(float)high low:(float)low lastClose:(float)lastClose;

/**
 * 格式化ma的值，
 * 小于等于0 返回"--"
 * 大于1000，返回整形
 * 其它调用format_stringWithFloatValue:length:precision进行格式化
 * @param value 数值
 * @param len 总长度
 * @param precision 小数位数
 * @returns 字符串
 */
+ (NSString *)format_stringForMaWithValue:(float)value length:(int)len precision:(int)precision;

/**
 *  格式化传入的字符串,value大于0 加正号
 *
 *  @param tempString 传入的字符串
 *
 *  @return  >0  返回带正号的字符串
 */
+ (NSString *)format_stringForString:(NSString *)tempString;

/**
 *  格式化传入的字符串  添加%  针对小数
 *
 *  @param tempString 传入的字符串
 *
 *  @return 返回带%的字符串
 */
+ (NSString *)format_stringForPercent:(NSString *)tempString;


/**
 *  格式化传入的字符串  添加%  针对小数
 *  @param tempString 传入的字符串
 *  @param precision  小数位数
 *  @return 返回带%的字符串
 */
+ (NSString *)format_stringForPercent:(NSString *)tempString precision:(int)precision;

@end
